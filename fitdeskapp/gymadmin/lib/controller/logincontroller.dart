import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymadmin/Model/loginmodel.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:http/http.dart' as http;

// ✅ import your model file
// import 'package:gymadmin/models/loginmodel.dart';

class Loginscreencontroller extends GetxController {
  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxBool rememberMe = false.obs;

  final TextEditingController userNameController = TextEditingController(); // email
  final TextEditingController userPasswordController = TextEditingController();

  static const String _loginUrl =
      "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/login";

  @override
  void onInit() {
    super.onInit();

    final saved = box.read('rememberMe') ?? false;
    if (saved == true) {
      userNameController.text = box.read('email') ?? '';
      userPasswordController.text = box.read('password') ?? '';
      rememberMe.value = true;
    }
  }

  void toggleRememberMe(bool value) => rememberMe.value = value;

  Future<void> loginUser() async {
    final email = userNameController.text.trim();
    final password = userPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Please fill in both fields.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final res = await http.post(
        Uri.parse(_loginUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (res.body.isEmpty) {
        Get.snackbar(
          "Error",
          "Empty response from server.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final Map<String, dynamic> decoded = jsonDecode(res.body);


      // ✅ Use your model
      final login = loginmodel.fromJson(decoded);

      if ((res.statusCode == 200 || res.statusCode == 201) &&
          login.success == true) {
        // ✅ Remember Me save/clear
        if (rememberMe.value) {
          await box.write('rememberMe', true);
          await box.write('email', email);
          await box.write('password', password);
        } else {
          await box.remove('rememberMe');
          await box.remove('email');
          await box.remove('password');
        }

        // ✅ Save token
        final token = login.data?.token;
        if (token != null && token.isNotEmpty) {
          await PrefManager().writeValue(key: PrefConst.token, value: token);
        }

        // ✅ Save user details (adjust PrefConst keys to yours)
        final user = login.data?.user;
        if (user != null) {
          await PrefManager()
              .writeValue(key: PrefConst.userId, value: user.id?.toString() ?? "");
               await PrefManager()
              .writeValue(key: PrefConst.login, value: true);
          await PrefManager()
              .writeValue(key: PrefConst.userName, value: user.name ?? "");
          await PrefManager()
              .writeValue(key: PrefConst.userEmail, value: user.email ?? "");
          await PrefManager()
              .writeValue(key: PrefConst.userPhone, value: user.phoneNumber ?? "");
          await PrefManager()
              .writeValue(key: PrefConst.userType, value: user.type ?? "");
          await PrefManager().writeValue(
              key: PrefConst.userIsActive, value: user.isActive?.toString() ?? "");
        }

        // ✅ (Optional) save subscription/business stats if you need them later
        // final stats = login.data?.businessStats;

        Get.offAllNamed(RouteName.dashboard);
      } else {
        Get.snackbar(
          "Login Failed",
          login.message ?? "Invalid credentials.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }


}
