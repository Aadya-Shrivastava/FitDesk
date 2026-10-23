import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:gymtrainee/Model/dashboardmodel.dart';
import 'package:gymtrainee/Model/json_utils.dart';
import 'package:gymtrainee/controller/eventscontroller.dart';
import 'package:gymtrainee/controller/feescontroller.dart';
import 'package:gymtrainee/controller/notificationcontroller.dart';
import 'package:gymtrainee/controller/profilecontroller.dart';
import 'package:gymtrainee/widgets/api_client.dart';
import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';
import 'package:gymtrainee/widgets/localStorage/localstorage.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  final error = ''.obs;
  var dashboardData = dashboard().obs;

  // Today's check-in state, read from the attendance screen's local cache.
  final checkedInTime = ''.obs;
  final checkedOutTime = ''.obs;

  // Shared with their own screens so data is fetched once and stays in sync.
  late final ProfileController profile;
  late final NotificationController notifications;
  late final FeesController fees;
  late final EventsController events;

  // Kept for the existing hero card bindings.
  final name = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;

  @override
  void onInit() {
    super.onInit();
    profile = Get.put(ProfileController());
    notifications = Get.put(NotificationController());
    fees = Get.put(FeesController());
    events = Get.put(EventsController());
    ever(profile.user, (_) => _syncProfile());
    _syncProfile();
    loadTodayAttendance();
    fetchDashboardData();
  }

  void _syncProfile() {
    name.value = profile.name;
    email.value = profile.email;
    phone.value = profile.phone;
  }

  Future<void> fetchDashboardData() async {
    error.value = '';
    try {
      final body = await Api.get('/trainee/dashboard');
      dashboardData.value = dashboard.fromJson(asMap(body) ?? {});
    } catch (e) {
      Api.report('Dashboard.fetchDashboardData', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Pull-to-refresh: reload everything shown on the dashboard.
  Future<void> refreshAll() async {
    await Future.wait([
      fetchDashboardData(),
      profile.fetchProfile(),
      notifications.fetchNotifications(),
      fees.fetchFees(),
      events.fetchEvents(),
      loadTodayAttendance(),
    ]);
  }

  Future<void> loadTodayAttendance() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final cachedDate =
        await PrefManager().readValue(key: PrefConst.attendanceDate) ?? '';
    if (cachedDate != today) {
      checkedInTime.value = '';
      checkedOutTime.value = '';
      return;
    }
    checkedInTime.value =
        (await PrefManager().readValue(key: PrefConst.checkedInTime) ?? '').toString();
    checkedOutTime.value =
        (await PrefManager().readValue(key: PrefConst.checkedOutTime) ?? '').toString();
  }

  String get greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
