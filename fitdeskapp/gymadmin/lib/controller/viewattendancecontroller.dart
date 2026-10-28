import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:gymadmin/Model/attendancemodel.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

class Viewattendancecontroller extends GetxController {
  final String endpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/attendance";

  final attendanceList = <Attendance>[].obs;
  final allAttendance = <Attendance>[].obs;
  final isLoading = false.obs;
  final errorMessage = "".obs;

  // Filters
  final selectedType = "Trainee".obs;
  final List<String> typeOptions = ["Trainee", "Trainer"];
  final dateController = TextEditingController();
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    fetchAttendance();
  }

  @override
  void onClose() {
    dateController.dispose();
    searchController.dispose();
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

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  Future<void> fetchAttendance() async {
    if (!_isValidUiDate(dateController.text)) {
      errorMessage.value = "Select valid date (DD-MM-YYYY)";
      return;
    }

    final token = await _getToken();
    if (token == null || token.trim().isEmpty) {
      errorMessage.value = "Token missing. Please login again.";
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      final type = selectedType.value.toLowerCase();
      final apiDate = _uiDateToApiDate(dateController.text.trim());

      final uri = Uri.parse(
        endpoint,
      ).replace(queryParameters: {"type": type, "date": apiDate});

      final resp = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        errorMessage.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = Attendancemodel.fromJson(decoded);
      allAttendance.assignAll(model.data?.attendance ?? <Attendance>[]);
      _applyLocalFilters();
    } catch (e) {
      errorMessage.value = "Failed to load attendance: $e";
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters() {
    fetchAttendance();
  }

  void applyLocalFilters() {
    _applyLocalFilters();
  }

  void _applyLocalFilters() {
    final q = searchController.text.trim().toLowerCase();
    final type = selectedType.value.trim().toLowerCase();

    final filtered = allAttendance.where((record) {
      final userType = (record.user?.type ?? "").toString().toLowerCase();
      final userName = (record.user?.name ?? "").toString().toLowerCase();

      final typeMatch = type.isEmpty
          ? true
          : userType == type || userType.contains(type);
      final searchMatch = q.isEmpty || userName.contains(q);

      return typeMatch && searchMatch;
    }).toList();

    attendanceList.assignAll(filtered);
  }

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

  String _prettyApiError(String body, int status) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final msg = decoded["message"]?.toString();
        final errors = decoded["errors"];
        if (errors is Map) {
          final b = StringBuffer();
          b.writeln(msg ?? "Request failed ($status)");
          errors.forEach((k, v) => b.writeln("$k: $v"));
          return b.toString();
        }
        return msg ?? decoded.toString();
      }
      return body;
    } catch (_) {
      return body.isNotEmpty ? body : "Request failed ($status)";
    }
  }

  void viewAttendance(Attendance record) {
    final user = record.user;
    final userName = user?.name ?? "-";
    final userType = user?.type ?? "-";
    final notes = (record.notes ?? "").toString();

    Get.defaultDialog(
      title: userName,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Type: $userType"),
          Text("Date: ${record.date ?? '-'}"),
          Text("Check-in: ${record.checkedInTime ?? '-'}"),
          Text("Check-out: ${record.checkedOutTime ?? '-'}"),
          Text("Notes: ${notes.isNotEmpty ? notes : 'N/A'}"),
        ],
      ),
      confirm: ElevatedButton(
        onPressed: () => Get.back(),
        child: const Text("Close"),
      ),
    );
  }

  void editAttendance(Attendance record) {
    final userName = record.user?.name ?? "-";
    Get.snackbar(
      "Edit",
      "Editing attendance for $userName",
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void deleteAttendance(int index) {
    attendanceList.removeAt(index);
    Get.snackbar(
      "Deleted",
      "Attendance record removed successfully",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
