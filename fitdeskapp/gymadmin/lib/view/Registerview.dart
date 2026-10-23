import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/controller/registercontroller.dart' show RegisterController;
import 'package:gymadmin/theme/app_palette.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

  final controller = Get.put(RegisterController());

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Register"),
        backgroundColor:AppPalette.primary,
        foregroundColor: scheme.onPrimary,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _field("Name", controller.nameCtrl),
              _field("Email", controller.emailCtrl),
              _field("Phone", controller.phoneCtrl, limit: 10, type: TextInputType.phone),
              _field("Password", controller.passwordCtrl, obscure: true),
              _field("Confirm Password", controller.confirmPasswordCtrl, obscure: true),
              
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : controller.register,
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(
                          color: Colors.white,)
                      : const Text("Register",style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {bool obscure = false,
      TextInputType type = TextInputType.text,  int? limit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        maxLength: limit,
        controller: ctrl,
        obscureText: obscure,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
