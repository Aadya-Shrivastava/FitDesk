import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtrainee/controller/Ateendancecontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';


class AttendanceView extends StatelessWidget {
  AttendanceView({super.key});

  final AttendanceController c = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Attendance',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppPalette.primary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Attendance history',
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => Get.toNamed(RouteName.viewattendance),
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _Header(date: c.date.value),

              SizedBox(height: 12.h),

              if (c.error.value.isNotEmpty)
                _ErrorBanner(text: c.error.value),

              SizedBox(height: 12.h),

              _CardShell(
                title: 'Status',
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() => DropdownButtonFormField<String>(
                            value: c.status.value,
                            items: const [
                              DropdownMenuItem(value: 'Present', child: Text('Present')),
                              DropdownMenuItem(value: 'Absent', child: Text('Absent')),
                              DropdownMenuItem(value: 'Half Day', child: Text('Half Day')),
                            ],
                            onChanged: (v) {
                              if (v != null) c.setStatus(v);
                            },
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                            ),
                          )),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              _CardShell(
                title: 'Notes',
                child: TextFormField(
                  initialValue: c.notesCtrl.value,
                  onChanged: c.setNotes,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add note (optional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r)),
                    contentPadding: EdgeInsets.all(12.w),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              _CardShell(
                title: 'Today',
                child: Column(
                  children: [
                    _InfoRow(
                      label: 'Check-In Time',
                      value: c.checkedInTime.value.isEmpty ? '--' : c.checkedInTime.value,
                    ),
                    SizedBox(height: 8.h),
                    _InfoRow(
                      label: 'Check-Out Time',
                      value: c.checkedOutTime.value.isEmpty ? '--' : c.checkedOutTime.value,
                    ),
                    SizedBox(height: 10.h),
                    Divider(color: AppPalette.border),
                    SizedBox(height: 10.h),
                    _MiniAddress(
                      title: 'Check-In Address',
                      value: c.checkinAddress.value.isEmpty ? '--' : c.checkinAddress.value,
                    ),
                    SizedBox(height: 10.h),
                    _MiniAddress(
                      title: 'Check-Out Address',
                      value: c.checkoutAddress.value.isEmpty ? '--' : c.checkoutAddress.value,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              Obx(() {
                final disabledIn = c.isPosting.value || c.hasCheckedIn.value;
                final disabledOut = c.isPosting.value || c.hasCheckedOut.value || !c.hasCheckedIn.value;

                return Column(
                  children: [
                    _PrimaryButton(
                      text: c.hasCheckedIn.value ? 'Checked In' : 'CHECK IN',
                      icon: Icons.login,
                      isLoading: c.isPosting.value && !c.hasCheckedIn.value,
                      disabled: disabledIn,
                      onTap: c.checkIn,
                    ),
                    SizedBox(height: 12.h),
                    _PrimaryButton(
                      text: c.hasCheckedOut.value ? 'Checked Out' : 'CHECK OUT',
                      icon: Icons.logout,
                      isLoading: c.isPosting.value && c.hasCheckedIn.value && !c.hasCheckedOut.value,
                      disabled: disabledOut,
                      onTap: c.checkOut,
                    ),
                  ],
                );
              }),

              SizedBox(height: 12.h),

              if (c.isLoading.value)
                Padding(
                  padding: EdgeInsets.only(top: 12.h),
                  child: const CircularProgressIndicator(),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.date});
  final String date;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.primary, AppPalette.accent],
        ),
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: const Icon(Icons.location_on_outlined, color: Colors.white),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today Attendance',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
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
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppPalette.textPrimary,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppPalette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MiniAddress extends StatelessWidget {
  const _MiniAddress({required this.title, required this.value});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppPalette.textPrimary,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 12.sp,
            color: AppPalette.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onTap,
    required this.disabled,
    required this.isLoading,
  });

  final String text;
  final IconData icon;
  final VoidCallback onTap;
  final bool disabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: disabled ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.primary,
          disabledBackgroundColor: AppPalette.primary.withOpacity(0.35),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white),
                  SizedBox(width: 10.w),
                  Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppPalette.error.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppPalette.error.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 12.sp, color: AppPalette.error),
      ),
    );
  }
}
