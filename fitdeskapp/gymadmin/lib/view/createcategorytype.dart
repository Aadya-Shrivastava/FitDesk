import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gymadmin/controller/createcategorytype.dart';
import 'package:gymadmin/theme/app_palette.dart';

class CategorytypeAddView extends StatelessWidget {
  CategorytypeAddView({super.key});

  final CategorytypeController controller =
      Get.put(CategorytypeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: AppPalette.primary,
        title: Text(
          "Create Category",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.refreshList,
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// 🔹 CREATE FORM
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.border,
                      blurRadius: 6.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create Category",
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      TextFormField(
                        controller: controller.titleController,
                        validator: (value) => value == null || value.trim().isEmpty
                            ? "Please enter a title"
                            : null,
                        decoration: InputDecoration(
                          labelText: "Title",
                          hintText: "Enter category title",
                          prefixIcon: const Icon(
                            Icons.category_outlined,
                            color: AppPalette.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          filled: true,
                          fillColor: AppPalette.surface,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Obx(() {
                          return ElevatedButton.icon(
                            onPressed: controller.isCreating.value
                                ? null
                                : controller.createCategory,
                            icon: controller.isCreating.value
                                ? SizedBox(
                                    width: 18.w,
                                    height: 18.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.save, color: Colors.white),
                            label: Text(
                              controller.isCreating.value ? "Creating..." : "Create",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              padding: EdgeInsets.symmetric(
                                horizontal: 24.w,
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 25.h),

              /// 🔹 LIST
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppPalette.surface,
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.border,
                      blurRadius: 6.r,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Category List",
                      style: GoogleFonts.poppins(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppPalette.primary,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.categories.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (controller.error.value.isNotEmpty &&
                          controller.categories.isEmpty) {
                        return Column(
                          children: [
                            Text(
                              controller.error.value,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 12.h),
                            ElevatedButton(
                              onPressed: controller.refreshList,
                              child: const Text("Retry"),
                            ),
                          ],
                        );
                      }

                      if (controller.categories.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text("No categories available."),
                          ),
                        );
                      }

                      return NotificationListener<ScrollNotification>(
                        onNotification: (n) {
                          if (n.metrics.pixels >= n.metrics.maxScrollExtent - 50) {
                            controller.loadMore();
                          }
                          return false;
                        },
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.categories.length + 1,
                          separatorBuilder: (_, __) =>
                              const Divider(thickness: 0.8),
                          itemBuilder: (context, index) {
                            if (index == controller.categories.length) {
                              return Obx(() {
                                if (controller.isLoadingMore.value) {
                                  return const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              });
                            }

                            final c = controller.categories[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppPalette.primary,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                c.title ?? "-",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              // subtitle: Text(
                              //   "Created: ${c.createdAt ?? '-'}",
                              //   style: GoogleFonts.poppins(
                              //     fontSize: 12.sp,
                              //     color: AppPalette.textSecondary,
                              //   ),
                              // ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
