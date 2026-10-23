import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';
import 'package:gymadmin/controller/viewtraineecontroller.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:http/http.dart' as http;

import '../Model/classmodel.dart';
import '../widgets/localStorage/PrefConst.dart';

class ViewClassesController extends GetxController {
  final String endpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/classes";

  // state
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;

  // data
  final classes = <Classes>[].obs;

  // pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;

  // Trainer/trainee lists, reused for the "Assign Trainer"/"Assign Trainee"
  // pickers so we don't fetch them twice.
  late final ViewTrainerController trainerCtrl;
  late final TraineeListController traineeCtrl;

  // True while an assign-trainer/assign-trainee request is in flight.
  final isAssigning = false.obs;

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

    fetchClasses(reset: true);
  }

  Future<void> fetchClasses({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage.value = 1;
      lastPage.value = 1;
      total.value = 0;
      classes.clear();
      error.value = '';
    }

    isLoading.value = true;
    error.value = '';

    try {
      final token = await getToken();

      final uri = Uri.parse(endpoint).replace(queryParameters: {
        "page": "${currentPage.value}",
      });

      final resp = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = classmodel.fromJson(decoded);

        final list = model.data?.classes ?? <Classes>[];
        final pag = model.data?.pagination;

        if (reset) {
          classes.assignAll(list);
        } else {
          classes.addAll(list);
        }

        currentPage.value = pag?.currentPage ?? currentPage.value;
        lastPage.value = pag?.lastPage ?? 1;
        total.value = pag?.total ?? classes.length;
      } else {
        error.value = _extractError(resp);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (currentPage.value >= lastPage.value) return;

    isLoadingMore.value = true;
    try {
      currentPage.value = currentPage.value + 1;
      await fetchClasses(reset: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshList() async {
    await fetchClasses(reset: true);
  }

  // -------- Assign trainer / trainee --------

  Future<void> assignTrainer(int classId, int trainerId) async {
    final ok = await _postAssign(
      path: "$endpoint/$classId/assign-trainer",
      body: {"trainer_id": trainerId},
    );
    if (ok) {
      Get.snackbar(
        "Success",
        "Trainer assigned to class.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await refreshList();
    }
  }

  Future<void> assignTrainee(int classId, int traineeId) async {
    final ok = await _postAssign(
      path: "$endpoint/$classId/assign-trainee",
      body: {"trainee_id": traineeId},
    );
    if (ok) {
      Get.snackbar(
        "Success",
        "Trainee assigned to class.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await refreshList();
    }
  }

  /// Shared POST helper for both assign endpoints. Returns true on success;
  /// shows an error dialog with the backend's message and returns false
  /// otherwise.
  Future<bool> _postAssign({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    if (isAssigning.value) return false;
    isAssigning.value = true;

    try {
      final token = await getToken();
      if (token == null || token.trim().isEmpty) {
        _showAssignError("Token missing. Please login again.");
        return false;
      }

      final resp = await http
          .post(
            Uri.parse(path),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer ${token.trim()}",
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        return true;
      }

      _showAssignError(_extractError(resp));
      return false;
    } catch (e) {
      _showAssignError("Request failed: $e");
      return false;
    } finally {
      isAssigning.value = false;
    }
  }

  void _showAssignError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }

  // -------- Helpers ----------
  String trainerNames(Classes c) {
    final t = c.trainers ?? [];
    if (t.isEmpty) return "-";

    // trainers might be Map with name/title OR string OR something else
    final names = <String>[];

    for (final x in t) {
      if (x == null) continue;

      if (x is Map) {
        final m = Map<String, dynamic>.from(x);
        final name = (m["name"] ?? m["title"] ?? m["full_name"] ?? "").toString();
        if (name.trim().isNotEmpty) names.add(name.trim());
      } else if (x is String) {
        if (x.trim().isNotEmpty) names.add(x.trim());
      } else {
        names.add(x.toString());
      }
    }

    if (names.isEmpty) return "-";
    return names.join(", ");
  }

  /// Short "Day HH:mm-HH:mm" summary for each schedule, used in the list.
  String scheduleSummary(Classes c) {
    final schedules = c.schedules ?? [];
    if (schedules.isEmpty) return "-";
    return schedules
        .map((s) => "${_shortDay(s.day)} ${s.startTime ?? "--:--"}-${s.endTime ?? "--:--"}")
        .join("\n");
  }

  String _shortDay(String? day) {
    if (day == null || day.trim().isEmpty) return "-";
    return day.trim().substring(0, day.trim().length >= 3 ? 3 : day.trim().length);
  }

  void viewClassDetails(Classes c) {
    final schedules = (c.schedules ?? [])
        .map((s) => "${s.day ?? "-"}: ${s.startTime ?? "--:--"}-${s.endTime ?? "--:--"}")
        .join("\n");

    Get.defaultDialog(
      title: c.title ?? "Class",
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Fees: ₹${c.fees ?? 0}"),
            Text("Address: ${c.address ?? '-'}"),
            Text("Notes: ${(c.notes ?? '').trim().isEmpty ? '-' : c.notes}"),
            Text("Trainers: ${trainerNames(c)}"),
            Text("Total Trainers: ${c.totalTrainers ?? 0}"),
            Text("Total Trainees: ${c.totalTrainees ?? 0}"),
            const SizedBox(height: 8),
            Text("Schedules:\n${schedules.isEmpty ? '-' : schedules}"),
            const SizedBox(height: 8),
            Text("Created: ${c.createdAt ?? '-'}"),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text("Close"),
      ),
    );
  }

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
}
