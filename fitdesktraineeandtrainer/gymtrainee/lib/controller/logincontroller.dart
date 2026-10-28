import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymtrainee/Model/loginmodel.dart';
import 'package:gymtrainee/widgets/localStorage/PrefConst.dart';
import 'package:gymtrainee/Model/json_utils.dart';
import 'package:gymtrainee/widgets/api_client.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';

import 'package:http/http.dart' as http;

class Loginscreencontroller extends GetxController {
  final box = GetStorage();

  RxBool isLoading = false.obs;
  RxBool rememberMe = false.obs;

  final TextEditingController userNameController = TextEditingController(); // email
  final TextEditingController userPasswordController = TextEditingController();

  Future<void> loginUser() async {
    final String username = userNameController.text.trim();
    final String password = userPasswordController.text;
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar("Missing details", "Please enter your email and password.");
      return;
    }

    isLoading.value = true;
    try {
      // Call your API here
      final uri = Uri.parse("${Api.base}/auth/login");
      final body = {'email': username, 'password': password};
      final watch = Stopwatch()..start();
      final response = await http.post(
        uri,
        body: json.encode(body),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 20));
      Api.logHttp('POST', uri, body: body, response: response, elapsed: watch.elapsed);

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final loginData = loginmodel.fromJson(asMap(decoded) ?? {});

        // The /trainee/* APIs return 403 Forbidden for any account that isn't
        // a trainee (admin/trainer), so refuse those here instead of letting
        // every screen fail after login.
        final userType = loginData.data?.user?.type?.toLowerCase();
        if (loginData.success == true &&
            userType != null &&
            !userType.contains('trainee') &&
            !userType.contains('member')) {
          Get.snackbar("Access denied",
              "This account is a '$userType' account. Please log in with a trainee/member account.");
          return;
        }

        if (loginData.success == true) {
          // Save token and all user details in local storage
          box.write(PrefConst.token, loginData.data?.token);
          box.write(PrefConst.userName, loginData.data?.user?.name);
          box.write(PrefConst.userEmail, loginData.data?.user?.email);
          box.write(PrefConst.userPhone, loginData.data?.user?.phoneNumber);
          box.write(PrefConst.userId, loginData.data?.user?.profile);
          box.write(PrefConst.userIsActive, true);
          // Trainee details (fitness goal, membership dates...) come nested
          // under data.user.trainee or data.trainee; keep the raw maps so the
          // profile/dashboard can show them without another API call.
          final rawData = asMap(asMap(decoded)?['data']) ?? {};
          final rawUser = asMap(rawData['user']) ?? {};
          final rawTrainee =
              asMap(rawUser['trainee']) ?? asMap(rawData['trainee']) ?? {};
          box.write(PrefConst.userJson, rawUser);
          box.write(PrefConst.traineeJson, rawTrainee);
          box.write(PrefConst.userType,
              asStr(rawTrainee['fitness_goal']) ?? loginData.data?.user?.trainee?.fitnessGoal);
          box.write(PrefConst.login, true);

          // Navigate to the dashboard or desired screen
          Get.offNamed(RouteName.dashboard);
        } else {
          // Handle login failure (e.g., show a Snackbar)
          Get.snackbar("Error", loginData.message ?? "Login failed.");
        }
      } else {
        String msg = response.statusCode == 401 || response.statusCode == 422
            ? "Invalid email or password."
            : "Login failed (HTTP ${response.statusCode}).";
        try {
          final m = json.decode(response.body);
          if (m is Map && m["message"] != null) msg = m["message"].toString();
        } catch (_) {}
        Get.snackbar("Login failed", msg);
        Api.report('Login.loginUser',
            'HTTP ${response.statusCode}: ${response.body}'); // DEBUG-LOG
      }
    } catch (e) {
      Get.snackbar("Login failed",
          "Could not reach the server. Check your internet and try again.");
      Api.report('Login.loginUser', e); // DEBUG-LOG
    } finally {
      isLoading.value = false;
    }
  }
}
