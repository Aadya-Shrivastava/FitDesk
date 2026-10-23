import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/Model/viewattendacnemodel.dart';
import 'package:gymtrainee/controller/viewattendancecontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/date_calc.dart';

class Viewattendanceview extends GetView<Viewattendancecontroller> {
  const Viewattendanceview({super.key});

  @override
  Widget build(BuildContext context) {
    // If you're not binding controller elsewhere, uncomment:
    // Get.put(Viewattendancecontroller());

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: const Text('Attendance'),
        elevation: 0,
        backgroundColor: AppPalette.primary,
        foregroundColor: AppPalette.textPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) return const LoadingView();

        if (controller.error.value.isNotEmpty) {
          return ErrorView(
            message: controller.error.value,
            onRetry: controller.fetchAttendance,
          );
        }

        if (controller.attendanceList.isEmpty) {
          return EmptyView(
            icon: Icons.event_available_rounded,
            title: 'No attendance yet',
            subtitle: 'Check in at the gym and your visits will be listed here.',
            onRefresh: controller.refreshAttendance,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAttendance,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            itemCount: controller.attendanceList.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return _Summary(c: controller);
              final a = controller.attendanceList[index - 1];
              return _AttendanceCard(att: a);
            },
          ),
        );
      }),
    );
  }
}

/// "Mon, 12 Oct 2026"
String _fmtDay(String? raw) {
  final d = DateCalc.parse(raw);
  return d == null ? (raw ?? "—") : DateFormat('EEE, dd MMM yyyy').format(d);
}

/// Server duration if given, otherwise check-out minus check-in.
String _duration(Attendance a) {
  final server = (a.duration ?? '').trim();
  if (server.isNotEmpty) return server;
  final d = DateCalc.between(a.checkedInTime, a.checkedOutTime);
  return d == null ? "—" : DateCalc.fmtDuration(d);
}

/// Totals worked out from the history list itself.
class _Summary extends StatelessWidget {
  final Viewattendancecontroller c;
  const _Summary({required this.c});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final list = c.attendanceList;
    final thisMonth = list.where((a) {
      final d = DateCalc.parse(a.date);
      return d != null && d.year == now.year && d.month == now.month;
    }).length;
    final sessions = list
        .map((a) => DateCalc.between(a.checkedInTime, a.checkedOutTime))
        .whereType<Duration>()
        .toList();
    final avg = sessions.isEmpty
        ? null
        : Duration(
            minutes: sessions.fold<int>(0, (s, d) => s + d.inMinutes) ~/ sessions.length);

    Widget stat(String label, String value) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      color: AppPalette.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(label, style: const TextStyle(color: AppPalette.textSecondary, fontSize: 12)),
            ],
          ),
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          stat('Total visits', '${list.length}'),
          stat('This month', '$thisMonth'),
          stat('Avg session', DateCalc.fmtDuration(avg)),
        ],
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  final Attendance att;
  const _AttendanceCard({required this.att});

  @override
  Widget build(BuildContext context) {
    final status = (att.status ?? "Unknown").trim();
    final pill = _statusPill(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Expanded(
                child: Text(
                  _fmtDay(att.date),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              pill,
            ],
          ),
          const SizedBox(height: 12),

          // Check in/out
          _InfoRow(
            icon: Icons.login_rounded,
            title: "Check-in",
            value: att.checkedInTime ?? "—",
            subtitle: att.checkinAddress,
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.logout_rounded,
            title: "Check-out",
            value: att.checkedOutTime ?? "—",
            subtitle: att.checkoutAddress,
          ),

          const SizedBox(height: 12),
          _Divider(),

          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.timer_rounded, size: 18),
              const SizedBox(width: 8),
              const Text(
                "Duration",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                _duration(att),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),

          if ((att.notes ?? "").trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                att.notes!.trim(),
                style: const TextStyle(height: 1.3),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(String status) {
    // CultFit-ish: compact pill + strong color semantics
    Color bg;
    Color fg;

    final s = status.toLowerCase();
    if (s.contains("present") || s.contains("checked") || s.contains("in")) {
      bg = AppPalette.success.withOpacity(0.15);
      fg = AppPalette.success;
    } else if (s.contains("absent") || s.contains("miss")) {
      bg = AppPalette.error.withOpacity(0.15);
      fg = AppPalette.error;
    } else if (s.contains("late")) {
      bg = const Color(0xFFF59E0B).withOpacity(0.15);
      fg = const Color(0xFFF59E0B);
    } else {
      bg = AppPalette.border;
      fg = AppPalette.textPrimary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.isEmpty ? "Unknown" : status,
        style: TextStyle(
          color: fg,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppPalette.background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const Spacer(),
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if ((subtitle ?? "").trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!.trim(),
                  style: TextStyle(
                    color: AppPalette.textSecondary,
                    fontSize: 12.5,
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        )
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      width: double.infinity,
      color: AppPalette.border,
    );
  }
}


