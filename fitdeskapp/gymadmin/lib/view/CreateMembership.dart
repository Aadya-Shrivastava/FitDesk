import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gymadmin/controller/CreateMembershipcontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class MembershipAddView extends GetView<MembershipController> {
  const MembershipAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          "Create Membership",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              onPressed: () => Get.toNamed(RouteName.viewMembership),
              child: Text(
                "View Membership",
                style: TextStyle(
                  color: AppPalette.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
            physics: const BouncingScrollPhysics(),
            children: [
              _sectionLabel("Membership Details"),
              SizedBox(height: 10.h),
              _sectionCard(
                children: [
                  _buildTextField(
                    "Title",
                    controller.titleController,
                    Icons.title,
                    true,
                  ),
                  SizedBox(height: 16.h),

                  /// Package = duration of the membership
                  _buildDropdown(
                    label: "Package Duration",
                    value: controller.selectedPackage,
                    options: controller.packageOptions,
                  ),
                ],
              ),

              SizedBox(height: 22.h),
              _sectionLabel("Pricing"),
              SizedBox(height: 10.h),
              _sectionCard(
                children: [
                  /// Fee with a trainer & fee without a trainer, side by side
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFeeField(
                          caption: "With Trainer",
                          ctrl: controller.withTrainerFeeController,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildFeeField(
                          caption: "Without Trainer",
                          ctrl: controller.withoutTrainerFeeController,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    "Members can choose either option when they sign up.",
                    style: GoogleFonts.poppins(
                      fontSize: 11.5.sp,
                      color: AppPalette.textSecondary,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 22.h),
              _sectionLabel("Classes & Notes (optional)"),
              SizedBox(height: 10.h),
              _sectionCard(
                children: [
                  /// Classes selector (optional, multi select dialog)
                  Obx(() {
                    return InkWell(
                      onTap: () => _openClassesDialog(context, controller),
                      borderRadius: BorderRadius.circular(10.r),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Classes",
                          prefixIcon: const Icon(Icons.fitness_center,
                              color: AppPalette.primary),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                          filled: true,
                          fillColor: AppPalette.surface,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 14.h, horizontal: 12.w),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.selectedClassesLabel,
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (controller.isLoadingClasses.value)
                              SizedBox(
                                width: 18.w,
                                height: 18.w,
                                child: const CircularProgressIndicator(strokeWidth: 2),
                              )
                            else
                              const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: 16.h),

                  _buildTextField(
                    "Notes",
                    controller.notesController,
                    Icons.note_alt,
                    false,
                    maxLines: 3,
                  ),
                ],
              ),

              SizedBox(height: 28.h),

              /// Submit button
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : controller.submitForm,
                    icon: controller.isSubmitting.value
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
                      controller.isSubmitting.value ? "Creating..." : "Create Membership",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 3,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------- Fee field (caption above, "Fee" label inside) ---------------------
  Widget _buildFeeField({
    required String caption,
    required TextEditingController ctrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          style: GoogleFonts.poppins(
            fontSize: 12.5.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary,
          ),
        ),
        SizedBox(height: 6.h),
        _buildTextField(
          "Fee",
          ctrl,
          Icons.currency_rupee,
          true,
          type: TextInputType.number,
        ),
      ],
    );
  }

  // --------------------- Section helpers ---------------------
  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppPalette.textSecondary,
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _sectionCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // --------------------- TextField ---------------------
  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    bool required, {
    TextInputType type = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      validator: (v) =>
          required && (v == null || v.trim().isEmpty) ? "This field is required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
      ),
    );
  }

  // --------------------- Dropdown ---------------------
  Widget _buildDropdown({
    required String label,
    required RxString value,
    required List<String> options,
  }) {
    return Obx(
      () => DropdownButtonFormField<String>(
        value: value.value,
        items: options
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e == options.first ? e : e.replaceAll('_', ' ').toUpperCase()),
                ))
            .toList(),
        onChanged: (v) => value.value = v ?? options.first,
        validator: (v) =>
            (v == null || v == options.first) ? "Please select $label" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.list, color: AppPalette.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        ),
      ),
    );
  }

  // --------------------- Multi-Select Dialog ---------------------
  Future<void> _openClassesDialog(
    BuildContext context,
    MembershipController controller,
  ) async {
    if (controller.classesList.isEmpty && !controller.isLoadingClasses.value) {
      // try loading again if empty
      await controller.fetchClasses();
    }

    await showDialog(
      context: context,
      builder: (_) {
        return Obx(() {
          return AlertDialog(
            title: const Text("Select Classes"),
            content: SizedBox(
              width: double.maxFinite,
              child: controller.isLoadingClasses.value
                  ? const Center(child: CircularProgressIndicator())
                  : controller.classesList.isEmpty
                      ? const Text("No classes found.")
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: controller.classesList.length,
                          itemBuilder: (_, i) {
                            final item = controller.classesList[i];
                            return Obx(() {
                              final checked =
                                  controller.selectedClassIds.contains(item.id);
                              return CheckboxListTile(
                                value: checked,
                                title: Text(item.name),
                                onChanged: (_) =>
                                    controller.toggleClassSelection(item.id),
                                controlAffinity: ListTileControlAffinity.leading,
                              );
                            });
                          },
                        ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.selectedClassIds.clear();
                  controller.selectedClassIds.refresh();
                },
                child: const Text("Clear"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Done"),
              ),
            ],
          );
        });
      },
    );
  }
}
