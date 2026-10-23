import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/controller/dashboardcontroller.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/appdrawer.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';
import 'package:gymtrainee/widgets/state_views.dart';
import 'package:gymtrainee/widgets/date_calc.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomePage({super.key});

  /// Opens a screen and refreshes the dashboard bits that screen can change.
  Future<void> _open(String route) async {
    await Get.toNamed(route);
    controller.loadTodayAttendance();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return Scaffold(
      backgroundColor: AppPalette.background,
      drawer: const AppDrawer(current: RouteName.dashboard),
      appBar: AppBar(
        backgroundColor: AppPalette.background,
        elevation: 0,
        centerTitle: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Dashboard', style: appText(20, weight: FontWeight.w700)),
        actions: [
          Obx(() => _BellButton(
                count: c.notifications.unreadCount,
                onTap: () => _open(RouteName.notifications),
              )),
          const SizedBox(width: 8),
          Obx(() => GestureDetector(
                onTap: () => _open(RouteName.profile),
                child: UserAvatar(
                  url: c.profile.photoUrl,
                  initials: c.profile.initials,
                  size: 36,
                ),
              )),
          const SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) return const LoadingView();
        return RefreshIndicator(
          color: AppPalette.secondary,
          onRefresh: c.refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
            children: [
              _HeroCard(c: c, onTap: () => _open(RouteName.profile)),
              if (c.error.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InlineError(message: c.error.value, onRetry: c.fetchDashboardData),
              ],
              const SizedBox(height: 16),
              _TodayCard(c: c, onTap: () => _open(RouteName.addAttendance)),
              const SizedBox(height: 22),
              const SectionHeader('Your stats'),
              _StatGrid(c: c, open: _open),
              const SizedBox(height: 16),
              _FeesCard(c: c, onTap: () => _open(RouteName.viewfees)),
              const SizedBox(height: 22),
              const SectionHeader('Quick actions'),
              _QuickActions(open: _open),
              _EventsStrip(c: c, open: _open),
              _LatestNotifications(c: c, open: _open),
            ],
          ),
        );
      }),
    );
  }
}

// ---------------------------------------------------------------- app bar bell

class _BellButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _BellButton({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppPalette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppPalette.border),
            ),
            child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
          ),
          if (count > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                constraints: const BoxConstraints(minWidth: 18),
                decoration: BoxDecoration(
                  color: AppPalette.error,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppPalette.background, width: 1.5),
                ),
                child: Text(count > 9 ? '9+' : '$count',
                    textAlign: TextAlign.center,
                    style: appText(10, weight: FontWeight.w700)),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- hero

