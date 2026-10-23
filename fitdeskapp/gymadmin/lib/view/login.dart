import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/logincontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class Login extends StatelessWidget {
  final Loginscreencontroller controller = Get.put(Loginscreencontroller());
  final RxBool isPasswordVisible = false.obs;

  Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              /// Curved background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, 250.h),
                  painter: CurvedPainter(),
                ),
              ),

              /// Main content
              Column(
                children: [
                  SizedBox(height: 160.h),

                  /// Login Box
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: AppPalette.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppPalette.border,
                            blurRadius: 10.r,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel('Email'),
                          _buildTextField(
                            controller.userNameController,
                            'Enter your registered Email-id',
                            Icons.phone,
                            keyboardType: TextInputType.emailAddress,
                          
                          ),
                          SizedBox(height: 20.h),

                          _buildLabel('Password'),
                          Obx(() => _buildTextField(
                                
                                controller.userPasswordController,
                                'Enter your password',
                                Icons.lock,
                                isObscure: true,
                                isPasswordVisible: isPasswordVisible,
                              )),
                          SizedBox(height: 10.h),

                          /// Remember Me + Forgot Password
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Obx(() => Row(
                                    children: [
                                      Checkbox(
                                        value: controller.rememberMe.value,
                                        onChanged: (val) =>
                                            controller.rememberMe.value =
                                                val ?? false,
                                        activeColor: Colors.green,
                                      ),
                                      const Text("Remember Me"),
                                    ],
                                  )),
                              TextButton(
                                onPressed: () {
                                  Get.snackbar(
                                    "Forgot Password",
                                    "Please contact admin to reset your password.",
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                                child: const Text(
                                  "Forgot Password?",
                                  style: TextStyle(
                                    color: AppPalette.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 25.h),

                          /// Sign In Button
                          Obx(() => controller.isLoading.value
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : _buildButton(
                                  label: "SIGN IN",
                                  color: AppPalette.primary,
                                  onTap: controller.loginUser,
                                )),
                          SizedBox(height: 25.h),

                          /// Just navigates to registration — not part of the
                          /// sign-in submission, so it must not react to
                          /// controller.isLoading.
                          _buildButton(
                            label: "Register Your Gym",
                            color: AppPalette.primary,
                            onTap: () => Get.toNamed(RouteName.register),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 40.h),

                  Text(
                    "© 2026 Apex Innovation",
                    style: TextStyle(
                      color: AppPalette.textSecondary,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return AutoSizeText(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.textPrimary,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    IconData icon, {
    bool isObscure = false,
    RxBool? isPasswordVisible,
    List<TextInputFormatter>? inputFormatters,
    TextInputType? keyboardType,
  }) {
    final obscure = isObscure ? isPasswordVisible?.value ?? true : false;
    return TextField(
      controller: controller,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: AppPalette.textSecondary),
        suffixIcon: isObscure
            ? IconButton(
                icon: Icon(
                  (isPasswordVisible?.value ?? false)
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: AppPalette.textSecondary,
                ),
                onPressed: () => isPasswordVisible?.toggle(),
              )
            : null,
        filled: true,
        fillColor: AppPalette.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class CurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // 60% black → 40% purple, matching the gym_header backgrounds.
      ..shader = AppPalette.headerGradient
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.90,
          size.width * 0.50, size.height * 0.80)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.70,
          size.width, size.height * 0.80)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
