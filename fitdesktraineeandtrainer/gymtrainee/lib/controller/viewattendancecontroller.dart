import 'package:get/get.dart';
import 'package:gymtrainee/Model/viewattendacnemodel.dart';
import 'package:gymtrainee/widgets/api_client.dart';
import 'package:gymtrainee/widgets/date_calc.dart';

class Viewattendancecontroller extends GetxController {
  // state
  final isLoading = false.obs;
  final error = "".obs;
  final attendanceList = <Attendance>[].obs;

  int get presentCount => attendanceList
      .where((a) => (a.status ?? '').toLowerCase() == 'present')
      .length;

  // calendar state
  final focusedDay = DateTime.now().obs;
  final selectedDay = Rxn<DateTime>(); // null = show every record

  static DateTime dayKey(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Records grouped by calendar day.
  Map<DateTime, List<Attendance>> get byDay {
    final map = <DateTime, List<Attendance>>{};
    for (final a in attendanceList) {
      final d = DateCalc.parse(a.date);
      if (d != null) map.putIfAbsent(dayKey(d), () => []).add(a);
    }
    return map;
  }

  /// The list under the calendar: the tapped day only, or everything.
  List<Attendance> get visible {
    final day = selectedDay.value;
    return day == null ? attendanceList : (byDay[dayKey(day)] ?? []);
  }

  /// Days in a row with a visit, ending today (or yesterday, if not in yet).
  int get currentStreak {
    final days = byDay.keys.toSet();
    var d = dayKey(DateTime.now());
    if (!days.contains(d)) d = d.subtract(const Duration(days: 1));
    var streak = 0;
    while (days.contains(d)) {
      streak++;
      d = d.subtract(const Duration(days: 1));
    }
    return streak;
  }

  /// Days visited in the month the calendar is showing.
  int get visitsInFocusedMonth {
    final f = focusedDay.value;
    return byDay.keys.where((d) => d.year == f.year && d.month == f.month).length;
  }

  void selectDay(DateTime day) {
    final same = selectedDay.value != null && dayKey(selectedDay.value!) == dayKey(day);
    selectedDay.value = same ? null : day; // tap again to show all
    focusedDay.value = day;
  }

  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    error.value = "";

    try {
      // Previously sent without the bearer token, so it always failed (401).
      final body = await Api.get('/trainee/attendance');
      final items =
          Api.findList(body, ['attendance', 'attendances']).map(Attendance.fromJson).toList();
      attendanceList.assignAll(items);
    } catch (e) {
      Api.report('ViewAttendance.fetchAttendance', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshAttendance() => fetchAttendance();
}
