import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';

import 'package:gymadmin/Model/eventtypemodel.dart';

class EventTypeController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final eventTypeController = TextEditingController();

  final String endpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/event-types";

  // list
  final eventTypes = <EventTypes>[].obs;

  // states
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final isLoadingMore = false.obs;
  final error = ''.obs;

  // pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    fetchEventTypes(reset: true);
  }

  @override
  void onClose() {
    eventTypeController.dispose();
    super.onClose();
  }

  // ---------------- GET LIST ----------------
  Future<void> fetchEventTypes({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage.value = 1;
      lastPage.value = 1;
      eventTypes.clear();
      error.value = '';
    }

    isLoading.value = true;

    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        error.value = "Token missing. Please login again.";
        return;
      }

      final url = Uri.parse("$endpoint?page=${currentPage.value}");
      final resp = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      debugPrint("GET $url");
      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        error.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = eventtypemodel.fromJson(decoded);

      final list = model.data?.eventTypes ?? <EventTypes>[];
      final pagination = model.data?.pagination;

      if (pagination != null) {
        currentPage.value = pagination.currentPage ?? currentPage.value;
        lastPage.value = pagination.lastPage ?? lastPage.value;
      }

      eventTypes.addAll(list);
      error.value = '';
    } catch (e) {
      error.value = "Failed to load event types: $e";
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
      await fetchEventTypes(reset: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshList() async {
    await fetchEventTypes(reset: true);
  }

  // ---------------- POST CREATE ----------------
  Future<void> createEventType() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    final name = eventTypeController.text.trim();

    isSubmitting.value = true;
    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        _snackError("Token missing. Login again.");
        return;
      }

      final resp = await http.post(
        Uri.parse(endpoint),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
        body: jsonEncode({"name": name}), // ✅ API BODY
      );

      debugPrint("POST $endpoint");
      debugPrint("STATUS: ${resp.statusCode}");
      debugPrint("BODY: ${resp.body}");

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Event type created!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        eventTypeController.clear();

        // ✅ refresh list from server (don’t fake add)
        await fetchEventTypes(reset: true);
      } else {
        _snackError(_prettyApiError(resp.body, resp.statusCode));
      }
    } catch (e) {
      _snackError("Create failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  // ---------------- Helpers ----------------
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
