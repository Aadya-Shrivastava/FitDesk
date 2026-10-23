import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controller/viewtrainercontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/date_calc.dart';

class ViewTrainer extends StatelessWidget {
  ViewTrainer({super.key});

  final ViewTrainerController c = Get.put(ViewTrainerController());

  @override
  Widget build(BuildContext context) {
    // NOTE: ScreenUtilInit should be in main.dart, not here.
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Trainer Details',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppPalette.primary,
        elevation: 0,
      ),
      body: Obx(() {
        if (c.isLoading.value) return const LoadingView();

        if (c.error.value.isNotEmpty) {
          return ErrorView(message: c.error.value, onRetry: c.fetchTrainers);
        }

        final t = c.selectedTrainer.value;
        if (t == null) {
          return EmptyView(
            icon: Icons.sports_rounded,
            title: 'No trainer assigned yet',
            subtitle: 'Once the gym assigns you a trainer, their details will appear here.',
            onRefresh: c.fetchTrainers,
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _HeaderCard(
                name: c.safe(t.name),
                email: c.safe(t.email),
                phone: c.safe(t.phoneNumber),
                profileUrl: c.profileUrl(t.profile),
                onToggle: c.toggleDetails,
                showDetails: c.showDetails.value,
              ),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    // If multiple trainers returned, allow switching (cultfit-like quick switch)
                    if (c.trainers.length > 1) _TrainerSelector(),

                    SizedBox(height: 12.h),

                    Obx(() => AnimatedCrossFade(
                          duration: const Duration(milliseconds: 200),
                          crossFadeState: c.showDetails.value
                              ? CrossFadeState.showFirst
                              : CrossFadeState.showSecond,
                          firstChild: Column(
                            children: [
                              _InfoChips(
                                gender: c.safe(t.gender),
                                dob: DateCalc.dobWithAge(t.dob),
                                qualification: c.safe(t.qualification),
                                status: (t.status ?? 0) == 1 ? 'Active' : 'Inactive',
                              ),
                              SizedBox(height: 12.h),
                              _DetailsCard(t: t),
                              SizedBox(height: 12.h),
                              _AddressCard(t: t),
                              SizedBox(height: 16.h),

                              // Your "Assigned Members" table is not possible without API.
                              // // Keep placeholder until you provide endpoint.
                              // _PlaceholderMembersCard(),
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
    required this.name,
    required this.email,
    required this.phone,
    required this.profileUrl,
    required this.onToggle,
    required this.showDetails,
  });

  final String name;
  final String email;
  final String phone;
  final String profileUrl;
  final VoidCallback onToggle;
  final bool showDetails;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppPalette.primary,
      child: Stack(
        children: [
          // Cover
          Container(
            height: 160.h,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppPalette.primary, AppPalette.accent],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18.r),
                bottomRight: Radius.circular(18.r),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: avatar + toggle
                Row(
                  children: [
                    _Avatar(profileUrl: profileUrl),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onToggle,
                      icon: Icon(
                        showDetails ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 14.h),

                // Quick stats row (fake until you have endpoints)
                // Row(
                //   children: [
                //     _StatPill(label: 'Assigned', value: '--'),
                //     SizedBox(width: 10.w),
                //     _StatPill(label: 'Sessions', value: '--'),
                //     SizedBox(width: 10.w),
                //     _StatPill(label: 'Rating', value: '--'),
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profileUrl});
  final String profileUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56.w,
      height: 56.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: ClipOval(
        child: profileUrl.isEmpty
            ? Container(
                color: Colors.white.withOpacity(0.15),
                child: const Icon(Icons.person, color: Colors.white),
              )
            : Image.network(
                profileUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.white.withOpacity(0.15),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
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

class _TrainerSelector extends StatelessWidget {
  _TrainerSelector();

  final ViewTrainerController c = Get.find<ViewTrainerController>();

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
            spreadRadius: 0,
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
              final current = c.selectedTrainer.value;
              return DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: current?.id,
                  items: c.trainers
                      .map((t) => DropdownMenuItem<int>(
                            value: t.id,
                            child: Text(
                              '${t.name ?? '-'} (${t.trainerId ?? t.id ?? '-'})',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(fontSize: 13.sp),
                            ),
                          ))
                      .toList(),
                  onChanged: (id) {
                    final t = c.trainers.firstWhereOrNull((x) => x.id == id);
                    if (t != null) c.selectTrainer(t);
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
  const _InfoChips({
    required this.gender,
    required this.dob,
    required this.qualification,
    required this.status,
  });

  final String gender;
  final String dob;
  final String qualification;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      children: [
        _Chip(icon: Icons.person_outline, text: gender),
        _Chip(icon: Icons.cake_outlined, text: dob),
        _Chip(icon: Icons.school_outlined, text: qualification),
        _Chip(icon: Icons.verified_outlined, text: status),
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
          Text(
            text,
            style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.t});
  final dynamic t; // Trainers

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ViewTrainerController>();

    return _CardShell(
      title: 'Profile',
      child: Column(
        children: [
          _kv('Name', c.safe(t.name)),
          _kv('Email', c.safe(t.email)),
          _kv('Phone', c.safe(t.phoneNumber)),
          _kv('Gender', c.safe(t.gender)),
          _kv('DOB', DateCalc.dobWithAge(t.dob)),
          _kv('Trainer ID', (t.trainerId ?? t.id ?? '-').toString()),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
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

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.t});
  final dynamic t;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ViewTrainerController>();

    return _CardShell(
      title: 'Address',
      child: Column(
        children: [
          _kv('Address', c.safe(t.address)),
          _kv('City', c.safe(t.city)),
          _kv('State', c.safe(t.state)),
          _kv('Country', c.safe(t.country)),
          _kv('Zip Code', c.safe(t.zipCode)),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
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

class _PlaceholderMembersCard extends StatelessWidget {
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
        'You can’t show assigned members until you provide the endpoint.\n'
        'Send the members API (trainer -> members list) and I’ll wire the list exactly like CultFit (cards + status + CTA).',
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
            spreadRadius: 0,
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

