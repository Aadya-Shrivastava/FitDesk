import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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

  // Exercises ticked today, and the dates every one of that day's exercises was done.
  final doneKeys = <String>{}.obs;
  final completedDays = <String>{}.obs;

  static const _doneStoreKey = 'workoutDone'; // {"date": "yyyy-MM-dd", "keys": [...]}
  static const _daysStoreKey = 'workoutCompletedDays'; // ["yyyy-MM-dd", ...]
  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadProgress();
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

  // ---------------- completion tracking ----------------
  String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  String get _todayDate => _dateKey(DateTime.now());

  /// Stable id for one exercise row of the selected plan.
  String activityKey(String day, int index, Activities a) =>
      '${selected.value?.id ?? 0}|$day|$index|${a.activityId ?? a.activityName ?? ''}';

  bool isDone(String key) => doneKeys.contains(key);

  void toggle(String key) {
    if (!doneKeys.remove(key)) doneKeys.add(key);
    _saveProgress();
  }

  /// Ticks every key, or clears them all if they're already all done.
  void toggleAll(List<String> keys) {
    if (keys.isNotEmpty && keys.every(isDone)) {
      doneKeys.removeAll(keys);
    } else {
      doneKeys.addAll(keys);
    }
    _saveProgress();
  }

  /// The schedule day matching today's weekday ("Monday", "mon", ...), if any.
  String? todayDay(Map<String, List<Activities>> grouped) {
    final weekday = DateFormat('EEEE').format(DateTime.now()).toLowerCase();
    for (final day in grouped.keys) {
      final d = day.trim().toLowerCase();
      if (d.length >= 3 && weekday.startsWith(d.substring(0, 3))) return day;
    }
    return null;
  }

  /// Keys for today's exercises; the whole plan when no day matches today.
  List<String> todayKeys(Map<String, List<Activities>> grouped) {
    final today = todayDay(grouped);
    return [
      for (final e in grouped.entries)
        if (today == null || e.key == today)
          for (var i = 0; i < e.value.length; i++) activityKey(e.key, i, e.value[i]),
    ];
  }

  /// Consecutive completed days ending today (or yesterday, if today isn't finished yet).
  int streak(Map<String, List<Activities>> grouped) {
    final keys = todayKeys(grouped);
    final todayDone = keys.isNotEmpty && keys.every(isDone);
    var count = todayDone ? 1 : 0;
    var d = DateTime.now().subtract(const Duration(days: 1));
    while (completedDays.contains(_dateKey(d))) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  void _loadProgress() {
    final saved = _box.read(_doneStoreKey);
    if (saved is Map && saved['date'] == _todayDate && saved['keys'] is List) {
      doneKeys.assignAll((saved['keys'] as List).map((e) => e.toString()));
    }
    final days = _box.read(_daysStoreKey);
    if (days is List) completedDays.assignAll(days.map((e) => e.toString()));
  }

  void _saveProgress() {
    final w = selected.value;
    final keys = todayKeys(groupByDay(w?.activities ?? <Activities>[]));
    if (keys.isNotEmpty && keys.every(isDone)) {
      completedDays.add(_todayDate);
    } else {
      completedDays.remove(_todayDate);
    }
    _box.write(_doneStoreKey, {'date': _todayDate, 'keys': doneKeys.toList()});
    _box.write(_daysStoreKey, completedDays.toList());
  }
}
