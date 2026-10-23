import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/Model/extramodels.dart';
import 'package:gymtrainee/controller/eventscontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';

class EventsView extends StatelessWidget {
  EventsView({super.key});

  final EventsController c = Get.put(EventsController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: simpleAppBar('Gym Events'),
      body: Obx(() {
        if (c.isLoading.value && c.events.isEmpty) return const LoadingView();
        if (c.error.value.isNotEmpty && c.events.isEmpty) {
          return ErrorView(message: c.error.value, onRetry: c.fetchEvents);
        }
        if (c.events.isEmpty) {
          return EmptyView(
            icon: Icons.event_busy_rounded,
            title: 'No events planned',
            subtitle: 'Competitions, workshops and gym events will be listed here.',
            onRefresh: c.fetchEvents,
          );
        }
        final upcoming = c.upcoming;
        final past = c.events.where((e) => !e.isUpcomingOrOngoing).toList().reversed.toList();
        return RefreshIndicator(
          color: AppPalette.secondary,
          onRefresh: c.fetchEvents,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              if (upcoming.isNotEmpty) ...[
                const SectionHeader('Upcoming'),
                for (final e in upcoming) _EventCard(e: e, highlight: true),
              ],
              if (past.isNotEmpty) ...[
                const SizedBox(height: 12),
                const SectionHeader('Past events'),
                for (final e in past) _EventCard(e: e),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventItem e;
  final bool highlight;
  const _EventCard({required this.e, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final d = e.start;
    final range = e.endDate != null && e.endDate != e.startDate
        ? '${fmtDate(e.startDate)} – ${fmtDate(e.endDate)}'
        : fmtDate(e.startDate);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        gradient: highlight ? AppPalette.headerGradient : null,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppPalette.border),
              ),
              child: Column(
                children: [
                  Text(d == null ? '--' : '${d.day}', style: appText(20, weight: FontWeight.w700)),
                  Text(d == null ? '' : fmtDate(e.startDate, pattern: 'MMM'),
                      style: appText(11, color: AppPalette.secondary)),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(e.title, style: appText(15, weight: FontWeight.w600))),
                      if (e.status != null)
                        StatusChip(label: e.status!.toUpperCase(), color: AppPalette.secondary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text([if (e.type != null) e.type!, range].join('  •  '),
                      style: appText(11.5, color: AppPalette.textSecondary)),
                  if (e.description != null) ...[
                    const SizedBox(height: 8),
                    Text(e.description!, style: appText(12.5, color: Colors.white70)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
