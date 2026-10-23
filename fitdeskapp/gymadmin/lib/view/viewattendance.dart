import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/viewattendancecontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class AttendanceViewPage extends StatelessWidget {
  final Viewattendancecontroller controller = Get.put(Viewattendancecontroller());

  AttendanceViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: Text(
          "Attendance List",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppPalette.primary,
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPalette.primary,
        onPressed: controller.applyFilters,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ====== Filters ======
            Row(
              children: [
                Expanded(flex: 2, child: _buildDropdown()),
                SizedBox(width: 12.w),
                Expanded(flex: 2, child: _buildDateField()),
                SizedBox(width: 12.w),
                Obx(() {
                  final loading = controller.isLoading.value;
                  return ElevatedButton(
                    onPressed: loading ? null : controller.applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
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
            SizedBox(height: 16.h),

            TextFormField(
              controller: controller.searchController,
              onChanged: (_) => controller.applyLocalFilters(),
              decoration: InputDecoration(
                labelText: "Search by name",
                prefixIcon: const Icon(Icons.search, color: AppPalette.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                filled: true,
                fillColor: AppPalette.surface,
              ),
            ),
            SizedBox(height: 16.h),

            // ====== Header Row ======
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "User",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Date",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Check-In Time",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Check-Out Time",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "Notes",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            // ====== Attendance List ======
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : controller.errorMessage.value.isNotEmpty
                        ? Center(
                            child: Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : controller.attendanceList.isEmpty
                            ? const Center(child: Text("No attendance records found"))
                    : ListView.separated(
                        itemCount: controller.attendanceList.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, index) {
                          final record = controller.attendanceList[index];
                          final userName = record.user?.name ?? "-";
                          final notes = (record.notes ?? "").toString();
                          final date = record.date ?? "-";
                          final checkIn = record.checkedInTime ?? "-";
                          final checkOut = record.checkedOutTime ?? "-";

                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 10.h),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      userName,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      date,
                                      style: GoogleFonts.poppins(fontSize: 13.sp),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      checkIn,
                                      style: GoogleFonts.poppins(fontSize: 13.sp),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      checkOut,
                                      style: GoogleFonts.poppins(fontSize: 13.sp),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      notes.isNotEmpty ? notes : "-",
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(fontSize: 13.sp),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
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
        onChanged: (v) {
          controller.selectedType.value = v ?? "Member";
          controller.applyLocalFilters();
        },
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
}
