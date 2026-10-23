import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymadmin/controller/viewworkoutcontroller.dart';
import 'package:gymadmin/theme/app_palette.dart';

class WorkoutViewPage extends GetView<Viewworkoutcontroller> {
  const WorkoutViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(Viewworkoutcontroller());

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: AppPalette.primary,
        surfaceTintColor: Colors.white,
        title: const Text(
          "Workouts",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: AppPalette.secondary),
        actions: [
          Obx(() {
            return IconButton(
              tooltip: "Refresh",
              onPressed: controller.isLoading.value ? null : controller.refreshList,
              icon: const Icon(Icons.refresh),
            );
          }),
          const SizedBox(width: 6),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppPalette.border),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppPalette.primary,
        onPressed: () => Get.snackbar("Create", "Create workout screen not provided yet"),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Create", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.workouts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refreshList,
          );
        }

        if (controller.workouts.isEmpty) {
          return const _EmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshList,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              itemCount: controller.workouts.length + 1,
              itemBuilder: (_, i) {
                if (i == controller.workouts.length) {
                  return Obx(() {
                    if (!controller.isLoadingMore.value) return const SizedBox(height: 12);
                    return const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  });
                }

                final w = controller.workouts[i];
                final a = w.assignedTo;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppPalette.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppPalette.border),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 14, offset: Offset(0, 8)),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => controller.openDetails(w),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppPalette.secondary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.fitness_center_outlined, color: AppPalette.secondary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a?.title ?? "Assigned",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w900, color: AppPalette.secondary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${a?.type ?? "Type"} • ${w.startDate ?? "-"} → ${w.endDate ?? "-"}",
                                  style: const TextStyle(color: AppPalette.textSecondary, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    _chip("Activities", "${w.totalActivities ?? (w.activities?.length ?? 0)}"),
                                    const SizedBox(width: 8),
                                    if ((w.notes ?? "").trim().isNotEmpty) _chip("Notes", "Yes"),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          PopupMenuButton<String>(
                            onSelected: (v) {
                              if (v == "view") controller.openDetails(w);
                              if (v == "edit") controller.editWorkout(w);
                              if (v == "delete") controller.deleteWorkout(w);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: "view", child: Text("View")),
                              PopupMenuItem(value: "edit", child: Text("Edit")),
                              PopupMenuItem(value: "delete", child: Text("Delete")),
                            ],
                          )
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
    );
  }

  static Widget _chip(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppPalette.border),
      ),
      child: Text("$k: $v", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppPalette.textSecondary)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.border),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fitness_center_outlined, size: 46, color: AppPalette.textSecondary),
            SizedBox(height: 10),
            Text("No workouts found", style: TextStyle(fontWeight: FontWeight.w900)),
            SizedBox(height: 6),
            Text("Pull to refresh or create a new workout.", style: TextStyle(color: AppPalette.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppPalette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppPalette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 46, color: Colors.redAccent),
            const SizedBox(height: 10),
            const Text("Failed to load", style: TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppPalette.textSecondary)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.primary,
                foregroundColor: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
