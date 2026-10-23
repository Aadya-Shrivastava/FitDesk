import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

// Use the same model you already created for event types:
import 'package:gymadmin/Model/eventtypemodel.dart' as et;

class EventController extends GetxController {
  // APIs
  final String eventsEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/events";
  final String eventTypesEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/event-types";

  // Form
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final startDateController = TextEditingController(); // yyyy-MM-dd
  final endDateController = TextEditingController();   // yyyy-MM-dd

  // Dropdown data (Event Types from API)
  final isLoadingTypes = false.obs;
  final typesError = ''.obs;
  final eventTypes = <et.EventTypes>[].obs;
  final selectedEventTypeId = RxnInt(); // ✅ API needs int

  // Status (API needs int)
  // You gave status: 1. We'll use 1=Active/Upcoming and 0=Inactive/Cancelled.
  final selectedStatus = 1.obs;

  // Submit
  final isSubmitting = false.obs;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    fetchEventTypes();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    startDateController.dispose();
    endDateController.dispose();
    super.onClose();
  }

  // -------------------- FETCH EVENT TYPES --------------------
  Future<void> fetchEventTypes() async {
    if (isLoadingTypes.value) return;

    isLoadingTypes.value = true;
    typesError.value = '';
    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        typesError.value = "Token missing. Please login again.";
        return;
      }

      final resp = await http.get(
        Uri.parse("$eventTypesEndpoint?page=1"),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      debugPrint("GET $eventTypesEndpoint");
      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        typesError.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = et.eventtypemodel.fromJson(decoded);
      final list = model.data?.eventTypes ?? <et.EventTypes>[];

      eventTypes.assignAll(list);

      // auto-select first if none selected
      if (selectedEventTypeId.value == null && list.isNotEmpty) {
        selectedEventTypeId.value = list.first.id;
      }
    } catch (e) {
      typesError.value = "Failed to load event types: $e";
    } finally {
      isLoadingTypes.value = false;
    }
  }

  // -------------------- DATE PICKER --------------------
  Future<void> pickDate(TextEditingController ctrl, {DateTime? firstDate}) async {
    final now = DateTime.now();

    // if controller already has a date, use it
    DateTime initial = now;
    try {
      if (ctrl.text.trim().isNotEmpty) {
        initial = DateFormat('yyyy-MM-dd').parseStrict(ctrl.text.trim());
      }
    } catch (_) {}

    final picked = await showDatePicker(
      context: Get.context!,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      ctrl.text = DateFormat('yyyy-MM-dd').format(picked); // ✅ API format
    }
  }

  // -------------------- SUBMIT --------------------
  Future<void> submitForm() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    // event type id required
    if (selectedEventTypeId.value == null) {
      _snackError("Please select Event Type.");
      return;
    }

    // date sanity: end >= start
    final startText = startDateController.text.trim();
    final endText = endDateController.text.trim();
    DateTime start, end;
    try {
      start = DateFormat('yyyy-MM-dd').parseStrict(startText);
      end = DateFormat('yyyy-MM-dd').parseStrict(endText);
    } catch (_) {
      _snackError("Invalid date format. Use yyyy-MM-dd.");
      return;
    }

    if (end.isBefore(start)) {
      _snackError("End date cannot be before start date.");
      return;
    }

    isSubmitting.value = true;
    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        _snackError("Token missing. Login again.");
        return;
      }

      final payload = {
        "title": titleController.text.trim(),
        "start_date": startText,
        "end_date": endText,
        "description": descriptionController.text.trim(),
        "event_type_id": selectedEventTypeId.value,
        "status": selectedStatus.value, // ✅ int
      };

      final resp = await http.post(
        Uri.parse(eventsEndpoint),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
        body: jsonEncode(payload),
      );

      debugPrint("POST $eventsEndpoint");
      debugPrint("PAYLOAD: ${jsonEncode(payload)}");
      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Event created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      } else {
        _snackError(_prettyApiError(resp.body, resp.statusCode));
      }
    } catch (e) {
      _snackError("Create failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
    startDateController.clear();
    endDateController.clear();
    // keep selected type + status (or reset if you want)
    selectedStatus.value = 1;
  }
// Status (API needs int)
final statusOptions = <int, String>{
  1: "Upcoming",
  2: "Running",
  3: "Completed",
  4: "Cancelled",
}.obs;

final selectedStatusCode = 1.obs; // default Upcoming

  // -------------------- Helpers --------------------
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

  void _snackError(String msg) {
    Get.snackbar(
      "Error",
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }
}
