import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/Model/viewworkoutassign.dart';

class Viewworkoutcontroller extends GetxController {
  final String endpoint = "https://fitdesk.theapexinnovation.com/api/v1/gym-owner/workouts";

  final workouts = <Workouts>[].obs;

  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final errorMessage = "".obs;

  final currentPage = 1.obs;
  final lastPage = 1.obs;

  Future<String?> _getToken() async {
    return await PrefManager().readValue(key: PrefConst.token);
  }

  @override
  void onInit() {
    super.onInit();
    fetchWorkouts(reset: true);
  }

  Future<void> fetchWorkouts({bool reset = false}) async {
    if (isLoading.value) return;

    if (reset) {
      workouts.clear();
      errorMessage.value = "";
      currentPage.value = 1;
      lastPage.value = 1;
    }

    isLoading.value = true;
    try {
      final token = await _getToken();
      if (token == null || token.trim().isEmpty) {
        errorMessage.value = "Token missing. Please login again.";
        return;
      }

      final url = Uri.parse("$endpoint?page=${currentPage.value}");
      final resp = await http.get(
        url,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer ${token.trim()}",
        },
      );

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        errorMessage.value = _prettyApiError(resp.body, resp.statusCode);
        return;
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final model = viewworkoutassign.fromJson(decoded);

      final newList = model.data?.workouts ?? <Workouts>[];
      final pg = model.data?.pagination;

      if (pg != null) {
        currentPage.value = pg.currentPage ?? currentPage.value;
        lastPage.value = pg.lastPage ?? lastPage.value;
      }

      workouts.addAll(newList);
      errorMessage.value = "";
    } catch (e) {
      errorMessage.value = "Failed to load workouts: $e";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (currentPage.value >= lastPage.value) return;

    isLoadingMore.value = true;
    try {
      currentPage.value = currentPage.value + 1;
      await fetchWorkouts(reset: false);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshList() async {
    await fetchWorkouts(reset: true);
  }

  // -------- UI actions --------

  void openDetails(Workouts w) {
    Get.bottomSheet(
      _WorkoutDetailsSheet(workout: w),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void editWorkout(Workouts w) {
    Get.snackbar("Edit", "Edit workout #${w.id ?? ""} (implement API)",
        snackPosition: SnackPosition.BOTTOM);
  }

  void deleteWorkout(Workouts w) {
    // You didn't provide delete API endpoint. This is placeholder.
    workouts.removeWhere((x) => x.id == w.id);
    Get.snackbar("Deleted", "Workout removed (UI only)",
        snackPosition: SnackPosition.BOTTOM);
  }

  // -------- Helpers --------
  String _prettyApiError(String body, int status) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final msg = decoded["message"]?.toString();
        final errors = decoded["errors"];
        if (errors is Map) {
          final b = StringBuffer();
          b.writeln(msg ?? "Request failed ($status)");
          errors.forEach((k, v) => b.writeln("$k: $v"));
          return b.toString();
        }
        return msg ?? decoded.toString();
      }
      return body;
    } catch (_) {
      return body.isNotEmpty ? body : "Request failed ($status)";
    }
  }
}

// ===================== Details Sheet (UI helper) =====================

class _WorkoutDetailsSheet extends StatelessWidget {
  final Workouts workout;
  const _WorkoutDetailsSheet({required this.workout});

  @override
  Widget build(BuildContext context) {
    final a = workout.assignedTo;
    final activities = workout.activities ?? [];

    // group by day
    final byDay = <String, List<Activities>>{};
    for (final act in activities) {
      final day = (act.day ?? "Unknown").toString();
      byDay.putIfAbsent(day, () => []);
      byDay[day]!.add(act);
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      builder: (_, scroll) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF6F7FB),
            borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Workout #${workout.id ?? "-"}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0B2342)),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scroll,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    _InfoCard(
                      title: "Assigned",
                      rows: [
                        _InfoRow("Type", a?.type ?? "-"),
                        _InfoRow("Title", a?.title ?? "-"),
                        _InfoRow("Start", workout.startDate ?? "-"),
                        _InfoRow("End", workout.endDate ?? "-"),
                        _InfoRow("Total Activities", "${workout.totalActivities ?? activities.length}"),
                      ],
                      note: (workout.notes ?? "").trim().isEmpty ? null : workout.notes,
                    ),
                    const SizedBox(height: 12),

                    _SectionTitle("Activities"),
                    const SizedBox(height: 8),

                    if (activities.isEmpty)
                      const _EmptyBox(text: "No activities in this workout.")
                    else
                      ...byDay.entries.map((e) {
                        return _DayBlock(day: e.key, items: e.value);
                      }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final List<_InfoRow> rows;
  final String? note;
  const _InfoCard({required this.title, required this.rows, this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0B2342))),
            const SizedBox(height: 10),
            ...rows.map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(r.k, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
                      ),
                      Expanded(child: Text(r.v, style: const TextStyle(fontWeight: FontWeight.w800))),
                    ],
                  ),
                )),
            if (note != null) ...[
              const Divider(height: 18),
              Text("Notes", style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(note!, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow {
  final String k;
  final String v;
  _InfoRow(this.k, this.v);
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF0B2342)));
  }
}

class _DayBlock extends StatelessWidget {
  final String day;
  final List<Activities> items;
  const _DayBlock({required this.day, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9EF)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(day, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...items.map((a) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFD),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE7E9EF)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(a.activityName ?? "-", style: const TextStyle(fontWeight: FontWeight.w900)),
                    ),
                    _mini("W", a.weight),
                    const SizedBox(width: 8),
                    _mini("S", a.sets),
                    const SizedBox(width: 8),
                    _mini("R", a.reps),
                    const SizedBox(width: 8),
                    _mini("Rest", a.rest, wide: true),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _mini(String label, Object? v, {bool wide = false}) {
    final valueText = v == null ? "0" : v.toString();
    return Container(
      width: wide ? 70 : 40,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE7E9EF)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(valueText, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E9EF)),
      ),
      child: Text(text, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700)),
    );
  }
}
