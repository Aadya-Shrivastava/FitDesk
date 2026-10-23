// screens/admin_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/controller/splashscreencontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';

class SplashScreen extends GetView<Splashscreencontroller> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller (if not already)
    Get.put(Splashscreencontroller());

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                'FITDESK',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.secondary,
                  letterSpacing: 2.0,
                ),
              ),
              SizedBox(height: 10),

              // Subheading Text
              Text(
                'GYM MANAGEMENT SYSTEM',
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 4,
                  color: AppPalette.textSecondary,
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
