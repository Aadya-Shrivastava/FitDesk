import 'package:get/get.dart';
import 'package:gymtrainee/Model/classesmodel.dart';
import 'package:gymtrainee/widgets/api_client.dart';

class Viewclasscontroller extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  final classesList = <Classes>[].obs;
  final selectedClass = Rxn<Classes>();

  final showDetails = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    isLoading.value = true;
    error.value = '';

    try {
      final body = await Api.get('/trainee/classes');
      final list = Api.findList(body, ['classes']).map(Classes.fromJson).toList();
      classesList.assignAll(list);

      // Optional: pass class id via Get.arguments
      final arg = Get.arguments;
      if (arg is int) {
        selectedClass.value = classesList.firstWhereOrNull((c) => c.id == arg);
      }
      selectedClass.value ??= classesList.isNotEmpty ? classesList.first : null;
    } catch (e) {
      Api.report('ViewClass.fetchClasses', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  void select(Classes c) => selectedClass.value = c;
  void toggleDetails() => showDetails.value = !showDetails.value;

  String safe(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

  String money(int? v) => v == null ? '-' : '₹$v';

  String timeFmt(String? t) {
    // API usually gives "18:00:00" etc. Keep simple.
    if (t == null || t.trim().isEmpty) return '-';
    return t.length >= 5 ? t.substring(0, 5) : t;
  }

  String scheduleLine(Schedules s) {
    final day = safe(s.day);
    final st = timeFmt(s.startTime);
    final et = timeFmt(s.endTime);
    return '$day • $st - $et';
  }
}
