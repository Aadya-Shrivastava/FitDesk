import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/viewclasscontroller.dart';
import '../Model/classmodel.dart';
import 'package:gymadmin/theme/app_palette.dart';

class ClassesViewPage extends StatelessWidget {
  ClassesViewPage({super.key});

  final ViewClassesController controller = Get.isRegistered<ViewClassesController>()
      ? Get.find<ViewClassesController>()
      : Get.put(ViewClassesController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: Text(
          "Classes List",
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
        onPressed: controller.refreshList,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),

      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======= Heading =======
            Container(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: AppPalette.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                "All Classes",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // ======= List =======
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.classes.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (controller.error.value.isNotEmpty &&
                    controller.classes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshList,
                    child: ListView(
                      children: [
                        SizedBox(height: 200.h),
                        Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              controller.error.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: ElevatedButton(
                            onPressed: controller.refreshList,
                            child: const Text("Retry"),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (controller.classes.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refreshList,
                    child: ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("No classes found")),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refreshList,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (n) {
                      if (n.metrics.pixels >= n.metrics.maxScrollExtent - 80) {
                        controller.loadMore();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      itemCount: controller.classes.length + 1,
                      separatorBuilder: (_, __) => SizedBox(height: 10.h),
                      itemBuilder: (context, index) {
                        if (index == controller.classes.length) {
                          return Obx(() {
                            if (controller.isLoadingMore.value) {
                              return Padding(
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          });
                        }

                        final c = controller.classes[index];
                        return InkWell(
                          onTap: () => controller.viewClassDetails(c),
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 14.w,
                                vertical: 12.h,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          c.title ?? "-",
                                          style: GoogleFonts.poppins(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: AppPalette.primary.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6.r),
                                        ),
                                        child: Text(
                                          "₹${c.fees ?? 0}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppPalette.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  _infoRow(Icons.access_time, controller.scheduleSummary(c)),
                                  SizedBox(height: 4.h),
                                  _infoRow(Icons.location_on_outlined, c.address ?? "-"),
                                  SizedBox(height: 4.h),
                                  _infoRow(Icons.badge_outlined, controller.trainerNames(c)),
                                  SizedBox(height: 4.h),
                                  _infoRow(Icons.group_outlined,
                                      "${c.totalTrainees ?? 0} member(s)"),
                                  SizedBox(height: 12.h),
                                  Obx(() => Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: controller.isAssigning.value
                                                  ? null
                                                  : () => _openTrainerPicker(context, c),
                                              icon: const Icon(Icons.badge_outlined, size: 16),
                                              label: const Text("Assign Trainer"),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: AppPalette.primary),
                                                foregroundColor: AppPalette.primary,
                                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              onPressed: controller.isAssigning.value
                                                  ? null
                                                  : () => _openTraineePicker(context, c),
                                              icon: const Icon(Icons.group_add_outlined, size: 16),
                                              label: const Text("Assign Trainee"),
                                              style: OutlinedButton.styleFrom(
                                                side: const BorderSide(color: AppPalette.primary),
                                                foregroundColor: AppPalette.primary,
                                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  // -------- Assign trainer / trainee pickers --------

  void _openTrainerPicker(BuildContext context, Classes c) {
    final classId = c.id;
    if (classId == null) return;

    _openPickerBottomSheet(
      context: context,
      title: "Assign Trainer",
      isLoading: () => controller.trainerCtrl.isLoading.value,
      itemCount: () => controller.trainerCtrl.trainers.length,
      itemLabel: (i) {
        final t = controller.trainerCtrl.trainers[i];
        return (t.name ?? "").trim().isNotEmpty ? t.name! : "Trainer #${t.id}";
      },
      itemSubtitle: (i) => controller.trainerCtrl.trainers[i].email ?? "",
      onPick: (i) {
        final trainerId = controller.trainerCtrl.trainers[i].id;
        if (trainerId != null) controller.assignTrainer(classId, trainerId);
      },
    );
  }

  void _openTraineePicker(BuildContext context, Classes c) {
    final classId = c.id;
    if (classId == null) return;

    _openPickerBottomSheet(
      context: context,
      title: "Assign Trainee",
      isLoading: () => controller.traineeCtrl.isLoading.value,
      itemCount: () => controller.traineeCtrl.trainees.length,
      itemLabel: (i) {
        final t = controller.traineeCtrl.trainees[i];
        return (t.name ?? "").trim().isNotEmpty ? t.name! : "Trainee #${t.id}";
      },
      itemSubtitle: (i) => controller.traineeCtrl.trainees[i].email ?? "",
      onPick: (i) {
        final traineeId = controller.traineeCtrl.trainees[i].id;
        if (traineeId != null) controller.assignTrainee(classId, traineeId);
      },
    );
  }

  /// Shared search + list bottom sheet used by both pickers above. Reads
  /// through small callbacks instead of a fixed list type so it works for
  /// both Trainers and Trainees without duplicating the sheet UI.
  void _openPickerBottomSheet({
    required BuildContext context,
    required String title,
    required bool Function() isLoading,
    required int Function() itemCount,
    required String Function(int index) itemLabel,
    required String Function(int index) itemSubtitle,
    required void Function(int index) onPick,
  }) {
    final search = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setState) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(18.r)),
            ),
            child: Obx(() {
              final loading = isLoading();
              final count = itemCount();

              final q = search.text.trim().toLowerCase();
              final indices = List.generate(count, (i) => i).where((i) {
                if (q.isEmpty) return true;
                return itemLabel(i).toLowerCase().contains(q) ||
                    itemSubtitle(i).toLowerCase().contains(q);
              }).toList();

              return Column(
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16.sp),
                  ),
                  SizedBox(height: 10.h),
                  TextField(
                    controller: search,
                    decoration: InputDecoration(
                      hintText: "Search...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  SizedBox(height: 10.h),
                  Expanded(
                    child: loading && count == 0
                        ? const Center(child: CircularProgressIndicator())
                        : indices.isEmpty
                            ? const Center(child: Text("No results"))
                            : ListView.builder(
                                itemCount: indices.length,
                                itemBuilder: (_, i) {
                                  final idx = indices[i];
                                  final subtitle = itemSubtitle(idx);
                                  return ListTile(
                                    title: Text(itemLabel(idx)),
                                    subtitle: subtitle.trim().isEmpty ? null : Text(subtitle),
                                    onTap: () {
                                      Get.back();
                                      onPick(idx);
                                    },
                                  );
                                },
                              ),
                  ),
                ],
              );
            }),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14.sp, color: AppPalette.textSecondary),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12.5.sp, color: AppPalette.textSecondary),
          ),
        ),
      ],
    );
  }
}
