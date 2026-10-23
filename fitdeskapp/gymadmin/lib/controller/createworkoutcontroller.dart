import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import '../widgets/localStorage/PrefConst.dart';

import '../Model/workoutmodel.dart' as activity_model;
import '../Model/classmodel.dart' as class_model;

// ✅ your API trainee list controller + model types
import 'package:gymadmin/controller/viewtraineecontroller.dart';
import 'package:gymadmin/Model/traineemodel.dart';

class SimpleItem {
  final int id;
  final String title;
  SimpleItem({required this.id, required this.title});
}

class WorkoutController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // APIs
  final String workoutsEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/workouts";
  final String activitiesEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/workout-activities";
  final String classesEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/classes";

  // Assign Type (API expects: trainee / class)
  final assignType = "trainee".obs;

  // Selected assign id
  final RxnInt selectedTraineeId = RxnInt();
  final RxnInt selectedClassId = RxnInt();

  // Dates (API wants yyyy-MM-dd)
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  // Notes
  final notesController = TextEditingController();

  // Loading
  final isLoadingActivities = false.obs;
  final isLoadingClasses = false.obs;
  final isSubmitting = false.obs;

  // Errors
  final errorActivities = ''.obs;
  final errorClasses = ''.obs;

  // Dropdown data
  final activityOptions = <SimpleItem>[].obs;
  final classOptions = <SimpleItem>[].obs;

  // ✅ Trainee dropdown data (REAL from API)
  final isLoadingTrainees = false.obs;
  final errorTrainees = ''.obs;
  final traineeOptions = <SimpleItem>[].obs;

  // ✅ Trainee API controller
  late final TraineeListController traineeCtrl;
  Worker? _wTrainees;

  // Workout entries
  final workouts = <Map<String, dynamic>>[].obs;

  final List<String> days = const [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
  ];

  Future<String?> getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();

    // ✅ attach trainee controller
    traineeCtrl = Get.isRegistered<TraineeListController>()
        ? Get.find<TraineeListController>()
        : Get.put(TraineeListController(), permanent: true);

    // whenever API trainees update → map to dropdown
    _wTrainees = ever<List<Trainees>>(traineeCtrl.trainees, (_) {
      _mapTraineesToOptions(traineeCtrl.trainees);
      // keep selected value valid
      _ensureSelectedTraineeExists();
    });

    fetchWorkoutActivities();
    fetchClasses();
    fetchTrainees(); // ✅ load trainees

    addWorkoutEntry();
  }

  @override
  void onClose() {
    _wTrainees?.dispose();
    startDateController.dispose();
    endDateController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // ---------- trainees ----------
  Future<void> fetchTrainees() async {
    isLoadingTrainees.value = true;
    errorTrainees.value = "";
    try {
      await traineeCtrl.fetchTrainees(reset: true);
      _mapTraineesToOptions(traineeCtrl.trainees);
      _ensureSelectedTraineeExists();
    } catch (e) {
      errorTrainees.value = "Failed to load trainees: $e";
    } finally {
      isLoadingTrainees.value = false;
    }
  }

  void _mapTraineesToOptions(List<Trainees> list) {
    final mapped = list
        .where((t) => (t.id ?? 0) > 0)
        .map((t) {
          final id = t.id!;
          final name = (t.name ?? "").trim();
          final email = (t.email ?? "").trim();

          final label = name.isNotEmpty
              ? name
              : (email.isNotEmpty ? email : "Trainee #$id");

          return SimpleItem(id: id, title: label);
        })
        .toList();

    traineeOptions.assignAll(mapped);
  }

  void _ensureSelectedTraineeExists() {
    final selected = selectedTraineeId.value;
    if (selected == null) return;
    final ok = traineeOptions.any((x) => x.id == selected);
    if (!ok) selectedTraineeId.value = null;
  }

  // ---------- Load workout activities ----------
  Future<void> fetchWorkoutActivities() async {
    isLoadingActivities.value = true;
    errorActivities.value = '';
    try {
      final token = await getToken();

      final resp = await http.get(
        Uri.parse(activitiesEndpoint),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = activity_model.workoutmodel.fromJson(decoded);

        final list = model.data?.activities ?? <activity_model.Activities>[];
        final mapped = list
            .where((a) => a.id != null && (a.title ?? '').trim().isNotEmpty)
            .map((a) => SimpleItem(id: a.id!, title: a.title!.trim()))
            .toList();

        activityOptions.assignAll(mapped);

        // also update default activity_id for existing rows if null
        if (activityOptions.isNotEmpty) {
          for (final row in workouts) {
            row['activity_id'] ??= activityOptions.first.id;
          }
          workouts.refresh();
        }
      } else {
        errorActivities.value = _extractError(resp);
      }
    } catch (e) {
      errorActivities.value = e.toString();
    } finally {
      isLoadingActivities.value = false;
    }
  }

  // ---------- Load classes ----------
  Future<void> fetchClasses() async {
    isLoadingClasses.value = true;
    errorClasses.value = '';
    try {
      final token = await getToken();

      final resp = await http.get(
        Uri.parse(classesEndpoint),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = class_model.classmodel.fromJson(decoded);

        final list = model.data?.classes ?? <class_model.Classes>[];
        final mapped = list
            .where((c) => c.id != null && (c.title ?? '').trim().isNotEmpty)
            .map((c) => SimpleItem(id: c.id!, title: c.title!.trim()))
            .toList();

        classOptions.assignAll(mapped);
      } else {
        errorClasses.value = _extractError(resp);
      }
    } catch (e) {
      errorClasses.value = e.toString();
    } finally {
      isLoadingClasses.value = false;
    }
  }

  // ---------- Workout rows ----------
  void addWorkoutEntry() {
    final defaultActivityId =
        activityOptions.isNotEmpty ? activityOptions.first.id : null;

    workouts.add({
      'day': 'Sunday',
      'activity_id': defaultActivityId, // int?
      'weight': '',
      'sets': '',
      'reps': '',
      'rest': '',
    });
  }

  void removeWorkoutEntry(int index) {
    workouts.removeAt(index);
  }

  // ---------- Date picking ----------
  Future<void> pickDate(TextEditingController ctrl, {required bool isStart}) async {
    final initial = isStart
        ? (startDate.value ?? DateTime.now())
        : (endDate.value ?? (startDate.value ?? DateTime.now()));

    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null) return;

    final formatted = _yyyyMmDd(picked);

    if (isStart) {
      startDate.value = picked;
      startDateController.text = formatted;

      if (endDate.value != null && endDate.value!.isBefore(picked)) {
        endDate.value = null;
        endDateController.clear();
      }
    } else {
      if (startDate.value != null && picked.isBefore(startDate.value!)) {
        _showError("End date cannot be before start date.");
        return;
      }
      endDate.value = picked;
      endDateController.text = formatted;
    }
  }

  String _yyyyMmDd(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return "$y-$m-$day";
  }

  // ---------- Submit ----------
  Future<void> submitForm() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    if (workouts.isEmpty) {
      _showError("Please add at least one workout activity row.");
      return;
    }

    final assignTo = assignType.value; // trainee/class
    final assignId = assignTo == "trainee"
        ? selectedTraineeId.value
        : selectedClassId.value;

    if (assignId == null) {
      _showError("Please select ${assignTo == 'trainee' ? 'Trainee' : 'Class'}.");
      return;
    }

    if (startDateController.text.trim().isEmpty) {
      _showError("Start date is required.");
      return;
    }
    if (endDateController.text.trim().isEmpty) {
      _showError("End date is required.");
      return;
    }

    for (int i = 0; i < workouts.length; i++) {
      final row = workouts[i];

      if (row['activity_id'] == null) {
        _showError("Select activity in row ${i + 1}.");
        return;
      }

      final weight = int.tryParse((row['weight'] ?? '').toString());
      final sets = int.tryParse((row['sets'] ?? '').toString());
      final reps = int.tryParse((row['reps'] ?? '').toString());
      final rest = int.tryParse((row['rest'] ?? '').toString());

      if (weight == null || sets == null || reps == null || rest == null) {
        _showError("Row ${i + 1}: weight/sets/reps/rest must be valid numbers.");
        return;
      }
      if (sets <= 0 || reps <= 0) {
        _showError("Row ${i + 1}: sets and reps must be > 0.");
        return;
      }
    }

    isSubmitting.value = true;

    try {
      final token = await getToken();

      final payload = {
        "assign_to": assignTo,
        "assign_id": assignId,
        "start_date": startDateController.text.trim(),
        "end_date": endDateController.text.trim(),
        "notes": notesController.text.trim(),
        "activities": workouts.map((row) {
          return {
            "day": row["day"],
            "activity_id": row["activity_id"],
            "weight": int.parse(row["weight"].toString()),
            "sets": int.parse(row["sets"].toString()),
            "reps": int.parse(row["reps"].toString()),
            "rest": int.parse(row["rest"].toString()),
          };
        }).toList(),
      };

      final resp = await http.post(
        Uri.parse(workoutsEndpoint),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Workout created successfully!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
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
    assignType.value = "trainee";
    selectedTraineeId.value = null;
    selectedClassId.value = null;

    startDate.value = null;
    endDate.value = null;
    startDateController.clear();
    endDateController.clear();

    notesController.clear();
    workouts.clear();
    addWorkoutEntry();
  }

  // ---------- errors ----------
  String _extractError(http.Response resp) {
    try {
      final decoded = jsonDecode(resp.body);
      if (decoded is Map) {
        if (decoded["message"] != null) return decoded["message"].toString();
        if (decoded["error"] != null) return decoded["error"].toString();
        if (decoded["errors"] != null) return decoded["errors"].toString();
      }
      return "Failed (${resp.statusCode}): ${resp.body}";
    } catch (_) {
      return "Failed (${resp.statusCode}): ${resp.body}";
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }
}
