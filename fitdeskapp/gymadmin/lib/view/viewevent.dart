import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/vieweventcontroller.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:gymadmin/theme/app_palette.dart';

class EventViewPage extends StatelessWidget {
  final Vieweventcontroller controller = Get.put(Vieweventcontroller());

  EventViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: AppPalette.primary,
        centerTitle: true,
        title: Text(
          "Event Calendar",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            final loading = controller.isLoading.value;
            return IconButton(
              tooltip: "Refresh",
              onPressed: loading ? null : () => controller.fetchEvents(reset: true),
              icon: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.refresh, color: Colors.white),
            );
          }),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Error line
            Obx(() {
              if (controller.error.value.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  controller.error.value,
                  style: GoogleFonts.poppins(color: Colors.red.shade700, fontSize: 12.sp),
                ),
              );
            }),

            /// Calendar
            Obx(() {
              return TableCalendar(
                focusedDay: controller.focusedDay.value,
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                calendarFormat: CalendarFormat.month,

                selectedDayPredicate: (day) =>
                    isSameDay(controller.selectedDay.value, day),

                onDaySelected: (selectedDay, focusedDay) {
                  controller.selectedDay.value = selectedDay;
                  controller.focusedDay.value = focusedDay;
                },

                onPageChanged: (focusedDay) {
                  controller.focusedDay.value = focusedDay;
                },

                // 🔥 THIS now returns List<Events> not List<String>
                eventLoader: controller.getEventsForDay,

                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                  selectedDecoration: BoxDecoration(color: AppPalette.primary, shape: BoxShape.circle),
                  markerDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                ),

                headerStyle: HeaderStyle(
                  titleCentered: true,
                  formatButtonVisible: false,
                  titleTextFormatter: (date, locale) =>
                      DateFormat.yMMMM().format(date).toUpperCase(),
                  titleTextStyle: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),

            SizedBox(height: 16.h),

            /// List header
            Obx(() {
              final d = controller.selectedDay.value;
              return Text(
                "Events on ${DateFormat('MMM d, yyyy').format(d)}",
                style: GoogleFonts.poppins(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppPalette.primary,
                ),
              );
            }),

            SizedBox(height: 10.h),

            /// List
            Expanded(
              child: Obx(() {
                final list = controller.getEventsForDay(controller.selectedDay.value);

                if (controller.isLoading.value && controller.allEvents.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (list.isEmpty) {
                  return const Center(child: Text("No events for this day"));
                }

                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (context, index) {
                    final e = list[index];

                    final title = (e.title ?? "Untitled").trim();
                    final typeName = (e.eventType?.name ?? "-").trim();
                    final statusLabel = (e.statusLabel ?? "-").trim();

                    final start = e.startDate ?? "";
                    final end = e.endDate ?? "";

                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      child: ListTile(
                        title: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        subtitle: Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Type: $typeName"),
                              Text("Status: $statusLabel"),
                              if (start.isNotEmpty || end.isNotEmpty)
                                Text("Date: $start  →  $end"),
                            ],
                          ),
                        ),
                        leading: Container(
                          width: 10.w,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: _statusColor(statusLabel),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String label) {
    final v = label.toLowerCase();
    if (v.contains("upcoming")) return Colors.orange;
    if (v.contains("running") || v.contains("ongoing")) return Colors.blue;
    if (v.contains("completed")) return Colors.green;
    if (v.contains("cancel")) return Colors.red;
    return Colors.grey;
  }
}
