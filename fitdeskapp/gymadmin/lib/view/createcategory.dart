import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/createcategorycontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class CategoryAddView extends StatelessWidget {
  final CategoryController controller = Get.put(CategoryController());

  CategoryAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Center(
        child: Container(
          width: 500.w,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppPalette.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppPalette.border,
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: controller.formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Title
                Text(
                  "Create Category",
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppPalette.primary,
                  ),
                ),
                SizedBox(height: 20.h),

                /// Input Field
                TextFormField(
                  controller: controller.titleController,
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Please enter a title"
                      : null,
                  decoration: InputDecoration(
                    labelText: "Title",
                    hintText: "Enter title",
                    prefixIcon:
                        const Icon(Icons.category_outlined, color: AppPalette.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    filled: true,
                    fillColor: AppPalette.surface,
                  ),
                ),
                SizedBox(height: 30.h),

                /// Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.createCategory,
                      icon: const Icon(Icons.save, color: Colors.white),
                      label: Text(
                        "Create",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        padding: EdgeInsets.symmetric(
                            horizontal: 28.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
