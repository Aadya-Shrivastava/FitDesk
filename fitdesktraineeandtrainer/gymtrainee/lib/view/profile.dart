import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/controller/profilecontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/appdrawer.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';

class ProfileView extends StatelessWidget {
  ProfileView({super.key});

  final ProfileController c = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Obx(() {
        final _ = c.isLoading.value; // rebuild the header's loading spinner
        if (c.error.value.isNotEmpty && c.name.isEmpty) {
          return SafeArea(child: ErrorView(message: c.error.value, onRetry: c.fetchProfile));
        }
        return RefreshIndicator(
          color: AppPalette.secondary,
          onRefresh: c.fetchProfile,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _Header(c: c)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (c.daysLeft != null) ...[
                      _MembershipCard(c: c),
                      const SizedBox(height: 16),
                    ],
                    _InfoSection(title: 'Contact', rows: [
                      (Icons.mail_outline_rounded, 'Email', c.email),
                      (Icons.phone_outlined, 'Phone', c.phone),
                    ]),
                    const SizedBox(height: 16),
                    _InfoSection(title: 'Personal', rows: [
                      (Icons.badge_outlined, 'Member ID', c.memberId),
                      (Icons.wc_rounded, 'Gender', _cap(c.gender)),
                      (Icons.cake_outlined, 'Date of birth', c.dob.isEmpty ? '' : fmtDate(c.dob)),
                      (Icons.timelapse_rounded, 'Age', c.age.isEmpty ? '' : '${c.age} years'),
                    ]),
                    const SizedBox(height: 16),
                    _InfoSection(title: 'Fitness', rows: [
                      (Icons.flag_outlined, 'Goal', c.fitnessGoal),
                    ]),
                    const SizedBox(height: 16),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        children: [
                          _link(Icons.currency_rupee_rounded, 'My fees', RouteName.viewfees),
                          _link(Icons.history_rounded, 'Attendance history', RouteName.viewattendance),
                          _link(Icons.notifications_none_rounded, 'Notifications', RouteName.notifications),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: showLogoutDialog,
                      icon: const Icon(Icons.logout_rounded, color: AppPalette.error),
                      label: Text('Logout',
                          style: appText(14, weight: FontWeight.w600, color: AppPalette.error)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppPalette.error.withValues(alpha: 0.5)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _link(IconData icon, String label, String route) => ListTile(
        leading: Icon(icon, color: AppPalette.secondary),
        title: Text(label, style: appText(14)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppPalette.textSecondary),
        onTap: () => Get.toNamed(route),
      );
}

class _Header extends StatelessWidget {
  final ProfileController c;
  const _Header({required this.c});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: const BoxDecoration(
        gradient: AppPalette.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(8, top + 4, 8, 24),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Expanded(child: Text('My Profile', style: appText(18, weight: FontWeight.w600))),
              if (c.isLoading.value)
                const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppPalette.secondary)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          UserAvatar(url: c.photoUrl, initials: c.initials, size: 92),
          const SizedBox(height: 12),
          Text(c.name.isEmpty ? 'Member' : c.name,
              textAlign: TextAlign.center, style: appText(22, weight: FontWeight.w700)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: [
              StatusChip(
                  label: (c.role.isEmpty ? 'MEMBER' : c.role).toUpperCase(),
                  color: AppPalette.secondary),
              if (c.fitnessGoal.isNotEmpty)
                StatusChip(label: c.fitnessGoal, color: AppPalette.success),
            ],
          ),
        ],
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final ProfileController c;
  const _MembershipCard({required this.c});

  @override
  Widget build(BuildContext context) {
    final days = c.daysLeft!;
    final color = days < 0
        ? AppPalette.error
        : days <= 7
            ? AppPalette.warning
            : AppPalette.success;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(Icons.card_membership_rounded, color: color, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Membership', style: appText(11.5, color: AppPalette.textSecondary)),
                    Text(c.membershipName.isEmpty ? 'Active plan' : c.membershipName,
                        style: appText(15, weight: FontWeight.w600)),
                  ],
                ),
              ),
              StatusChip(
                label: days < 0 ? 'EXPIRED' : '$days DAYS LEFT',
                color: color,
              ),
            ],
          ),
          if (c.membershipProgress != null) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: c.membershipProgress,
                minHeight: 7,
                backgroundColor: Colors.white12,
                color: color,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Started ${fmtDate(c.membershipStart?.toIso8601String())}',
                  style: appText(11, color: AppPalette.textSecondary)),
              const Spacer(),
              Text('Expires ${fmtDate(c.membershipExpiry?.toIso8601String())}',
                  style: appText(11, color: AppPalette.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<(IconData, String, String)> rows;
  const _InfoSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final visible = rows.where((r) => r.$3.trim().isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) const Divider(height: 1, color: AppPalette.border),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Icon(visible[i].$1, size: 20, color: AppPalette.secondary),
                      const SizedBox(width: 12),
                      Text(visible[i].$2, style: appText(13, color: AppPalette.textSecondary)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(visible[i].$3,
                            textAlign: TextAlign.right,
                            style: appText(13.5, weight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
