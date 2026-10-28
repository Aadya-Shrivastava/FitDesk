import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtrainee/Model/classesmodel.dart';

import '../controller/viewclasscontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';
import 'package:gymtrainee/widgets/state_views.dart';

class ViewClass extends StatelessWidget {
  ViewClass({super.key});

  final Viewclasscontroller c = Get.put(Viewclasscontroller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: simpleAppBar('Class Details'),
      body: Obx(() {
        if (c.isLoading.value) return const LoadingView();

        if (c.error.value.isNotEmpty) {
          return ErrorView(message: c.error.value, onRetry: c.fetchClasses);
        }

        final cls = c.selectedClass.value;
        if (cls == null) {
          return EmptyView(
            icon: Icons.class_rounded,
            title: 'No classes yet',
            subtitle: 'You are not enrolled in any class. Ask your gym to add you to one.',
            onRefresh: c.fetchClasses,
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _HeaderCard(
                title: c.safe(cls.title),
                fee: c.money(cls.fees),
                enrolled: cls.isEnrolled == true,
                onToggle: c.toggleDetails,
                showDetails: c.showDetails.value,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    if (c.classesList.length > 1) _ClassSelector(),

                    SizedBox(height: 12.h),

                    Obx(() => AnimatedCrossFade(
                          duration: const Duration(milliseconds: 220),
                          crossFadeState: c.showDetails.value
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Column(
                            children: [
                              _InfoChips(
                                address: c.safe(cls.address),
                                notes: c.safe(cls.notes),
                              ),
                              SizedBox(height: 12.h),

                              _DetailsCard(cls: cls),
                              SizedBox(height: 12.h),

                              _ScheduleCard(schedules: cls.schedules ?? const []),
                              SizedBox(height: 12.h),

                              _TrainersCard(trainers: cls.trainers ?? const []),
                              SizedBox(height: 24.h),

                              // Assigned members needs API - no guessing.
                              // _MembersPlaceholder(),
                              // SizedBox(height: 24.h),
                            ],
                          ),
                          secondChild: SizedBox(height: 24.h),
                        )),
                  ],
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
    required this.title,
    required this.fee,
    required this.enrolled,
    required this.onToggle,
    required this.showDetails,
  });

  final String title;
  final String fee;
  final bool enrolled;
  final VoidCallback onToggle;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppPalette.background,
      child: Stack(
        children: [
          Container(
            height: 165.h,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56.w,
                      height: 56.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                      ),
                      child: const Icon(Icons.fitness_center, color: Colors.white),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              _Pill(
                                text: fee,
                                icon: Icons.payments_outlined,
                              ),
                              SizedBox(width: 10.w),
                              _Pill(
                                text: enrolled ? 'Enrolled' : 'Not Enrolled',
                                icon: enrolled ? Icons.verified : Icons.info_outline,
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onToggle,
                      icon: Icon(
                        showDetails ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                // SizedBox(height: 14.h),
                // Row(
                //   children: [
                //     _StatPill(label: 'Duration', value: '--'),
                //     SizedBox(width: 10.w),
                //     _StatPill(label: 'Batches', value: '--'),
                //     SizedBox(width: 10.w),
                //     _StatPill(label: 'Intensity', value: '--'),
                //   ],
                // ),
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
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
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

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClassSelector extends StatelessWidget {
  _ClassSelector();

  final Viewclasscontroller c = Get.find<Viewclasscontroller>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.swap_horiz, size: 18.sp, color: AppPalette.secondary),
          SizedBox(width: 8.w),
          Expanded(
            child: Obx(() {
              final current = c.selectedClass.value;
              return DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: current?.id,
                  items: c.classesList
                      .map((x) => DropdownMenuItem<int>(
                            value: x.id,
                            child: Text(
                              x.title ?? '-',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 13.sp),
                            ),
                          ))
                      .toList(),
                  onChanged: (id) {
                    final sel = c.classesList.firstWhereOrNull((e) => e.id == id);
                    if (sel != null) c.select(sel);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _InfoChips extends StatelessWidget {
  const _InfoChips({required this.address, required this.notes});
  final String address;
  final String notes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _Chip(icon: Icons.location_on_outlined, text: address),
        _Chip(icon: Icons.notes_outlined, text: notes),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxWidth: 320.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: AppPalette.secondary),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.cls});
  final Classes cls;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<Viewclasscontroller>();

    return _CardShell(
      title: 'Class Details',
      child: Column(
        children: [
          _kv('Title', c.safe(cls.title)),
          _kv('Fees', c.money(cls.fees)),
          _kv('Address', c.safe(cls.address)),
          _kv('Notes', c.safe(cls.notes)),
          _kv('Enrolled', cls.isEnrolled == true ? 'Yes' : 'No'),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
            child: Text(
              k,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppPalette.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: GoogleFonts.poppins(fontSize: 12.sp, color: AppPalette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedules});
  final List<Schedules> schedules;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<Viewclasscontroller>();

    return _CardShell(
      title: 'Schedule',
      child: schedules.isEmpty
          ? Text(
              'No schedule available.',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: AppPalette.textSecondary),
            )
          : Column(
              children: schedules
                  .map(
                    (s) => Container(
                      margin: EdgeInsets.only(bottom: 10.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppPalette.background,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppPalette.border),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 18.sp, color: AppPalette.secondary),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              c.scheduleLine(s),
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppPalette.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _TrainersCard extends StatelessWidget {
  const _TrainersCard({required this.trainers});
  final List<Trainers> trainers;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<Viewclasscontroller>();

    return _CardShell(
      title: 'Trainers',
      child: trainers.isEmpty
          ? Text(
              'No trainers assigned.',
              style: GoogleFonts.poppins(fontSize: 12.sp, color: AppPalette.textSecondary),
            )
          : Column(
              children: trainers
                  .map(
                    (t) => Container(
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
                            radius: 18.r,
                            backgroundColor: AppPalette.primary.withOpacity(0.08),
                            child: Icon(Icons.person, color: AppPalette.secondary, size: 18.sp),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.safe(t.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppPalette.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  c.safe(t.email),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11.sp,
                                    color: AppPalette.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppPalette.textSecondary, size: 20.sp),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _MembersPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _CardShell(
      title: 'Assigned Members',
      trailing: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.info_outline),
        label: const Text('Need API'),
      ),
      child: Text(
        'You still haven’t provided the members API.\n'
        'Give the endpoint for: class -> members list, and I’ll build a CultFit-style list (search, status, actions).',
        style: GoogleFonts.poppins(fontSize: 12.sp, color: AppPalette.textSecondary),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.title, required this.child, this.trailing});
  final String title;
  final Widget child;
  final Widget? trailing;

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
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.secondary,
                ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

