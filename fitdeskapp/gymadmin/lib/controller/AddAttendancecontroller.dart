import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// local storage
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/controller/viewtrainercontroller.dart';
import 'package:gymadmin/controller/viewtraineecontroller.dart';
import 'package:gymadmin/Model/viewtrainermodel.dart';
import 'package:gymadmin/Model/traineemodel.dart';

class AttendanceController extends GetxController {
  // API
  final String createAttendanceEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/attendance";

  // UI state
  final isLoading = false.obs;
  final isSaving = false.obs;

  // Dropdown
  final selectedType = "Trainee".obs;
  final List<String> typeOptions = ["Trainee", "Trainer"];

  // Date UI: dd-MM-yyyy
  final dateController = TextEditingController();

  // Each row MUST have: user_id, name, present, checkIn(HH:mm), checkOut(HH:mm), notes
  final attendanceList = <Map<String, dynamic>>[].obs;

  // live data controllers
  late final ViewTrainerController trainerCtrl;
  late final TraineeListController traineeCtrl;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());

    trainerCtrl = Get.isRegistered<ViewTrainerController>()
        ? Get.find<ViewTrainerController>()
        : Get.put(ViewTrainerController(), permanent: true);

    traineeCtrl = Get.isRegistered<TraineeListController>()
        ? Get.find<TraineeListController>()
        : Get.put(TraineeListController(), permanent: true);
  }

  @override
  void onClose() {
    dateController.dispose();
    super.onClose();
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: _parseUiDate(dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      dateController.text = DateFormat('dd-MM-yyyy').format(picked);
    }
  }

  /// APPLY = load list for selected type & date
  Future<void> apply() async {
    if (selectedType.value.trim().isEmpty) {
      _warn("Select Type");
      return;
    }
    if (!_isValidUiDate(dateController.text)) {
      _warn("Select valid date (DD-MM-YYYY)");
      return;
    }

    isLoading.value = true;
    try {
      final key = "${selectedType.value}_${dateController.text}";
      final existingKey =
          attendanceList.isNotEmpty ? attendanceList.first["_key"] : null;

      // Don’t destroy edits if user taps Apply again with same filters
      if (existingKey == key) return;

      if (selectedType.value == "Trainee") {
        await traineeCtrl.fetchTrainees(reset: true);
        if (traineeCtrl.errorMessage.value.isNotEmpty) {
          _warn(traineeCtrl.errorMessage.value);
          return;
        }

        final rows = traineeCtrl.trainees
            .where((t) => _traineeUserId(t) > 0)
            .map((t) => _row(
                  userId: _traineeUserId(t),
                  name: _displayName(t.name, t.email, "Trainee", _traineeUserId(t)),
                  key: key,
                ))
            .toList();

        attendanceList.assignAll(rows);
      } else {
        await trainerCtrl.fetchTrainers(page: 1);
        if (trainerCtrl.error.value.isNotEmpty) {
          _warn(trainerCtrl.error.value);
          return;
        }

        final rows = trainerCtrl.trainers
            .where((t) => _trainerUserId(t) > 0)
            .map((t) => _row(
                  userId: _trainerUserId(t),
                  name: _displayName(t.name, t.email, "Trainer", _trainerUserId(t)),
                  key: key,
                ))
            .toList();

        attendanceList.assignAll(rows);
      }
    } finally {
      isLoading.value = false;
    }
  }

  int _traineeUserId(Trainees t) {
    final id = t.id ?? t.traineeId ?? 0;
    return id > 0 ? id : 0;
  }

  int _trainerUserId(Trainers t) {
    final id = t.id ?? t.trainerId ?? 0;
    return id > 0 ? id : 0;
  }

  String _displayName(String? name, String? email, String prefix, int id) {
    final n = (name ?? "").trim();
    if (n.isNotEmpty) return n;
    final e = (email ?? "").trim();
    if (e.isNotEmpty) return e;
    return "$prefix #$id";
  }

  Map<String, dynamic> _row({
    required int userId,
    required String name,
    required String key,
  }) =>
      {
        "_key": key, // internal
        "user_id": userId,
        "name": name,
        "present": false,
        "checkIn": "", // HH:mm
        "checkOut": "", // HH:mm
        "notes": "", // optional
      };

  void togglePresent(int index, bool value) {
    attendanceList[index]["present"] = value;

    // if absent => clear times (clean)
    if (!value) {
      attendanceList[index]["checkIn"] = "";
      attendanceList[index]["checkOut"] = "";
    }
    attendanceList.refresh();
  }

  Future<void> pickTime(int index, bool isCheckIn) async {
    final picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;

    final hhmm = _toHHmm(picked);

    if (isCheckIn) {
      attendanceList[index]["checkIn"] = hhmm;

      // If checkout exists and is before checkin -> clear checkout
      final out = attendanceList[index]["checkOut"]?.toString() ?? "";
      if (out.isNotEmpty && _compareHHmm(out, hhmm) < 0) {
        attendanceList[index]["checkOut"] = "";
      }
    } else {
      final inTime = attendanceList[index]["checkIn"]?.toString() ?? "";
      if (inTime.isNotEmpty && _compareHHmm(hhmm, inTime) < 0) {
        _warn("Check-out cannot be before Check-in");
        return;
      }
      attendanceList[index]["checkOut"] = hhmm;
    }

    attendanceList.refresh();
  }

  /// ✅ REAL SAVE: POST /attendance per user
  Future<void> saveAttendance() async {
    if (attendanceList.isEmpty) {
      _warn("Nothing to save. Tap Apply first.");
      return;
    }
    if (!_isValidUiDate(dateController.text)) {
      _warn("Invalid date (DD-MM-YYYY)");
      return;
    }

    final token = await _getToken();
    if (token == null || token.trim().isEmpty) {
      _error("Token missing. Login again.");
      return;
    }

    // Convert date for API yyyy-MM-dd
    final apiDate = _uiDateToApiDate(dateController.text.trim());

    // Validate rows BEFORE hitting API
    for (int i = 0; i < attendanceList.length; i++) {
      final row = attendanceList[i];
      final present = row["present"] == true;
      if (!present) continue; // only save present rows

      final userId = row["user_id"];
      final checkIn = (row["checkIn"] ?? "").toString();
      final checkOut = (row["checkOut"] ?? "").toString();

      if (userId == null) {
        _warn("Row ${i + 1}: user_id missing");
        return;
      }
      if (checkIn.isEmpty) {
        _warn("Row ${i + 1}: Check-in required for Present");
        return;
      }
      if (checkOut.isNotEmpty && _compareHHmm(checkOut, checkIn) < 0) {
        _warn("Row ${i + 1}: Check-out must be after Check-in");
        return;
      }
    }

    if (isSaving.value) return;
    isSaving.value = true;

    int ok = 0;
    final failed = <String>[];

    try {
      // Send sequentially (safer than spamming API with Future.wait)
      for (int i = 0; i < attendanceList.length; i++) {
        final row = attendanceList[i];
        final present = row["present"] == true;
        if (!present) continue;

        final userId = row["user_id"] as int;
        final checkIn = (row["checkIn"] ?? "").toString();
        final checkOut = (row["checkOut"] ?? "").toString();
        final notes = (row["notes"] ?? "").toString().trim();

        final payload = {
          "user_id": userId,
          "date": apiDate,
          "checked_in_time": checkIn,
          "checked_out_time": checkOut.isEmpty ? null : checkOut,
          "notes": notes.isEmpty ? null : notes,
        };

        final resp = await http.post(
          Uri.parse(createAttendanceEndpoint),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "Authorization": "Bearer ${token.trim()}",
          },
          body: jsonEncode(payload),
        );

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          ok++;
        } else {
          failed.add("User $userId: ${resp.statusCode} ${_prettyApiError(resp.body)}");
        }
      }

      if (failed.isEmpty) {
        Get.snackbar(
          "Success",
          "Attendance saved ($ok records).",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.defaultDialog(
          title: "Partial Save",
          content: SingleChildScrollView(
            child: Text(
              "Saved: $ok\nFailed: ${failed.length}\n\n${failed.join("\n")}",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          confirm: ElevatedButton(onPressed: Get.back, child: const Text("OK")),
        );
      }
    } catch (e) {
      _error("Save failed: $e");
    } finally {
      isSaving.value = false;
    }
  }

  // ---------- helpers ----------
  bool _isValidUiDate(String v) {
    try {
      DateFormat('dd-MM-yyyy').parseStrict(v.trim());
      return true;
    } catch (_) {
      return false;
    }
  }

  DateTime? _parseUiDate(String v) {
    try {
      return DateFormat('dd-MM-yyyy').parseStrict(v.trim());
    } catch (_) {
      return null;
    }
  }

  String _uiDateToApiDate(String ui) {
    final d = DateFormat('dd-MM-yyyy').parseStrict(ui);
    return DateFormat('yyyy-MM-dd').format(d);
  }

  String _toHHmm(TimeOfDay t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  // returns -1 if a<b, 0 if equal, 1 if a>b
  int _compareHHmm(String a, String b) {
    final ap = a.split(":");
    final bp = b.split(":");
    if (ap.length != 2 || bp.length != 2) return 0;

    final ah = int.tryParse(ap[0]) ?? 0;
    final am = int.tryParse(ap[1]) ?? 0;
    final bh = int.tryParse(bp[0]) ?? 0;
    final bm = int.tryParse(bp[1]) ?? 0;

    final av = ah * 60 + am;
    final bv = bh * 60 + bm;

    if (av == bv) return 0;
    return av < bv ? -1 : 1;
  }

  String formatForUi(String hhmm) {
    if (hhmm.trim().isEmpty) return "--:--";
    final parts = hhmm.split(":");
    if (parts.length != 2) return hhmm;
    final h = int.tryParse(parts[0]) ?? 0;
    final m = int.tryParse(parts[1]) ?? 0;
    return TimeOfDay(hour: h, minute: m).format(Get.context!);
  }

  String _prettyApiError(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final msg = decoded["message"]?.toString();
        final errors = decoded["errors"];
        if (errors is Map) {
          final b = StringBuffer();
          if (msg != null) b.writeln(msg);
          errors.forEach((k, v) => b.writeln("$k: $v"));
          return b.toString();
        }
        return msg ?? decoded.toString();
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  void _warn(String msg) {
    Get.snackbar(
      "Alert",
      msg,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _error(String msg) {
    Get.snackbar(
      "Error",
      msg,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }
}
