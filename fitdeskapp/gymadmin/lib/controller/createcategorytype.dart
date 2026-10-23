import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:http/http.dart' as http;

import '../Model/categoriesmodel.dart';
import '../widgets/localStorage/PrefConst.dart';

class CategorytypeController extends GetxController {
  // endpoints
  final String listEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/categories";
  final String createEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/categories";

  // form
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();

  // state
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isCreating = false.obs;
  final error = ''.obs;

  // data
  final categories = <Categories>[].obs;

  // pagination
  final currentPage = 1.obs;
  final lastPage = 1.obs;
  final total = 0.obs;

  Future<String?> getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    fetchCategories(reset: true);
  }

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  // ---------------- GET ----------------
  Future<void> fetchCategories({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      currentPage.value = 1;
      lastPage.value = 1;
      total.value = 0;
      categories.clear();
      error.value = '';
    }

    isLoading.value = true;
    error.value = '';

    try {
      final token = await getToken();
      final uri = Uri.parse(listEndpoint).replace(queryParameters: {
        "page": "${currentPage.value}",
      });

      final resp = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
        final model = categoriesmodel.fromJson(decoded);

        final list = model.data?.categories ?? <Categories>[];
        final pag = model.data?.pagination;

        if (reset) {
          categories.assignAll(list);
        } else {
          categories.addAll(list);
        }

        currentPage.value = pag?.currentPage ?? currentPage.value;
        lastPage.value = pag?.lastPage ?? 1;
        total.value = pag?.total ?? categories.length;
      } else {
        error.value = _extractError(resp);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshList() async {
    await fetchCategories(reset: true);
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (currentPage.value >= lastPage.value) return;

    isLoadingMore.value = true;
    try {
      currentPage.value = currentPage.value + 1;
      await fetchCategories(reset: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ---------------- POST ----------------
  Future<void> createCategory() async {
    if (!formKey.currentState!.validate()) return;

    final title = titleController.text.trim();
    if (title.isEmpty) return;

    isCreating.value = true;

    try {
      final token = await getToken();

      final resp = await http.post(
        Uri.parse(createEndpoint),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
        body: jsonEncode({"title": title}),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Category created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        titleController.clear();

        // safest (backend might sort/paginate): refresh from server
        await refreshList();
      } else {
        _showError("Create failed (${resp.statusCode}).\n${resp.body}");
      }
    } catch (e) {
      _showError("Create failed: $e");
    } finally {
      isCreating.value = false;
    }
  }

  // ---------------- Helpers ----------------
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
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
