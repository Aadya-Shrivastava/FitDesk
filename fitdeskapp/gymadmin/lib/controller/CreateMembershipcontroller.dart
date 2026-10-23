import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:http/http.dart' as http;

/// Simple class item for dropdown/multi-select
class GymClassItem {
  final int id;
  final String name;

  GymClassItem({required this.id, required this.name});

  factory GymClassItem.fromJson(Map<String, dynamic> json) {
    return GymClassItem(
      id: (json['id'] is int) ? json['id'] : int.tryParse("${json['id']}") ?? 0,
      name: "${json['title'] ?? json['name'] ?? 'Class'}",
    );
  }
}

class MembershipController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Text controllers
  final titleController = TextEditingController();
  final withTrainerFeeController = TextEditingController();
  final withoutTrainerFeeController = TextEditingController();
  final notesController = TextEditingController();
var token = "".obs;
  // API endpoints
  final String membershipsEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/memberships";
  final String classesEndpoint =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/classes";

  // Loading states
  final isSubmitting = false.obs;
  final isLoadingClasses = false.obs;

  // Package dropdown
  // API expects "weekly/monthly/quarterly/half_yearly/yearly" (lowercase,
  // snake_case — every other multi-word field/value in this API uses
  // underscores, e.g. phone_number, zip_code, with_trainer_fee).
  final List<String> packageOptions = const [
    'Select Package',
    'weekly',
    'monthly',
    'quarterly',
    'half_yearly',
    'yearly',
  ];
  final selectedPackage = 'Select Package'.obs;

  // Classes from API
  final classesList = <GymClassItem>[].obs;
  final selectedClassIds = <int>[].obs;

  // ------------------ LIFECYCLE ------------------
  @override
  void onInit() {
    super.onInit();
    fetchClasses();
  }

  @override
  void onClose() {
    titleController.dispose();
    withTrainerFeeController.dispose();
    withoutTrainerFeeController.dispose();
    notesController.dispose();
    super.onClose();
  }

  // ------------------ TOKEN ------------------
  /// Replace this with your real token getter (SharedPreferences/SecureStorage/etc.)
  Future<String?> getToken() async {
    // TODO: implement your token read.
    // Example:
    // final prefs = await SharedPreferences.getInstance();
    token.value = await PrefManager().readValue(key: PrefConst.token);
    // return prefs.getString("token");
    return token.value;
  }

  // ------------------ API: FETCH CLASSES ------------------
  Future<void> fetchClasses() async {
    isLoadingClasses.value = true;
    try {
      final token = await getToken();

      final resp = await http.get(
        Uri.parse(classesEndpoint),
        headers: {
          "Accept": "application/json",
          if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
        },
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final decoded = jsonDecode(resp.body);

        // Your backend may return:
        // { "data": { "classes": [ ... ] } }
        // or { "data": [ ... ] }
        // or { "classes": [ ... ] }
        List<dynamic> rawList = [];

        if (decoded is Map<String, dynamic>) {
          final data = decoded["data"];
          if (data is Map<String, dynamic> && data["classes"] is List) {
            rawList = data["classes"];
          } else if (data is List) {
            rawList = data;
          } else if (decoded["classes"] is List) {
            rawList = decoded["classes"];
          }
        }

        final parsed = rawList
            .whereType<Map>()
            .map((e) => GymClassItem.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => e.id != 0)
            .toList();

        classesList.assignAll(parsed);
      } else {
        _showError("Failed to load classes (${resp.statusCode}).\n${resp.body}");
      }
    } catch (e) {
      _showError("Failed to load classes: $e");
    } finally {
      isLoadingClasses.value = false;
    }
  }

  // ------------------ API: CREATE MEMBERSHIP ------------------
  Future<void> submitForm() async {
    if (!formKey.currentState!.validate()) return;

    if (selectedPackage.value == packageOptions.first) {
      _showError("Please select a package.");
      return;
    }

    final withTrainerFee = int.tryParse(withTrainerFeeController.text.trim());
    if (withTrainerFee == null || withTrainerFee <= 0) {
      _showError("Fee with trainer must be a valid number > 0.");
      return;
    }

    final withoutTrainerFee = int.tryParse(withoutTrainerFeeController.text.trim());
    if (withoutTrainerFee == null || withoutTrainerFee <= 0) {
      _showError("Fee without trainer must be a valid number > 0.");
      return;
    }

    isSubmitting.value = true;

    try {
      final token = await getToken();

      final payload = {
        "title": titleController.text.trim(),
        "package": selectedPackage.value.trim(), // e.g. "monthly"
        "amount": withTrainerFee, // kept for backward compatibility
        "with_trainer_fee": withTrainerFee,
        "without_trainer_fee": withoutTrainerFee,
        if (selectedClassIds.isNotEmpty) "class_ids": selectedClassIds.join(","), // "1,2,3"
        "notes": notesController.text.trim(),
      };

      final resp = await http
          .post(
            Uri.parse(membershipsEndpoint),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
            },
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        Get.snackbar(
          "Success",
          "Membership created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        clearForm();
      } else {
        _showApiError(resp.statusCode, resp.body);
      }
    } catch (e) {
      _showError("Create failed: $e");
    } finally {
      isSubmitting.value = false;
    }
  }

  // Shows the backend's full validation response in a dialog (not just a
  // snackbar) so a 422 like "the selected package is invalid" is fully
  // readable instead of getting cut off.
  void _showApiError(int statusCode, String body) {
    String pretty = body;
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded["message"]?.toString();
        final errors = decoded["errors"];
        final b = StringBuffer();
        if (message != null) b.writeln(message);
        if (errors is Map) {
          errors.forEach((k, v) => b.writeln("$k: $v"));
        }
        if (b.isNotEmpty) pretty = b.toString();
      }
    } catch (_) {
      // Not JSON — fall back to the raw body.
    }

    Get.defaultDialog(
      title: "Create Failed ($statusCode)",
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(pretty, style: const TextStyle(fontSize: 13)),
        ),
      ),
      confirm: ElevatedButton(onPressed: Get.back, child: const Text("OK")),
    );
  }

  // ------------------ UI HELPERS ------------------
  void toggleClassSelection(int classId) {
    if (selectedClassIds.contains(classId)) {
      selectedClassIds.remove(classId);
    } else {
      selectedClassIds.add(classId);
    }
    selectedClassIds.refresh();
  }

  String get selectedClassesLabel {
    if (selectedClassIds.isEmpty) return "Select Classes";
    final names = classesList
        .where((c) => selectedClassIds.contains(c.id))
        .map((c) => c.name)
        .toList();
    if (names.isEmpty) return "Select Classes";
    if (names.length <= 2) return names.join(", ");
    return "${names.take(2).join(", ")} +${names.length - 2}";
  }

  void clearForm() {
    titleController.clear();
    withTrainerFeeController.clear();
    withoutTrainerFeeController.clear();
    notesController.clear();
    selectedPackage.value = packageOptions.first;
    selectedClassIds.clear();
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
