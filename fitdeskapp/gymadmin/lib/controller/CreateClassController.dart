import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import '../widgets/localStorage/PrefConst.dart';

import 'viewtrainercontroller.dart';
import 'viewtraineecontroller.dart'; // ✅ your TraineeListController

class ScheduleItem {
  final String day;
  String startTime; // "09:00"
  String endTime;   // "10:30"

  ScheduleItem({
    required this.day,
    this.startTime = "--:--",
    this.endTime = "--:--",
  });

  Map<String, dynamic> toJson() => {
        "day": day,
        "start_time": startTime,
        "end_time": endTime,
      };
}

class ClassController extends GetxController {
  // API
  final String createClassEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/classes";

  // Form
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final titleController = TextEditingController();
  final feeController = TextEditingController();
  final addressController = TextEditingController();
  final notesController = TextEditingController();

  // Schedule
  final selectedDay = 'Sunday'.obs;
  final scheduleList = <ScheduleItem>[].obs;

  // Loading
  final isSubmitting = false.obs;

  // ✅ Trainer controller
  late final ViewTrainerController trainerCtrl;

  // ✅ Trainee controller (API)
  late final TraineeListController traineeCtrl;

  // ✅ Selected IDs
  final RxnInt selectedTrainerId = RxnInt();

  // ✅ MULTI trainees
  final selectedTraineeIds = <int>[].obs;

  Future<String?> getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();

    trainerCtrl = Get.isRegistered<ViewTrainerController>()
        ? Get.find<ViewTrainerController>()
        : Get.put(ViewTrainerController(), permanent: true);

    traineeCtrl = Get.isRegistered<TraineeListController>()
        ? Get.find<TraineeListController>()
        : Get.put(TraineeListController(), permanent: true);

    // Ensure data is loaded
    trainerCtrl.fetchTrainers(page: 1);
    traineeCtrl.fetchTrainees(reset: true);
  }

  @override
  void onClose() {
    titleController.dispose();
    feeController.dispose();
    addressController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // -------- Schedule --------
  void addSchedule() {
    scheduleList.add(ScheduleItem(day: selectedDay.value));
  }

  void removeSchedule(int index) {
    scheduleList.removeAt(index);
  }

  String _toHHmm(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  TimeOfDay? _parseTime(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return TimeOfDay(hour: h, minute: m);
  }

  Future<void> selectTime(BuildContext context, int index, bool isStart) async {
    final item = scheduleList[index];
    final current = isStart ? item.startTime : item.endTime;

    final picked = await showTimePicker(
      context: context,
      initialTime: _parseTime(current) ?? TimeOfDay.now(),
    );
    if (picked == null) return;

    final formatted = _toHHmm(picked);

    if (isStart) {
      item.startTime = formatted;
    } else {
      item.endTime = formatted;
    }

    scheduleList[index] = item;
    scheduleList.refresh();
  }

  // ✅ Multi select helper
  void toggleTrainee(int id) {
    if (selectedTraineeIds.contains(id)) {
      selectedTraineeIds.remove(id);
    } else {
      selectedTraineeIds.add(id);
    }
  }

  void clearSelectedTrainees() {
    selectedTraineeIds.clear();
  }

  // -------- Submit --------
  Future<void> submitForm() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final fees = double.tryParse(feeController.text.trim());
    if (fees == null || fees <= 0) {
      _showError("Fees must be a valid number > 0.");
      return;
    }

   

    

    if (scheduleList.isEmpty) {
      _showError("Please add at least one schedule.");
      return;
    }

    for (final s in scheduleList) {
      if (s.startTime == "--:--" || s.endTime == "--:--") {
        _showError("Please select start & end time for ${s.day}.");
        return;
      }
    }

    isSubmitting.value = true;

    try {
      final token = await getToken();
      if (token == null || token.trim().isEmpty) {
        _showError("Token missing. Please login again.");
        return;
      }

      final payload = {
        "title": titleController.text.trim(),
        "fees": fees,
        "address": addressController.text.trim(),
        "notes": notesController.text.trim(),
        "schedules": scheduleList.map((e) => e.toJson()).toList(),
        "trainer_ids": [selectedTrainerId.value], // API expects array
        "trainee_ids": selectedTraineeIds.toList(), // ✅ MULTI
      };

      debugPrint("CREATE CLASS PAYLOAD: ${jsonEncode(payload)}");

      final resp = await http
          .post(
            Uri.parse(createClassEndpoint),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer ${token.trim()}",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Class created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      } else {
        _showError("Create failed (${resp.statusCode}).\n${resp.body}");
      }
    } catch (e) {
      _showError("Create failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    feeController.clear();
    addressController.clear();
    notesController.clear();

    selectedTrainerId.value = null;
    selectedTraineeIds.clear();

    selectedDay.value = 'Sunday';
    scheduleList.clear();
  }

  void _showError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
