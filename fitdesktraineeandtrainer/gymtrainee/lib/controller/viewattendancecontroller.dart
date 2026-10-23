import 'package:get/get.dart';
import 'package:gymtrainee/Model/viewattendacnemodel.dart';
import 'package:gymtrainee/widgets/api_client.dart';

class Viewattendancecontroller extends GetxController {
  // state
  final isLoading = false.obs;
  final error = "".obs;
  final attendanceList = <Attendance>[].obs;

  int get presentCount => attendanceList
      .where((a) => (a.status ?? '').toLowerCase() == 'present')
      .length;

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
