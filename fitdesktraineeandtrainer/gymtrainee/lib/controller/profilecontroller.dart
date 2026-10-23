import 'package:get/get.dart';
import 'package:gymtrainee/Model/json_utils.dart';
import 'package:gymtrainee/widgets/api_client.dart';
import 'package:gymtrainee/widgets/date_calc.dart';
import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';
import 'package:gymtrainee/widgets/localStorage/localstorage.dart';

/// Profile data: shown instantly from what login saved, then refreshed from
/// GET /auth/profile. Also used by the dashboard for name/membership info.
class ProfileController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;
  final user = <String, dynamic>{}.obs;
  final trainee = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCached().then((_) => fetchProfile());
  }

  Future<void> _loadCached() async {
    final u = asMap(await PrefManager().readValue(key: PrefConst.userJson)) ?? {};
    final t = asMap(await PrefManager().readValue(key: PrefConst.traineeJson)) ?? {};
    // Older logins only stored these individual keys.
    u['name'] ??= await PrefManager().readValue(key: PrefConst.userName);
    u['email'] ??= await PrefManager().readValue(key: PrefConst.userEmail);
    u['phone_number'] ??= await PrefManager().readValue(key: PrefConst.userPhone);
    u['profile'] ??= await PrefManager().readValue(key: PrefConst.userId);
    t['fitness_goal'] ??= await PrefManager().readValue(key: PrefConst.userType);
    user.assignAll(u);
    trainee.assignAll(t);
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    error.value = '';
    try {
      final body = await Api.get('/auth/profile');
      final data = asMap(asMap(body)?['data']) ?? asMap(body) ?? {};
      final u = asMap(data['user']) ?? data;
      final t = asMap(data['trainee']) ?? asMap(u['trainee']);
      if (u.isNotEmpty) {
        user.addAll(Map<String, dynamic>.from(u)..remove('trainee'));
        await PrefManager().writeValue(key: PrefConst.userJson, value: Map<String, dynamic>.from(user));
        if (user['name'] != null) {
          await PrefManager().writeValue(key: PrefConst.userName, value: user['name']);
        }
      }
      if (t != null && t.isNotEmpty) {
        trainee.addAll(t);
        await PrefManager().writeValue(key: PrefConst.traineeJson, value: Map<String, dynamic>.from(trainee));
      }
    } catch (e) {
      // Cached data is still shown, so only surface the error if we have nothing.
      Api.report('Profile.fetch', e);
      if (user['name'] == null) error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  String _s(Map m, String k) {
    final v = m[k];
    return v == null || v.toString().trim().isEmpty ? '' : v.toString().trim();
  }

  String get name => _s(user, 'name');
  String get email => _s(user, 'email');
  String get phone => _s(user, 'phone_number');
  String get role => _s(user, 'type');
  String get photoUrl => Api.fileUrl(_s(user, 'profile'));
  String get initials {
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get gender => _s(trainee, 'gender');
  String get dob => _s(trainee, 'dob');
  // Worked out from DOB so it never goes stale; falls back to the stored age.
  String get age =>
      DateCalc.ageFromString(_s(trainee, 'dob'))?.toString() ?? _s(trainee, 'age');
  String get fitnessGoal => _s(trainee, 'fitness_goal');
  String get memberId => _s(trainee, 'trainee_id');

  String get membershipName {
    final plan = trainee['membership_plan'] ?? trainee['membership'];
    if (plan is Map) return _s(plan, 'name').isNotEmpty ? _s(plan, 'name') : _s(plan, 'title');
    final named = _s(trainee, 'membership_name');
    if (named.isNotEmpty) return named;
    return plan == null ? '' : 'Plan #$plan';
  }

  DateTime? get membershipStart => DateTime.tryParse(_s(trainee, 'membership_start_date'));
  DateTime? get membershipExpiry => DateTime.tryParse(_s(trainee, 'membership_expiry_date'));

  /// Days until expiry (negative once expired), or null if unknown.
  int? get daysLeft {
    final e = membershipExpiry;
    if (e == null) return null;
    final now = DateTime.now();
    return DateTime(e.year, e.month, e.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  /// 0..1 share of the membership period already used.
  double? get membershipProgress {
    final s = membershipStart, e = membershipExpiry;
    if (s == null || e == null || !e.isAfter(s)) return null;
    final used = DateTime.now().difference(s).inSeconds / e.difference(s).inSeconds;
    return used.clamp(0.0, 1.0);
  }
}
