import 'package:get/get.dart';
import 'package:gymtrainee/Model/workoutmodel.dart';
import 'package:intl/intl.dart';
import 'package:gymtrainee/widgets/api_client.dart';
import 'package:gymtrainee/widgets/date_calc.dart';

class Viewtodayworkoutcontroller extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  final workouts = <Workouts>[].obs;
  final selected = Rxn<Workouts>();

  final showDetails = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkouts();
  }

  Future<void> fetchWorkouts() async {
    isLoading.value = true;
    error.value = '';

    try {
      final body = await Api.get('/trainee/workouts');
      final list =
          Api.findList(body, ['workouts']).map(Workouts.fromJson).toList();
      workouts.assignAll(list);

      // Choose today's workout if available
      selected.value =
          _pickTodayWorkout(list) ?? (list.isNotEmpty ? list.first : null);
    } catch (e) {
      Api.report('TodayWorkout.fetchWorkouts', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  void select(Workouts w) => selected.value = w;
  void toggleDetails() => showDetails.value = !showDetails.value;

  // ---------------- helpers ----------------
  String safe(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

  String timeShort(String? v) => safe(v);

  /// "30 Nov 2026 • 12 days left" for the plan's end date.
  String endLabel(String? raw) {
    final d = DateCalc.parse(raw);
    if (d == null) return safe(raw);
    final left = DateCalc.daysUntil(d)!;
    final tail = left < 0
        ? 'Plan ended'
        : left == 0
            ? 'Ends today'
            : '$left day${left == 1 ? '' : 's'} left';
    return '${DateFormat('dd MMM yyyy').format(d)} • $tail';
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    // Expecting yyyy-MM-dd or yyyy-MM-ddTHH:mm:ss...
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  bool _isTodayBetween(DateTime start, DateTime end) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !today.isBefore(s) && !today.isAfter(e);
  }

  Workouts? _pickTodayWorkout(List<Workouts> list) {
    for (final w in list) {
      final s = _parseDate(w.startDate);
      final e = _parseDate(w.endDate);
      if (s != null && e != null && _isTodayBetween(s, e)) return w;
    }
    return null;
  }

  // Group activities by day
  Map<String, List<Activities>> groupByDay(List<Activities> activities) {
    final map = <String, List<Activities>>{};
    for (final a in activities) {
      final day = safe(a.day);
      map.putIfAbsent(day, () => []);
      map[day]!.add(a);
    }
    return map;
  }
}
