import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtrainee/Model/workoutmodel.dart';

import '../controller/viewtodayworkoutcontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';
import 'package:gymtrainee/widgets/state_views.dart';

class ViewTodayWorkout extends StatelessWidget {
  ViewTodayWorkout({super.key});

  final Viewtodayworkoutcontroller c = Get.put(Viewtodayworkoutcontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: simpleAppBar('Today\'s Workout'),
      body: Obx(() {
        if (c.isLoading.value) return const LoadingView();

        if (c.error.value.isNotEmpty) {
          return ErrorView(message: c.error.value, onRetry: c.fetchWorkouts);
        }

        final w = c.selected.value;
        if (w == null) {
          return EmptyView(
            icon: Icons.fitness_center_rounded,
            title: 'No workout plan yet',
            subtitle:
                'Your trainer hasn\'t assigned a workout. It will show up here once they do.',
            onRefresh: c.fetchWorkouts,
          );
        }

        final activities = w.activities ?? <Activities>[];
        final grouped = c.groupByDay(activities);

        return SingleChildScrollView(
          child: Column(
            children: [
              _HeaderCard(
                assignedTo: '${c.safe(w.assignedTo?.type)}',
                startDate: c.safe(w.startDate),
                endDate: c.endLabel(w.endDate),
                onToggle: c.toggleDetails,
                showDetails: c.showDetails.value,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Obx(
                  () => AnimatedCrossFade(
                    duration: const Duration(milliseconds: 220),
                    crossFadeState: c.showDetails.value
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        SizedBox(height: 12.h),
                        _CardShell(
                          title: 'Plan Notes',
                          child: Text(
                            c.safe(w.notes),
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              color: AppPalette.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _CardShell(
                          title: 'Workout Schedule',
                          child: grouped.isEmpty
                              ? Text(
                                  'No activities found.',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.sp,
                                    color: AppPalette.textSecondary,
                                  ),
                                )
                              : Column(
                                  children: grouped.entries.map((e) {
                                    final day = e.key;
                                    final list = e.value;
                                    return _DaySection(day: day, items: list);
                                  }).toList(),
                                ),
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                    secondChild: SizedBox(height: 24.h),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.assignedTo,
    required this.startDate,
    required this.endDate,
    required this.onToggle,
    required this.showDetails,
  });

  final String assignedTo;
  final String startDate;
  final String endDate;
  final VoidCallback onToggle;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppPalette.background,
      child: Stack(
        children: [
          // ✅ FIX: Increased height (was 160.h) + gives room on small phones
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppPalette.headerGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 22.h, 16.w, 16.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: const Icon(Icons.bolt, color: Colors.white),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Assigned To',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        assignedTo,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 10.h),

                      // ✅ FIX: Wrap instead of Row so pills never overflow
                      Wrap(
                        spacing: 10.w,
                        runSpacing: 8.h,
                        children: [
                          _Pill(text: startDate, icon: Icons.play_arrow),
                          _Pill(text: endDate, icon: Icons.stop),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onToggle,
                  icon: Icon(
                    showDetails
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      // ✅ Small padding tweak makes it safer on tiny screens
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({required this.day, required this.items});
  final String day;
  final List<Activities> items;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<Viewtodayworkoutcontroller>();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.background,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.secondary,
            ),
          ),
          SizedBox(height: 10.h),
          ...items.map(
            (a) => _ActivityRow(
              name: c.safe(a.activityName),
              weight: c.safe(a.weight),
              sets: c.safe(a.sets),
              reps: c.safe(a.reps),
              rest: c.safe(a.rest),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.name,
    required this.weight,
    required this.sets,
    required this.reps,
    required this.rest,
  });

  final String name;
  final String weight;
  final String sets;
  final String reps;
  final String rest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16.r,
            backgroundColor: AppPalette.primary.withOpacity(0.08),
            child: Icon(
              Icons.fitness_center,
              size: 16.sp,
              color: AppPalette.secondary,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppPalette.textPrimary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          _Metric(text: '$weight kg', label: 'Wt'),
          SizedBox(width: 8.w),
          _Metric(text: sets, label: 'Sets'),
          SizedBox(width: 8.w),
          _Metric(text: reps, label: 'Reps'),
          SizedBox(width: 8.w),
          _Metric(text: rest, label: 'Rest'),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.text, required this.label});
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10.sp,
            color: AppPalette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppPalette.secondary,
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}
