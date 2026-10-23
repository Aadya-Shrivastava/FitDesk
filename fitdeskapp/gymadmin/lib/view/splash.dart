// screens/admin_splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/controller/splashscreencontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class SplashScreen extends GetView<Splashscreencontroller> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller (if not already)
    final Splashscreencontroller controller = Get.put(Splashscreencontroller());

    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Center content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // FIITJEE Logo Text
                  Text(
                    'FITDESK',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppPalette.secondary,
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Subheading Text
                  const Text(
                    'GYM MANAGEMENT SYSTEM',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 4,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
