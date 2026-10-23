import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/createworkoutcontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class WorkoutAddView extends StatelessWidget {
  WorkoutAddView({super.key});

  final WorkoutController controller =
      Get.put(WorkoutController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          "Create Workout",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppPalette.primary,
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: SizedBox(
              height: 40.h,
              width: 160.w,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(RouteName.viewworkout),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  "View Workouts",
                  style: TextStyle(fontSize: 15.sp, color: AppPalette.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Assign To
                Text("Assign To:",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 15.sp)),
                SizedBox(height: 6.h),
                Obx(() => Row(
                      children: [
                        Radio<String>(
                          value: "trainee",
                          groupValue: controller.assignType.value,
                          onChanged: (val) {
                            controller.assignType.value = val!;
                            controller.selectedClassId.value = null;
                          },
                          activeColor: AppPalette.primary,
                        ),
                        const Text("Member"),
                        SizedBox(width: 20.w),
                        Radio<String>(
                          value: "class",
                          groupValue: controller.assignType.value,
                          onChanged: (val) {
                            controller.assignType.value = val!;
                            controller.selectedTraineeId.value = null;
                          },
                          activeColor: AppPalette.primary,
                        ),
                        const Text("Class"),
                      ],
                    )),
                SizedBox(height: 10.h),

                /// Trainee / Class Dropdown (ID-based)
                Obx(() {
                  return controller.assignType.value == "trainee"
                      ? _buildAssignDropdown(
                          label: "Select Member",
                          value: controller.selectedTraineeId,
                          items: controller.traineeOptions,
                        )
                      : _buildAssignDropdown(
                          label: "Select Class",
                          value: controller.selectedClassId,
                          items: controller.classOptions,
                          isLoading: controller.isLoadingClasses.value,
                          errorText: controller.errorClasses.value,
                          onRetry: controller.fetchClasses,
                        );
                }),
                SizedBox(height: 16.h),

                /// Dates
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField(
                        "Start Date",
                        controller.startDateController,
                        onTap: () => controller.pickDate(
                          controller.startDateController,
                          isStart: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: _buildDateField(
                        "End Date",
                        controller.endDateController,
                        onTap: () => controller.pickDate(
                          controller.endDateController,
                          isStart: false,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                /// Notes
                _buildTextField(
                  "Notes",
                  controller.notesController,
                  Icons.note_alt_outlined,
                  false,
                  maxLines: 3,
                ),
                SizedBox(height: 20.h),

                /// Workout List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Workout Plan",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                        color: AppPalette.primary,
                      ),
                    ),
                    IconButton(
                      onPressed: controller.addWorkoutEntry,
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                /// Workout Entries
                Obx(() => Column(
                      children: List.generate(
                        controller.workouts.length,
                        (index) => _buildWorkoutRow(controller.workouts[index], index),
                      ),
                    )),

                SizedBox(height: 25.h),

                /// Submit
                Center(
                  child: Obx(() {
                    return ElevatedButton.icon(
                      onPressed: controller.isSubmitting.value
                          ? null
                          : controller.submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppPalette.primary,
                        padding: EdgeInsets.symmetric(
                            horizontal: 40.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
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
                        controller.isSubmitting.value ? "Creating..." : "Create",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15.sp,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- Builders ----------------

  Widget _buildAssignDropdown({
    required String label,
    required RxnInt value,
    required List<SimpleItem> items,
    bool isLoading = false,
    String errorText = '',
    VoidCallback? onRetry,
  }) {
    if (isLoading && items.isEmpty) {
      return _loadingField(label);
    }

    if (errorText.isNotEmpty && items.isEmpty) {
      return _errorField(label, errorText, onRetry);
    }

    return DropdownButtonFormField<int>(
      value: value.value,
      items: items
          .map((e) => DropdownMenuItem<int>(
                value: e.id,
                child: Text(e.title),
              ))
          .toList(),
      onChanged: (v) => value.value = v,
      validator: (v) => v == null ? "Please select $label" : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController ctrl,
      {required VoidCallback onTap}) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      validator: (v) => v == null || v.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
      onTap: onTap,
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon,
      bool required,
      {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        validator: (v) =>
            required && (v == null || v.isEmpty) ? "This field is required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppPalette.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
      ),
    );
  }

  Widget _buildWorkoutRow(Map<String, dynamic> item, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(
            color: AppPalette.border,
            blurRadius: 5.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Workout ${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => controller.removeWorkoutEntry(index),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          /// Day Dropdown
          DropdownButtonFormField<String>(
            value: item['day'],
            items: controller.days
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              item['day'] = v!;
              controller.workouts.refresh();
            },
            decoration: _inputDecoration("Day"),
          ),
          SizedBox(height: 12.h),

          /// Activity Dropdown (ID based, from API)
          Obx(() {
            if (controller.isLoadingActivities.value &&
                controller.activityOptions.isEmpty) {
              return _loadingField("Activity");
            }

            if (controller.errorActivities.value.isNotEmpty &&
                controller.activityOptions.isEmpty) {
              return _errorField(
                "Activity",
                controller.errorActivities.value,
                controller.fetchWorkoutActivities,
              );
            }

            return DropdownButtonFormField<int>(
              value: item['activity_id'],
              items: controller.activityOptions
                  .map((e) => DropdownMenuItem<int>(
                        value: e.id,
                        child: Text(e.title),
                      ))
                  .toList(),
              onChanged: (v) {
                item['activity_id'] = v;
                controller.workouts.refresh();
              },
              validator: (v) => v == null ? "Select Activity" : null,
              decoration: _inputDecoration("Activity"),
            );
          }),

          SizedBox(height: 12.h),
          _miniTextField("Weight (Kg)", item, 'weight'),
          SizedBox(height: 12.h),
          _miniTextField("Sets", item, 'sets'),
          SizedBox(height: 12.h),
          _miniTextField("Reps", item, 'reps'),
          SizedBox(height: 12.h),
          _miniTextField("Rest (sec)", item, 'rest'),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        filled: true,
        fillColor: AppPalette.surface,
      );

  Widget _miniTextField(String hint, Map<String, dynamic> item, String key) {
    return TextFormField(
      initialValue: (item[key] ?? '').toString(),
      keyboardType: TextInputType.number,
      onChanged: (v) {
        item[key] = v;
        controller.workouts.refresh();
      },
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        filled: true,
        fillColor: AppPalette.surface,
      ),
    );
  }

  Widget _loadingField(String label) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
      child: const SizedBox(
        height: 24,
        child: Align(
          alignment: Alignment.centerLeft,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _errorField(String label, String msg, VoidCallback? retry) {
    return InkWell(
      onTap: retry,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
        child: Text(
          "Failed: $msg (tap to retry)",
          style: const TextStyle(color: Colors.red),
        ),
      ),
    );
  }
}
