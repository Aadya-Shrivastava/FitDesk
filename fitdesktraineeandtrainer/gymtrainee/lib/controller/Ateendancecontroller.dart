import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';
import 'package:gymtrainee/widgets/localStorage/localstorage.dart';
import 'package:gymtrainee/widgets/api_client.dart';

class AttendanceController extends GetxController {
  final isLoading = false.obs;
  final isPosting = false.obs;
  final error = ''.obs;

  final status = 'Present'.obs;
  final notesCtrl = ''.obs;

  final date = DateFormat('yyyy-MM-dd').format(DateTime.now()).obs;

  final checkedInTime = ''.obs;
  final checkedOutTime = ''.obs;

  final checkinAddress = ''.obs;
  final checkoutAddress = ''.obs;

  final hasCheckedIn = false.obs;
  final hasCheckedOut = false.obs;


  // -------------------- INIT --------------------
  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _loadCache();
    await _handleMidnightRules(); // ✅ auto checkout / reset if needed
    await fetchTodayAttendance(); // optional: sync with server
  }

  // -------------------- CACHE --------------------
  Future<void> _saveCache() async {
    await PrefManager().writeValue(key: PrefConst.attendanceDate, value: date.value);
    await PrefManager().writeValue(key: PrefConst.checkedInTime, value: checkedInTime.value);
    await PrefManager().writeValue(key: PrefConst.checkedOutTime, value: checkedOutTime.value);
    await PrefManager().writeValue(key: PrefConst.checkinAddress, value: checkinAddress.value);
    await PrefManager().writeValue(key: PrefConst.checkoutAddress, value: checkoutAddress.value);
    await PrefManager().writeValue(key: PrefConst.hasCheckedIn, value: hasCheckedIn.value.toString());
    await PrefManager().writeValue(key: PrefConst.hasCheckedOut, value: hasCheckedOut.value.toString());
  }

  Future<void> _loadCache() async {
    final cachedDate = await PrefManager().readValue(key: PrefConst.attendanceDate) ?? '';

    // If cache is from another day, wipe it
    if (cachedDate.isNotEmpty && cachedDate != date.value) {
      await _clearCacheForNewDay();
      return;
    }

    checkedInTime.value = await PrefManager().readValue(key: PrefConst.checkedInTime) ?? '';
    checkedOutTime.value = await PrefManager().readValue(key: PrefConst.checkedOutTime) ?? '';
    checkinAddress.value = await PrefManager().readValue(key: PrefConst.checkinAddress) ?? '';
    checkoutAddress.value = await PrefManager().readValue(key: PrefConst.checkoutAddress) ?? '';

    final hIn = await PrefManager().readValue(key: PrefConst.hasCheckedIn) ?? 'false';
    final hOut = await PrefManager().readValue(key: PrefConst.hasCheckedOut) ?? 'false';

    hasCheckedIn.value = hIn.toString().toLowerCase() == 'true';
    hasCheckedOut.value = hOut.toString().toLowerCase() == 'true';
  }

  Future<void> _clearCacheForNewDay() async {
    checkedInTime.value = '';
    checkedOutTime.value = '';
    checkinAddress.value = '';
    checkoutAddress.value = '';
    hasCheckedIn.value = false;
    hasCheckedOut.value = false;

    await PrefManager().writeValue(key: PrefConst.attendanceDate, value: date.value);
    await _saveCache();
  }

  // -------------------- MIDNIGHT AUTO RULES --------------------
  Future<void> _handleMidnightRules() async {
    // If user checked in and did not checkout, and day changed → auto-checkout yesterday
    final cachedDate = await PrefManager().readValue(key: PrefConst.attendanceDate) ?? '';

    // If cachedDate is empty (fresh install), just save today
    if (cachedDate.isEmpty) {
      await PrefManager().writeValue(key: PrefConst.attendanceDate, value: date.value);
      return;
    }

    // If yesterday checkin was pending checkout
    final wasCheckedIn = hasCheckedIn.value;
    final wasCheckedOut = hasCheckedOut.value;

    if (cachedDate != date.value && wasCheckedIn && !wasCheckedOut) {
      // ✅ Auto-checkout previous date at 23:59 (best practical)
      // Your requirement says 12 AM, but backend needs a time string.
      // We’ll set checkout = "23:59" for the previous day.
      await _autoCheckoutForDate(cachedDate, '23:59');
    }

    // If date changed, reset to today
    if (cachedDate != date.value) {
      await _clearCacheForNewDay();
    }
  }

  Future<void> _autoCheckoutForDate(String oldDate, String checkoutTime) async {
    try {
      // Only if we have checkin time for old date
      final oldCheckinTime = checkedInTime.value;
      if (oldCheckinTime.isEmpty) return;

      final payload = {
        "date": oldDate,
        "status": status.value,
        "checked_in_time": _toHHmm(oldCheckinTime),
        "checked_out_time": checkoutTime,
        "checkin_address": checkinAddress.value,
        "checkout_address": checkoutAddress.value.isEmpty ? "Auto checkout" : checkoutAddress.value,
        "notes": (notesCtrl.value.isEmpty) ? "Auto checkout at midnight" : notesCtrl.value,
      };

      // If backend rejects auto checkout, don’t break the app.
      await Api.post('/trainee/attendance', payload);
    } catch (e) {
      Api.report('Attendance._autoCheckoutForDate', e);
    }
  }

  // -------------------- SERVER SYNC (GET) --------------------
  Future<void> fetchTodayAttendance() async {
    isLoading.value = true;
    error.value = '';

    try {
      final body = await Api.get('/trainee/attendance');

      // GET /trainee/attendance returns the attendance history (a list), not
      // a single record — pick today's entry out of it. Reading it as a map
      // used to throw on every open and showed the error banner.
      final rows = Api.findList(body, ['attendance', 'attendances']);
      Map<String, dynamic>? data = rows.firstWhereOrNull(
          (r) => (r['date'] ?? '').toString().startsWith(date.value));
      if (rows.isEmpty && body is Map && body['data'] is Map) {
        final single = Map<String, dynamic>.from(body['data']);
        if ((single['date'] ?? '').toString().startsWith(date.value)) data = single;
      }
      if (data == null) return; // nothing recorded for today on the server yet

      checkedInTime.value = _toHHmm((data['checked_in_time'] ?? checkedInTime.value).toString());
      checkedOutTime.value = _toHHmm((data['checked_out_time'] ?? checkedOutTime.value).toString());
      checkinAddress.value = (data['checkin_address'] ?? checkinAddress.value).toString();
      checkoutAddress.value = (data['checkout_address'] ?? checkoutAddress.value).toString();

      final st = (data['status'] ?? '').toString();
      if (st == 'Present' || st == 'Absent' || st == 'Half Day') {
        status.value = st;
      }

      final n = (data['notes'] ?? '').toString();
      if (n.isNotEmpty) notesCtrl.value = n;

      hasCheckedIn.value = checkedInTime.value.isNotEmpty;
      hasCheckedOut.value = checkedOutTime.value.isNotEmpty;

      await _saveCache();
    } catch (e) {
      Api.report('Attendance.fetchTodayAttendance', e);
      // Not fatal: the local cache still shows today's status.
      if (e is ApiException && e.statusCode != 404) error.value = e.message;
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------- LOCATION --------------------
  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are OFF. Turn on GPS.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) throw Exception('Location permission denied.');
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permission permanently denied. Enable it in settings.');
    }

    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future<String> _reverseGeocode(Position p) async {
    final places = await placemarkFromCoordinates(p.latitude, p.longitude);
    if (places.isEmpty) return '${p.latitude}, ${p.longitude}';
    final pm = places.first;

    final parts = [
      pm.street,
      pm.subLocality,
      pm.locality,
      pm.administrativeArea,
      pm.postalCode,
      pm.country,
    ].where((x) => x != null && x.toString().trim().isNotEmpty).toList();

    return parts.join(', ');
  }

  String _nowTimeHHmm() => DateFormat('HH:mm').format(DateTime.now());

  // GET returns times as "HH:mm:ss" but POST validates "H:i"; trim seconds.
  String _toHHmm(String t) {
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(t.trim());
    return m == null ? t : '${m.group(1)!.padLeft(2, '0')}:${m.group(2)}';
  }

  // -------------------- ACTIONS --------------------
  Future<void> checkIn() async {
    if (hasCheckedIn.value) return;

    isPosting.value = true;
    error.value = '';

    try {
      final time = _nowTimeHHmm();
      final pos = await _getPosition();
      final address = await _reverseGeocode(pos);

      final payload = {
        "date": date.value,
        "status": status.value,
        "checked_in_time": time,
        "checked_out_time": "",
        "checkin_address": address,
        "checkout_address": "",
        "notes": notesCtrl.value,
      };

      await Api.post('/trainee/attendance', payload);

      checkedInTime.value = time;
      checkinAddress.value = address;
      hasCheckedIn.value = true;
      hasCheckedOut.value = false;

      await _saveCache();
    } catch (e) {
      Api.report('Attendance.checkIn', e);
      error.value = _msg(e);
    } finally {
      isPosting.value = false;
    }
  }

  Future<void> checkOut() async {
    if (!hasCheckedIn.value) {
      error.value = 'You must Check-In first.';
      return;
    }
    if (hasCheckedOut.value) return;

    isPosting.value = true;
    error.value = '';

    try {
      final time = _nowTimeHHmm();
      final pos = await _getPosition();
      final address = await _reverseGeocode(pos);

      final payload = {
        "date": date.value,
        "status": status.value,
        "checked_in_time": _toHHmm(checkedInTime.value),
        "checked_out_time": time,
        "checkin_address": checkinAddress.value,
        "checkout_address": address,
        "notes": notesCtrl.value,
      };

      await Api.post('/trainee/attendance', payload);

      checkedOutTime.value = time;
      checkoutAddress.value = address;
      hasCheckedOut.value = true;

      await _saveCache();
    } catch (e) {
      Api.report('Attendance.checkOut', e);
      error.value = _msg(e);
    } finally {
      isPosting.value = false;
    }
  }

  // -------------------- UI helpers --------------------
  // Location errors are thrown as Exception('...'); show their text as-is.
  String _msg(Object e) => e is ApiException
      ? e.message
      : e.toString().replaceFirst('Exception: ', '');

  String safe(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

  void setNotes(String v) {
    notesCtrl.value = v;
    _saveCache();
  }

  void setStatus(String v) {
    if (v == 'Present' || v == 'Absent' || v == 'Half Day') {
      status.value = v;
      _saveCache();
    }
  }
}
