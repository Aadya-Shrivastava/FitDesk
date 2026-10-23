import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:http/http.dart' as http;

class RegisterController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = "".obs;
  final canSubmit = false.obs;

  // Text Controllers
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // API URL for Gym Owner Registration
  final String registerUrl =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/create";

  @override
  void onInit() {
    super.onInit();
    nameCtrl.addListener(_recomputeFormValid);
    emailCtrl.addListener(_recomputeFormValid);
    phoneCtrl.addListener(_recomputeFormValid);
    passwordCtrl.addListener(_recomputeFormValid);
    confirmPasswordCtrl.addListener(_recomputeFormValid);
    _recomputeFormValid();
  }



  bool _isValidEmail(String value) {
    final email = value.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  String _digitsOnly(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  bool validateForm({bool showSnackBar = false}) {
    final name = nameCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final phone = _digitsOnly(phoneCtrl.text);
    final password = passwordCtrl.text.trim();
    final confirmPassword = confirmPasswordCtrl.text.trim();

    String? error;

    if (name.isEmpty) {
      error = "Name is required";
    } else if (email.isEmpty || !_isValidEmail(email)) {
      error = "Enter a valid email";
    } else if (phone.isEmpty || phone.length < 10) {
      error = "Enter a valid phone number";
    } else if (password.isEmpty || password.length < 6) {
      error = "Password must be at least 6 characters";
    } else if (confirmPassword.isEmpty) {
      error = "Confirm your password";
    } else if (password != confirmPassword) {
      error = "Passwords do not match";
    }

    if (error != null) {
      errorMessage.value = error;
      if (showSnackBar) {
        Get.snackbar(
          "Validation",
          error,
          snackPosition: SnackPosition.TOP,
        );
      }
      return false;
    }

    errorMessage.value = "";
    return true;
  }

  void _recomputeFormValid() {
    canSubmit.value = validateForm();
  }

  Future<void> register() async {
    if (!validateForm(showSnackBar: true)) {
      return;
    }

    isLoading.value = true;

    try {
      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "name": nameCtrl.text.trim(),
          "email": emailCtrl.text.trim(),
          "password": passwordCtrl.text.trim(),
          "password_confirmation": confirmPasswordCtrl.text.trim(),
          "phone_number": phoneCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar(
          "Success",
          "Registration completed",
          snackPosition: SnackPosition.BOTTOM,
        );

        // 👉 Navigate to Login
        Get.offAllNamed(RouteName.signin);
      } else {
        errorMessage.value = data["message"] ?? "Registration failed";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
