import 'package:get/get.dart';
import 'package:gymtrainee/Model/json_utils.dart';
import 'package:gymtrainee/Model/trainerdetailsmodel.dart';
import 'package:gymtrainee/widgets/api_client.dart';

class ViewTrainerController extends GetxController {
  final isLoading = false.obs;
  final error = ''.obs;

  final trainers = <Trainers>[].obs;
  final selectedTrainer = Rxn<Trainers>();

  // UI state
  final showDetails = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTrainers();
  }

  Future<void> fetchTrainers() async {
    isLoading.value = true;
    error.value = '';

    try {
      final body = await Api.get('/trainee/trainers');
      final list =
          Api.findList(body, ['trainers']).map(Trainers.fromJson).toList();
      // The API returns one assigned trainer as an object:
      // {data: {trainer_assigned: true, trainer: {...}}}
      if (list.isEmpty) {
        final single = asMap(asMap(asMap(body)?['data'])?['trainer']);
        if (single != null && single.isNotEmpty) list.add(Trainers.fromJson(single));
      }
      trainers.assignAll(list);

      // Select trainer by argument if passed, else first
      final arg = Get.arguments;
      if (arg is int) {
        selectedTrainer.value =
            trainers.firstWhereOrNull((t) => t.id == arg || t.trainerId == arg);
      }
      selectedTrainer.value ??= trainers.isNotEmpty ? trainers.first : null;
    } catch (e) {
      Api.report('ViewTrainer.fetchTrainers', e);
      error.value = Api.message(e);
    } finally {
      isLoading.value = false;
    }
  }

  void selectTrainer(Trainers t) {
    selectedTrainer.value = t;
  }

  void toggleDetails() {
    showDetails.value = !showDetails.value;
  }

  String safe(String? v) => (v == null || v.trim().isEmpty) ? '-' : v.trim();

  // If profile is relative path sometimes, normalize here
  String profileUrl(String? raw) => Api.fileUrl(raw);
}
