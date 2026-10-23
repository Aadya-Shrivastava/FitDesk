import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/Addeventcontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class EventAddView extends StatelessWidget {
  final EventController controller = Get.put(EventController(), permanent: true);

  EventAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: AppPalette.primary,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          "Create Event",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          // IconButton(
          //   tooltip: "Refresh Event Types",
          //   onPressed: controller.fetchEventTypes,
          //   icon: const Icon(Icons.refresh, color: Colors.white),
          // ),
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: SizedBox(
              height: 40.h,
              width: 150.w,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(RouteName.viewevent),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text("View Events", style: TextStyle(fontSize: 14.sp, color: AppPalette.primary)),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final submitting = controller.isSubmitting.value;

        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Form(
                key: controller.formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Type (API)
                      _eventTypeDropdown(),
                      SizedBox(height: 16.h),

                      // Title
                      _buildTextField(
                        "Event Name *",
                        controller.titleController,
                        Icons.event,
                        required: true,
                      ),
                      SizedBox(height: 16.h),

                      // Dates (yyyy-MM-dd)
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              "Start Date *",
                              controller.startDateController,
                              onTap: () => controller.pickDate(
                                controller.startDateController,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildDateField(
                              "End Date *",
                              controller.endDateController,
                              onTap: () => controller.pickDate(
                                controller.endDateController,
                                firstDate: DateTime(2020),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Description
                      _buildTextField(
                        "Description",
                        controller.descriptionController,
                        Icons.description_outlined,
                        required: false,
                        maxLines: 3,
                      ),
                      SizedBox(height: 16.h),

                      // Status (int)
                      _statusDropdown(),
                      SizedBox(height: 30.h),

                      Center(
                        child: SizedBox(
                          width: 220.w,
                          child: ElevatedButton.icon(
                            onPressed: submitting ? null : controller.submitForm,
                            icon: submitting
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
                              submitting ? "Creating..." : "Create Event",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 10.h),
                      Text(
                        "Note: Dates must be yyyy-MM-dd (API format).",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: AppPalette.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // overlay
            if (submitting)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                ),
              ),
          ],
        );
      }),
    );
  }

  // ---------------- Widgets ----------------

  Widget _eventTypeDropdown() {
    return Obx(() {
      final loading = controller.isLoadingTypes.value;
      final err = controller.typesError.value.trim();
      final list = controller.eventTypes;

      if (loading && list.isEmpty) {
        return _loadingField("Event Type *");
      }

      if (err.isNotEmpty && list.isEmpty) {
        return _errorField("Event Type *", err, controller.fetchEventTypes);
      }

      return DropdownButtonFormField<int>(
        value: controller.selectedEventTypeId.value,
        items: list.map((e) {
          final title = (e.name ?? "").trim().isEmpty
              ? "EventType #${e.id ?? '-'}"
              : e.name!.trim();
          return DropdownMenuItem<int>(
            value: e.id,
            child: Text(title),
          );
        }).toList(),
        onChanged: (v) => controller.selectedEventTypeId.value = v,
        validator: (v) => v == null ? "Please select Event Type" : null,
        decoration: InputDecoration(
          labelText: "Event Type *",
          prefixIcon: const Icon(Icons.category, color: AppPalette.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
      );
    });
  }
Widget _statusDropdown() {
  return Obx(() {
    final options = controller.statusOptions;

    return DropdownButtonFormField<int>(
      value: controller.selectedStatusCode.value,
      items: options.entries
          .map((e) => DropdownMenuItem<int>(
                value: e.key,
                child: Text(e.value),
              ))
          .toList(),
      onChanged: (v) => controller.selectedStatusCode.value = v ?? 1,
      validator: (v) => v == null ? "Please select Status" : null,
      decoration: InputDecoration(
        labelText: "Status *",
        prefixIcon: const Icon(Icons.timeline, color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
    );
  });
}

  Widget _buildTextField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    required bool required,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      validator: (v) =>
          required && (v == null || v.trim().isEmpty) ? "This field is required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
    );
  }

  Widget _buildDateField(
    String label,
    TextEditingController ctrl, {
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: ctrl,
      readOnly: true,
      validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today, color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
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
}
