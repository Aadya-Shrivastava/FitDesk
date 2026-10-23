import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/CreateClassController.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class ClassAddView extends StatelessWidget {
  ClassAddView({super.key});

  final ClassController controller = Get.isRegistered<ClassController>()
      ? Get.find<ClassController>()
      : Get.put(ClassController(), permanent: true);

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
          "Create Class",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppPalette.primary,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: SizedBox(
              height: 40.h,
              width: 160.w,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(RouteName.viewclass),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  "View Classes",
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
          child: ListView(
            children: [
              _buildRow(
                _buildTextField("Title", controller.titleController, true),
                _buildTextField("Fees", controller.feeController, true,
                    type: TextInputType.number),
              ),

              // ✅ Trainer + Trainee MULTI SELECT
              _buildRow(
                _buildTrainerDropdown(),
                _buildTraineeMultiSelect(context),
              ),

              _buildRow(
                _buildTextField("Address", controller.addressController, true, maxLines: 2),
                _buildTextField("Notes", controller.notesController, false, maxLines: 2),
              ),

              SizedBox(height: 20.h),
              Text(
                "Class Schedule",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: AppPalette.primary,
                ),
              ),
              SizedBox(height: 10.h),

              _buildScheduleSection(context),

              SizedBox(height: 20.h),
              Obx(() {
                return ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value ? null : controller.submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: controller.isSubmitting.value
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    controller.isSubmitting.value ? "Creating..." : "Create",
                    style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Layout helpers ----------------
  Widget _buildRow(Widget left, Widget right) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Expanded(child: left),
          SizedBox(width: 8.w),
          Expanded(child: right),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, bool required,
      {TextInputType type = TextInputType.text, int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: type,
      maxLines: maxLines,
      validator: (v) => required && (v == null || v.trim().isEmpty)
          ? "This field is required"
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
    );
  }

  // ✅ Trainer dropdown from API (NULL SAFE)
  Widget _buildTrainerDropdown() {
    return Obx(() {
      final trainerCtrl = controller.trainerCtrl;

      if (trainerCtrl.isLoading.value && trainerCtrl.trainers.isEmpty) {
        return _loadingField("Trainer");
      }

      if (trainerCtrl.error.value.isNotEmpty && trainerCtrl.trainers.isEmpty) {
        return _errorField("Trainer", trainerCtrl.error.value, () {
          trainerCtrl.fetchTrainers(page: 1);
        });
      }

      final items = trainerCtrl.trainers.where((t) => (t.id ?? 0) > 0).toList();

      // ✅ prevent "String is not subtype of Null" by ensuring value exists in items
      final selected = controller.selectedTrainerId.value;
      final validSelected = items.any((t) => t.id == selected) ? selected : null;

      return DropdownButtonFormField<int>(
        value: validSelected,
        items: items
            .map((t) => DropdownMenuItem<int>(
                  value: t.id!,
                  child: Text((t.name ?? "").trim().isNotEmpty ? t.name! : "Trainer #${t.id}"),
                ))
            .toList(),
        onChanged: (v) => controller.selectedTrainerId.value = v,
     
        decoration: InputDecoration(
          labelText: "Trainer",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
      );
    });
  }

  // ✅ Trainee MULTI SELECT (API)
  Widget _buildTraineeMultiSelect(BuildContext context) {
    return Obx(() {
      final tCtrl = controller.traineeCtrl;

      if (tCtrl.isLoading.value && tCtrl.trainees.isEmpty) {
        return _loadingField("Members");
      }

      if (tCtrl.errorMessage.value.isNotEmpty && tCtrl.trainees.isEmpty) {
        return _errorField("Members", tCtrl.errorMessage.value, () {
          tCtrl.fetchTrainees(reset: true);
        });
      }

      final items = tCtrl.trainees.where((x) => (x.id ?? 0) > 0).toList();

      final selectedNames = items
          .where((x) => controller.selectedTraineeIds.contains(x.id))
          .map((x) => (x.name ?? "Members #${x.id}").toString())
          .toList();

      final displayText = selectedNames.isEmpty
          ? "Select Members"
          : selectedNames.join(", ");

      return InkWell(
        onTap: () => _openTraineePickerBottomSheet(context, items),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: "Members",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            filled: true,
            fillColor: AppPalette.surface,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  displayText,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      );
    });
  }

  void _openTraineePickerBottomSheet(BuildContext context, List items) {
    final search = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.72,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Select members",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: controller.clearSelectedTrainees,
                      child: const Text("Clear"),
                    ),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Done"),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                TextField(
                  controller: search,
                  decoration: InputDecoration(
                    hintText: "Search member...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Obx(() {
                    final q = search.text.trim().toLowerCase();
                    final selectedIds = controller.selectedTraineeIds.toList();

                    final filtered = items.where((t) {
                      final name = (t.name ?? "").toString().toLowerCase();
                      final email = (t.email ?? "").toString().toLowerCase();
                      return q.isEmpty || name.contains(q) || email.contains(q);
                    }).toList();

                    return ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (_, i) {
                        final t = filtered[i];
                        final id = t.id as int;

                        final title = (t.name ?? "Member #$id").toString();
                        final subtitle = (t.email ?? "").toString();

                        final checked = selectedIds.contains(id);

                        return CheckboxListTile(
                          value: checked,
                          onChanged: (_) => controller.toggleTrainee(id),
                          title: Text(title),
                          subtitle: subtitle.trim().isEmpty ? null : Text(subtitle),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        },
      ),
      isScrollControlled: true,
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

  Widget _errorField(String label, String msg, VoidCallback retry) {
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

  // ---------------- Schedule section ----------------
  Widget _buildScheduleSection(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: controller.selectedDay.value,
                  items: const [
                    "Sunday",
                    "Monday",
                    "Tuesday",
                    "Wednesday",
                    "Thursday",
                    "Friday",
                    "Saturday"
                  ]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => controller.selectedDay.value = v ?? "Sunday",
                  decoration: InputDecoration(
                    labelText: "Days",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    filled: true,
                    fillColor: AppPalette.surface,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              IconButton(
                onPressed: controller.addSchedule,
                icon: const Icon(Icons.add_circle, color: Colors.green),
                tooltip: "Add Schedule",
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...controller.scheduleList.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;

            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppPalette.border),
                borderRadius: BorderRadius.circular(10.r),
                color: AppPalette.surface,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.day,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppPalette.textPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => controller.removeSchedule(i),
                        tooltip: "Remove",
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _timeField(
                          caption: "Start Time",
                          value: item.startTime,
                          icon: Icons.access_time,
                          onTap: () => controller.selectTime(context, i, true),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: _timeField(
                          caption: "End Time",
                          value: item.endTime,
                          icon: Icons.timer_off_outlined,
                          onTap: () => controller.selectTime(context, i, false),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _timeField({
    required String caption,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isEmpty = value == "--:--";
    return Padding(
      padding: EdgeInsets.only(top: 10.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppPalette.border),
            borderRadius: BorderRadius.circular(8.r),
            color: AppPalette.background,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  color: AppPalette.textSecondary,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(icon, color: AppPalette.secondary, size: 16.sp),
                  SizedBox(width: 6.w),
                  Text(
                    isEmpty ? "Select time" : value,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isEmpty ? AppPalette.textSecondary : AppPalette.textPrimary,
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
}