class _HeroCard extends StatelessWidget {
  final HomeController c;
  final VoidCallback onTap;
  const _HeroCard({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) => Obx(_body);

  Widget _body() {
    final p = c.profile;
    final trainer = c.dashboardData.value.data?.assignedTrainer?.name;
    final first = c.name.value.split(' ').first;
    final days = p.daysLeft;
    final progress = p.membershipProgress;

    return AppCard(
      onTap: onTap,
      gradient: AppPalette.headerGradient,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.greeting,
                        style: appText(13, color: AppPalette.textSecondary)),
                    const SizedBox(height: 2),
                    Text(first.isEmpty ? 'Welcome' : first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appText(24, weight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        const _Pill(icon: Icons.verified_rounded, text: 'MEMBER'),
                        if (p.fitnessGoal.isNotEmpty)
                          _Pill(icon: Icons.flag_rounded, text: p.fitnessGoal),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset('assets/images/gym_header.jpeg',
                    width: 84, height: 84, fit: BoxFit.cover),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.sports_rounded, size: 16, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Trainer: ${trainer ?? 'Not assigned yet'}',
                  overflow: TextOverflow.ellipsis,
                  style: appText(12.5, color: Colors.white),
                ),
              ),
            ],
          ),
          if (days != null) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Text(
                    p.membershipName.isEmpty ? 'Membership' : p.membershipName,
                    overflow: TextOverflow.ellipsis,
                    style: appText(12, color: Colors.white70),
                  ),
                ),
                Text(
                  days < 0
                      ? 'Expired'
                      : days == 0
                          ? 'Expires today'
                          : '$days days left',
                  style: appText(12,
                      weight: FontWeight.w700,
                      color: days <= 7 ? AppPalette.warning : AppPalette.secondary),
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Colors.white12,
                  color: days <= 7 ? AppPalette.warning : AppPalette.secondary,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Pill({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppPalette.secondary),
          const SizedBox(width: 4),
          Text(text, style: appText(10.5, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppPalette.error, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: appText(12, color: AppPalette.textSecondary))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- today

class _TodayCard extends StatelessWidget {
  final HomeController c;
  final VoidCallback onTap;
  const _TodayCard({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) => Obx(_body);

  Widget _body() {
    final inT = c.checkedInTime.value;
    final outT = c.checkedOutTime.value;
    final String title, subtitle, action;
    final Color color;
    final IconData icon;
    if (inT.isEmpty) {
      title = 'Not checked in yet';
      subtitle = 'Mark your attendance when you reach the gym';
      action = 'Check in';
      color = AppPalette.warning;
      icon = Icons.login_rounded;
    } else if (outT.isEmpty) {
      title = 'Checked in at ${fmtTime(inT)}';
      subtitle = 'Don\'t forget to check out after your session';
      action = 'Check out';
      color = AppPalette.secondary;
      icon = Icons.timer_outlined;
    } else {
      title = 'Workout done today';
      final spent = DateCalc.between(inT, outT);
      subtitle = '${fmtTime(inT)}  →  ${fmtTime(outT)}'
          '${spent == null ? '' : '  •  ${DateCalc.fmtDuration(spent)}'}';
      action = 'View';
      color = AppPalette.success;
      icon = Icons.check_circle_rounded;
    }

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(icon, color: color, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TODAY', style: appText(10.5, weight: FontWeight.w600, color: AppPalette.textSecondary)),
                const SizedBox(height: 2),
                Text(title, style: appText(14.5, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: appText(11.5, color: AppPalette.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(action, style: appText(12, weight: FontWeight.w700, color: color)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- stats

class _StatGrid extends StatelessWidget {
  final HomeController c;
  final Future<void> Function(String) open;
  const _StatGrid({required this.c, required this.open});

  @override
  Widget build(BuildContext context) => Obx(_body);

  Widget _body() {
    final d = c.dashboardData.value.data;
    final cards = [
      _StatCard(
        icon: Icons.class_rounded,
        label: 'Total classes',
        value: '${d?.totalClass ?? 0}',
        color: AppPalette.secondary,
        onTap: () => open(RouteName.viewclass),
      ),
      _StatCard(
        icon: Icons.sticky_note_2_rounded,
        label: 'Today\'s notes',
        value: '${d?.totalNote ?? 0}',
        color: AppPalette.warning,
        onTap: () => open(RouteName.viewworkout),
      ),
      _StatCard(
        icon: Icons.contacts_rounded,
        label: 'Total contacts',
        value: '${d?.totalContact ?? 0}',
        color: const Color(0xFF38BDF8),
        onTap: () => open(RouteName.viewtrainer),
      ),
      _StatCard(
        icon: Icons.sports_rounded,
        label: 'Trainer',
        value: d?.assignedTrainer?.name ?? 'N/A',
        color: AppPalette.success,
        onTap: () => open(RouteName.viewtrainer),
      ),
    ];
    return Column(
      children: [
        Row(children: [Expanded(child: cards[0]), const SizedBox(width: 12), Expanded(child: cards[1])]),
        const SizedBox(height: 12),
        Row(children: [Expanded(child: cards[2]), const SizedBox(width: 12), Expanded(child: cards[3])]),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBadge(icon, color: color, size: 36),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppPalette.textSecondary),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: appText(18, weight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: appText(11.5, color: AppPalette.textSecondary)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- fees

class _FeesCard extends StatelessWidget {
  final HomeController c;
  final VoidCallback onTap;
  const _FeesCard({required this.c, required this.onTap});

  @override
  Widget build(BuildContext context) => Obx(_body);

  Widget _body() {
    final f = c.fees;
    if (f.isLoading.value && f.fees.isEmpty) return const SizedBox.shrink();
    if (f.error.value.isNotEmpty || f.fees.isEmpty) return const SizedBox.shrink();

    final due = f.balance;
    final next = f.nextDue;
    final allPaid = due <= 0;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          IconBadge(allPaid ? Icons.verified_rounded : Icons.account_balance_wallet_rounded,
              color: allPaid ? AppPalette.success : AppPalette.warning, size: 46),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('FEES', style: appText(10.5, weight: FontWeight.w600, color: AppPalette.textSecondary)),
                const SizedBox(height: 2),
                Text(allPaid ? 'All fees paid' : '${fmtMoney(due)} due',
                    style: appText(15, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(
                  allPaid
                      ? 'Total paid ${fmtMoney(f.paid)}'
                      : next?.dueDate != null
                          ? 'Next due on ${fmtDate(next!.dueDate)}'
                          : '${f.pendingCount} pending payment(s)',
                  style: appText(11.5, color: AppPalette.textSecondary),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppPalette.textSecondary),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- quick actions

class _QuickActions extends StatelessWidget {
  final Future<void> Function(String) open;
  const _QuickActions({required this.open});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.fitness_center_rounded, 'Workout', RouteName.viewworkout, AppPalette.secondary),
      (Icons.class_rounded, 'Classes', RouteName.viewclass, const Color(0xFF38BDF8)),
      (Icons.how_to_reg_rounded, 'Check in', RouteName.addAttendance, AppPalette.success),
      (Icons.history_rounded, 'History', RouteName.viewattendance, AppPalette.warning),
      (Icons.currency_rupee_rounded, 'Fees', RouteName.viewfees, const Color(0xFFF472B6)),
      (Icons.event_rounded, 'Events', RouteName.viewevent, const Color(0xFFFB923C)),
      (Icons.sports_rounded, 'Trainer', RouteName.viewtrainer, const Color(0xFF34D399)),
      (Icons.person_rounded, 'Profile', RouteName.profile, AppPalette.textSecondary),
    ];
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 0.82,
      children: [
        for (final (icon, label, route, color) in items)
          AppCard(
            onTap: () => open(route),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconBadge(icon, color: color, size: 38),
                const SizedBox(height: 8),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: appText(11, weight: FontWeight.w500)),
              ],
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- events

class _EventsStrip extends StatelessWidget {
  final HomeController c;
  final Future<void> Function(String) open;
  const _EventsStrip({required this.c, required this.open});

  @override
  Widget build(BuildContext context) => Obx(_body);

  Widget _body() {
    final list = c.events.upcoming.take(5).toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          SectionHeader('Upcoming events',
              action: 'See all', onAction: () => open(RouteName.viewevent)),
          SizedBox(
            height: 112,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final e = list[i];
                final d = e.start;
                return SizedBox(
                  width: 230,
                  child: AppCard(
                    onTap: () => open(RouteName.viewevent),
                    gradient: AppPalette.headerGradient,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(d == null ? '--' : '${d.day}',
                                  style: appText(18, weight: FontWeight.w700)),
                              Text(d == null ? '' : fmtDate(e.startDate, pattern: 'MMM'),
                                  style: appText(11, color: AppPalette.secondary)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: appText(13.5, weight: FontWeight.w600)),
                              if (e.type != null) ...[
                                const SizedBox(height: 4),
                                Text(e.type!, style: appText(11, color: AppPalette.textSecondary)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- notifications

class _LatestNotifications extends StatelessWidget {
  final HomeController c;
  final Future<void> Function(String) open;
  const _LatestNotifications({required this.c, required this.open});

  @override
  Widget build(BuildContext context) => Obx(_body);

  Widget _body() {
    final n = c.notifications;
    final list = n.items.take(2).toList();
    if (list.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        children: [
          SectionHeader('Latest updates',
              action: 'See all', onAction: () => open(RouteName.notifications)),
          for (final item in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                onTap: () => open(RouteName.notifications),
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconBadge(Icons.campaign_rounded,
                        color: n.isUnread(item) ? AppPalette.secondary : AppPalette.textSecondary,
                        size: 36),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: appText(13.5, weight: FontWeight.w600)),
                          if (item.message.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(item.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: appText(12, color: AppPalette.textSecondary)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(timeAgo(item.createdAt),
                        style: appText(10.5, color: AppPalette.textSecondary)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
