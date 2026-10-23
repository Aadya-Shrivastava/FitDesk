import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/controller/createeventtypecontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class EventTypeAddView extends StatelessWidget {
  final EventTypeController controller = Get.put(EventTypeController(), permanent: true);

  EventTypeAddView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: AppPalette.primary,
        title: Text(
          "Create Event Type",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: "Refresh",
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
              // ---------------- CREATE CARD ----------------
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
                        "Create Event Type",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      TextFormField(
                        controller: controller.eventTypeController,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? "Please enter event type" : null,
                        decoration: InputDecoration(
                          labelText: "Event Type *",
                          hintText: "Enter event type name",
                          prefixIcon: const Icon(Icons.event_outlined, color: AppPalette.primary),
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
                          final busy = controller.isSubmitting.value;
                          return ElevatedButton.icon(
                            onPressed: busy ? null : controller.createEventType,
                            icon: busy
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
                              busy ? "Creating..." : "Create",
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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

              // ---------------- LIST CARD ----------------
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
                child: Obx(() {
                  final loading = controller.isLoading.value;
                  final err = controller.error.value.trim();
                  final list = controller.eventTypes;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Event Type List",
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppPalette.primary,
                        ),
                      ),
                      SizedBox(height: 12.h),

                      if (loading && list.isEmpty) ...[
                        const LinearProgressIndicator(),
                        SizedBox(height: 12.h),
                      ],

                      if (err.isNotEmpty && list.isEmpty) ...[
                        Text(
                          err,
                          style: GoogleFonts.poppins(color: Colors.red),
                        ),
                        SizedBox(height: 10.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: controller.refreshList,
                            icon: const Icon(Icons.refresh),
                            label: const Text("Retry"),
                          ),
                        ),
                      ],

                      if (list.isEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text("No event types available.")),
                        ),
                      ] else ...[
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: list.length,
                          separatorBuilder: (_, __) => const Divider(thickness: 0.8),
                          itemBuilder: (context, index) {
                            final event = list[index];

                            final title = (event.name ?? "").trim().isEmpty
                                ? "Event #${event.id ?? '-'}"
                                : event.name!.trim();

                            final created = (event.createdAt ?? "").trim().isEmpty
                                ? "-"
                                : event.createdAt!.trim();

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppPalette.primary,
                                child: Text(
                                  title.isNotEmpty ? title[0].toUpperCase() : "?",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              title: Text(
                                title,
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                "Created: $created",
                                style: GoogleFonts.poppins(
                                  fontSize: 12.sp,
                                  color: AppPalette.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),

                        SizedBox(height: 10.h),

                        // Load more
                        Obx(() {
                          final canLoadMore =
                              controller.currentPage.value < controller.lastPage.value;

                          if (!canLoadMore) return const SizedBox.shrink();

                          return Align(
                            alignment: Alignment.center,
                            child: controller.isLoadingMore.value
                                ? const Padding(
                                    padding: EdgeInsets.all(10),
                                    child: CircularProgressIndicator(),
                                  )
                                : OutlinedButton.icon(
                                    onPressed: controller.loadMore,
                                    icon: const Icon(Icons.expand_more),
                                    label: const Text("Load More"),
                                  ),
                          );
                        }),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
