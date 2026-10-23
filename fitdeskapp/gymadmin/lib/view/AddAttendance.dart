import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/AddAttendancecontroller.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class AttendanceView extends StatelessWidget {
  final AttendanceController controller = Get.put(AttendanceController());

  AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        backgroundColor: AppPalette.primary,
        centerTitle: true,
        title: Text(
          "Bulk Attendance",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.w),
            child: SizedBox(
              height: 40.h,
              width: 160.w,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(RouteName.viewattendance),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                child: Text(
                  "View Attendance",
                  style: TextStyle(fontSize: 15.sp, color: AppPalette.primary),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Filters
            Row(
              children: [
                Expanded(flex: 2, child: _buildDropdown()),
                SizedBox(width: 16.w),
                Expanded(flex: 2, child: _buildDateField()),
                SizedBox(width: 16.w),
                Obx(() {
                  final loading = controller.isLoading.value;
                  return ElevatedButton(
                    onPressed: loading ? null : controller.apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 14.h),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            "Apply",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  );
                }),
              ],
            ),
            SizedBox(height: 18.h),

            /// Table / Empty
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.attendanceList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.attendanceList.isEmpty) {
                  return Center(
                    child: Text(
                      "No records found. Please select type and date.",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppPalette.border),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(AppPalette.surface),
                      columns: [
                        _buildColumn("SR NO"),
                        _buildColumn("NAME"),
                        _buildColumn("PRESENT"),
                        _buildColumn("CHECKED IN"),
                        _buildColumn("CHECKED OUT"),
                        _buildColumn("NOTES"),
                      ],
                      rows: List<DataRow>.generate(
                        controller.attendanceList.length,
                        (index) {
                          final item = controller.attendanceList[index];

                          final serial = (index + 1).toString();
                          final name = (item["name"] ?? "-").toString();
                          final present = item["present"] == true;

                          final checkIn = (item["checkIn"] ?? "").toString();
                          final checkOut = (item["checkOut"] ?? "").toString();

                          return DataRow(
                            cells: [
                              DataCell(Text(serial)),
                              DataCell(Text(name)),

                              DataCell(
                                Checkbox(
                                  value: present,
                                  onChanged: (val) {
                                    if (val == null) return;
                                    controller.togglePresent(index, val);
                                  },
                                ),
                              ),

                              DataCell(
                                _timePickerCell(
                                  enabled: present,
                                  label: controller.formatForUi(checkIn),
                                  onTap: () => controller.pickTime(index, true),
                                ),
                              ),

                              DataCell(
                                _timePickerCell(
                                  enabled: present,
                                  label: controller.formatForUi(checkOut),
                                  onTap: () => controller.pickTime(index, false),
                                ),
                              ),

                              DataCell(
                                SizedBox(
                                  width: 220.w,
                                  child: TextFormField(
                                    enabled: present,
                                    initialValue: (item["notes"] ?? "").toString(),
                                    onChanged: (v) {
                                      item["notes"] = v;
                                      controller.attendanceList.refresh();
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Notes (optional)",
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8.r)),
                                      isDense: true,
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 16.h),

            /// Save
            Center(
              child: Obx(() {
                final saving = controller.isSaving.value;
                return ElevatedButton.icon(
                  onPressed: saving ? null : controller.saveAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  icon: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    saving ? "Saving..." : "Save",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Obx(() {
      return DropdownButtonFormField<String>(
        value: controller.selectedType.value,
        items: controller.typeOptions
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: (v) => controller.selectedType.value = v ?? "Members",
        decoration: InputDecoration(
          labelText: "Type *",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          filled: true,
          fillColor: AppPalette.surface,
        ),
      );
    });
  }

  Widget _buildDateField() {
    return TextFormField(
      controller: controller.dateController,
      readOnly: true,
      onTap: controller.pickDate,
      decoration: InputDecoration(
        labelText: "Date *",
        prefixIcon: const Icon(Icons.calendar_today, color: AppPalette.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        filled: true,
        fillColor: AppPalette.surface,
      ),
    );
  }

  DataColumn _buildColumn(String label) {
    return DataColumn(
      label: Text(
        label,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: AppPalette.textPrimary,
        ),
      ),
    );
  }

  Widget _timePickerCell({
    required bool enabled,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppPalette.border),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, color: AppPalette.textSecondary, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: AppPalette.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
