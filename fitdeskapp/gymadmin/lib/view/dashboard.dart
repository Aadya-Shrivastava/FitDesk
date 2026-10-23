// ============================================================================
// DASHBOARD SCREEN (Purple / Violet theme)
//
// This file draws the gym owner's home screen. It is built out of small
// widgets, each one responsible for a single visible piece of the screen:
//
//   HomePage               -> the whole screen (puts everything together)
//   _DashboardAppBar        -> the top bar: menu button, bell, avatar
//   _WelcomeHeader           -> "Welcome back, <name>" + date, stacked over the bicep/dumbbell banner art
//   _StatusBanner             -> the "Gym up to date this week" card
//   _StatCard                  -> a small card showing one number (Trainers, Members)
//   _IncomeHeroCard              -> the big purple "Total income" card
//   _QuickActionTile               -> one square button in the "Quick actions" row
//   _IncomeExpenseChartCard          -> the bigger chart comparing income vs expense
//
// Reading tip: start at HomePage.build() at the top — it lists every section
// of the screen, in order, top to bottom.
// ============================================================================

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gymadmin/theme/app_palette.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:gymadmin/controller/dashboardcontroller.dart';
import 'package:gymadmin/widgets/appdrawer.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';

// ----------------------------------------------------------------------------
// COLORS
// Every color the screen uses lives here, named exactly like the design's
// color legend (Primary, Secondary, Accent, Background, Surface, etc.).
// If you ever need to re-theme the app, this is the only place to edit.
// ----------------------------------------------------------------------------
class _Palette {
  static const primary = Color(0xFF6B21A8); // brinjal purple — deep, rich purple-violet
  static const secondary = Color(0xFFA78BFA); // lighter violet highlight
  static const accent = Color(0xFF4C1D95); // deep violet-indigo, for the expense line (no pink)
  static const background = Color(0xFF000000); // true black — page background
  static const surface = Color(0xFF241535); // brinjal-tinted card background
  static const textPrimary = Color(0xFFFFFFFF); // main text (white)
  static const textSecondary = Color(0xFFB8A4E3); // muted/label text
  static const success = Color(0xFF22C55E); // green, for "up" indicators
  static const border = Color(0xFF3A2150); // subtle card border
}

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ShowCaseWidget wraps the Scaffold (not just the body) so its
    // showcase context also covers the Drawer, which is where the
    // first-time app tour's highlighted items live.
    return ShowCaseWidget(
      onFinish: controller.markAppTourSeen,
      builder: (showcaseContext) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: _Palette.background,
        // Lets the body's black paint all the way up behind the app bar
        // (which is fully transparent, see _DashboardAppBar), so the top of
        // the screen — status bar included — reads as one seamless black
        // area instead of a separate plain app bar sitting on top of it.
        extendBodyBehindAppBar: true,
        appBar: _DashboardAppBar(controller: controller),
        drawer: const AppDrawer(),
        body: Obx(() {
          // Only block the whole screen with a spinner on the very first
          // load. A pull-to-refresh also flips isLoading, but by then
          // hasLoadedOnce is already true, so it just keeps showing the
          // existing content underneath the RefreshIndicator's own spinner.
          if (controller.isLoading.value && !controller.hasLoadedOnce) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_Palette.primary),
              ),
            );
          }

          // Data has just finished loading — if this is a first-time user,
          // kick off the drawer walkthrough once the frame settles.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.startFirstTimeTourIfNeeded(showcaseContext, _scaffoldKey);
          });

          // Once data has loaded, show the real screen. Wrapped in a
          // RefreshIndicator so swiping down re-fetches the latest stats —
          // AlwaysScrollableScrollPhysics is required for the swipe gesture
          // to work even when the content is shorter than the screen.
          return RefreshIndicator(
            onRefresh: controller.fetchDashboard,
            color: _Palette.primary,
            backgroundColor: _Palette.surface,
            child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full-width banner — sits outside the padded/centered
              // column below so its gradient can reach both screen edges.
              _WelcomeHeader(name: controller.name.value),

              Padding(
                padding: EdgeInsets.all(16.w),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  const _StatusBanner(),
                  SizedBox(height: 16.h),

                  // Trainers + Members, side by side.
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: "Trainers",
                          subtitle: "Expert guidance",
                          valueRx: controller.totalTrainers,
                          icon: Icons.badge_outlined,
                          onTap: () => Get.toNamed(RouteName.viewtrainer),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _StatCard(
                          title: "Members",
                          subtitle: "Stronger together",
                          valueRx: controller.totalTrainees,
                          icon: Icons.groups_2_outlined,
                          onTap: () => Get.toNamed(RouteName.viewtrainee),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  _IncomeHeroCard(controller: controller),
                  SizedBox(height: 26.h),

                  Text(
                    "Quick Actions",
                    style: GoogleFonts.poppins(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: _Palette.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionTile(
                          label: "Classes",
                          icon: Icons.fitness_center,
                          onTap: () => Get.toNamed(RouteName.viewclass),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _QuickActionTile(
                          label: "Membership",
                          icon: Icons.card_membership,
                          onTap: () => Get.toNamed(RouteName.viewMembership),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _QuickActionTile(
                          label: "Workouts",
                          icon: Icons.sports_gymnastics,
                          onTap: () => Get.toNamed(RouteName.viewworkout),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _QuickActionTile(
                          label: "Attend.",
                          icon: Icons.event_available,
                          onTap: () => Get.toNamed(RouteName.viewattendance),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: _QuickActionTile(
                          label: "Fees",
                          icon: Icons.payments_outlined,
                          onTap: () => Get.toNamed(RouteName.viewfees),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 26.h),

                  _IncomeExpenseChartCard(controller: controller),
                  SizedBox(height: 18.h),

                  Center(
                    child: Text(
                      "© 2026 FitDesk | Apex Innovation",
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: _Palette.textSecondary,
                      ),
                    ),
                  ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
          );
        }),
      ),
    );
  }
}

// ============================== APP BAR ====================================
// Holds the menu (hamburger) button on the left — Flutter adds that
// automatically whenever a Scaffold has both an AppBar and a drawer — plus
// the notification bell and the profile avatar on the right. It's fully
// transparent so the header's purple gradient shows through behind it.
// ============================================================================

class _DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;
  const _DashboardAppBar({required this.controller});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      // Makes the OS status bar itself see-through (Android otherwise
      // paints it as a solid block using the app's primary color), so the
      // header's own gradient shows through the clock/battery row instead.
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      iconTheme: const IconThemeData(color: _Palette.textPrimary),
      actions: [
        IconButton(
          onPressed: () => Get.toNamed(RouteName.notifications),
          icon: const Icon(Icons.notifications_none),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.toNamed(RouteName.profile),
            child: Obx(() {
              final name = controller.name.value;
              final avatarLetter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "?";
              return Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _Palette.primary,
                  border: Border.all(color: _Palette.secondary, width: 2),
                ),
                child: Text(
                  avatarLetter,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ============================ WELCOME HEADER ================================
// The banner image itself is still unwrapped (no Container/border/shadow
// around it) — the only thing added on top is a full-bleed gradient color
// tint (via ShaderMask + BlendMode.color), so the image's own glow keeps
// its shape/brightness but is recolored into the same deep indigo-violet
// family (#3B0764-#6D28D9) as the rest of the dashboard's purple cards,
// instead of reading a shade lighter/pinker on its own. The greeting text
// is stacked on top, vertically centered in the banner (below the app bar
// row) alongside the icon, and the whole banner has rounded corners like
// every other card on the screen.
// ============================================================================

class _WelcomeHeader extends StatelessWidget {
  final String name;

  const _WelcomeHeader({required this.name});

  // Drop your banner image in at this exact path (inside the project) and
  // it will appear automatically — no other code changes needed.
  static const _bannerImagePath = 'assets/images/welcome_banner.png';

  // "lulu" -> "Lulu", "lulu sharma" -> "Lulu Sharma". Applied only here at
  // render time — the stored name (controller.name / the API value) is
  // left exactly as-is.
  static String _titleCase(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed
        .split(RegExp(r'\s+'))
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // Example: "Tue, 13 Aug"
    final todayLabel = DateFormat('EEE, d MMM').format(DateTime.now());

    // Push everything down below the (invisible) app bar and the phone's
    // status bar, so it doesn't sit underneath the hamburger/bell/avatar.
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final heroHeight = 130.h + topInset;

    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: SizedBox(
        width: double.infinity,
        height: heroHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // The image, tinted with a left-to-right gradient (matching
            // the same purple family as the income/stat cards) via
            // BlendMode.color — this recolors it using the shader's
            // hue+saturation while keeping the image's own luminance, so
            // the glow's shape and brightness are untouched, only its hue.
            ShaderMask(
              blendMode: BlendMode.color,
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF3B0764), Color(0xFF6D28D9)],
              ).createShader(bounds),
              child: Image.asset(
                _bannerImagePath,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                // Falls back to plain black (not a broken-image icon) if
                // the asset is ever missing.
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.black),
              ),
            ),

            // Dark scrim fading in from the left edge, so the greeting
            // stays readable even when a long name runs into the glowing
            // artwork on the right.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    stops: const [0.0, 0.45, 0.75],
                    colors: [
                      Colors.black.withOpacity(0.55),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // The welcome text, stacked over the plain-gradient left side
            // of the image and vertically centered within the banner
            // (below the app bar row, so it never overlaps the
            // hamburger/bell/avatar) — same vertical position as the icon
            // on the right instead of sitting low near the bottom edge.
            Positioned.fill(
              top: topInset,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Date pill sits first, so a long name can never
                        // push it out of the banner.
                        _DatePill(label: todayLabel),
                        const SizedBox(height: 10),
                        Text(
                          "Welcome back,",
                          style: GoogleFonts.poppins(
                            fontSize: 21.sp,
                            color: _Palette.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 5),
                        // Long gym names shrink (down to minFontSize) to fit
                        // in at most 2 lines and in whatever height is left
                        // in the banner; anything still too long ends in "…".
                        Flexible(
                          child: AutoSizeText(
                            _titleCase(name),
                            maxLines: 2,
                            minFontSize: 22.sp.roundToDouble(),
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 40.sp.roundToDouble(),
                              fontWeight: FontWeight.w800,
                              color: _Palette.textPrimary,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Small translucent "📅 Thu, 15 Oct" chip shown at the top of the welcome
// header.
class _DatePill extends StatelessWidget {
  final String label;

  const _DatePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today_rounded, size: 13.sp, color: _Palette.textSecondary),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: _Palette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================ STATUS BANNER =================================
// The purple "Gym up to date this week" card near the top of the screen.
// ============================================================================

class _StatusBanner extends StatelessWidget {
  const _StatusBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // 60% black → 40% purple so the gym_header image blends in.
        gradient: AppPalette.headerGradient,
        border: Border.all(color: AppPalette.border),
        boxShadow: [
          BoxShadow(color: _Palette.primary.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset('assets/images/gym_header.jpeg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Gym up to date this week",
                  style: GoogleFonts.poppins(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Don't stop now. You're on fire!",
                  style: GoogleFonts.poppins(
                    fontSize: 11.5.sp,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.white),
        ],
      ),
    );
  }
}

// =============================== STAT CARD ==================================
// A small dark card that shows one number, e.g. "6 Trainers".
// ============================================================================

class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final RxString valueRx;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.subtitle,
    required this.valueRx,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Palette.border),
        ),
        // Stack (not clipped) so the watermark icon below can bleed past
        // the card's own edge instead of being boxed in by the padding.
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Large, barely-there icon watermark bleeding off the
            // bottom-right corner — decoration only, sits behind the
            // real content.
            Positioned(
              right: -16,
              bottom: -16,
              child: Icon(icon, size: 84, color: _Palette.secondary.withOpacity(0.06)),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _Palette.primary.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  // Secondary (the lighter purple) reads brighter than
                  // primary against this very dark card, which is what
                  // gives it that "electric" pop instead of looking flat.
                  child: Icon(icon, color: _Palette.secondary, size: 20),
                ),
                const SizedBox(height: 12),
                // valueRx is reactive, so wrapping just this Text in Obx()
                // means only the number redraws when it changes.
                Obx(() {
                  return Text(
                    valueRx.value,
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: _Palette.textPrimary,
                    ),
                  );
                }),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: _Palette.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 10.5.sp,
                    color: _Palette.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ INCOME HERO CARD ===============================
// The big purple card that shows total income and how it's trending.
// ============================================================================

class _IncomeHeroCard extends StatelessWidget {
  final HomeController controller;
  const _IncomeHeroCard({required this.controller});

  // Percent change between the last two monthly points in incomeData — null
  // when there isn't enough real data yet to compare (fewer than 2 months,
  // or the earlier one is 0), so the badge below just doesn't render rather
  // than making up a number.
  static double? _monthOverMonthChange(List<FlSpot> points) {
    if (points.length < 2) return null;
    final previous = points[points.length - 2].y;
    final current = points[points.length - 1].y;
    if (previous == 0) return null;
    return ((current - previous) / previous) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(RouteName.viewfees),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_Palette.primary, Color(0xFF2E0F4D)],
          ),
          // Same "electric" glow used on the header avatar and status banner.
          boxShadow: [
            BoxShadow(color: _Palette.primary.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total income",
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                Obx(() {
                  // .toList() (rather than handing the raw RxList to the
                  // helper directly) is what tells GetX this Obx depends on
                  // incomeData.
                  final pct = _monthOverMonthChange(controller.incomeData.toList());
                  if (pct == null) return const SizedBox.shrink();
                  final isUp = pct >= 0;
                  final color = isUp ? _Palette.success : const Color(0xFFF87171);
                  return Row(
                    children: [
                      Icon(isUp ? Icons.arrow_upward : Icons.arrow_downward, size: 14, color: color),
                      Text(
                        " ${pct.abs().toStringAsFixed(0)}%",
                        style: GoogleFonts.poppins(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 6),
            Obx(() {
              return Text(
                controller.todayIncome.value,
                style: GoogleFonts.poppins(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              );
            }),
            const SizedBox(height: 2),
            Text(
              "vs last month",
              style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.white.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================ QUICK ACTION TILE ==============================
// One square button in the "Quick actions" row (e.g. "Classes").
// Tapping it opens the matching screen.
// ============================================================================

class _QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _Palette.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _Palette.primary.withOpacity(0.18),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _Palette.secondary, size: 15),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9.sp,
                fontWeight: FontWeight.w700,
                color: _Palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================== INCOME VS EXPENSE CHART ===========================
// The bigger card near the bottom, comparing income and expense over time,
// with a toggle to switch between the last 6 months and the last 12.
//
// This is the only StatefulWidget on the screen, because the 6M / 1Y toggle
// needs to remember which option is selected.
// ============================================================================

class _IncomeExpenseChartCard extends StatefulWidget {
  final HomeController controller;
  const _IncomeExpenseChartCard({required this.controller});

  @override
  State<_IncomeExpenseChartCard> createState() => _IncomeExpenseChartCardState();
}

class _IncomeExpenseChartCardState extends State<_IncomeExpenseChartCard> {
  bool _showLast6Months = true;

  // Keeps only the last [count] points, then shifts their x-values so the
  // first visible point starts at 0 (otherwise the chart would leave empty
  // space on the left where the trimmed-off points used to be).
  List<FlSpot> _lastPoints(List<FlSpot> allPoints, int count) {
    if (allPoints.length <= count) return allPoints;
    final trimmed = allPoints.sublist(allPoints.length - count);
    return List.generate(trimmed.length, (i) => FlSpot(i.toDouble(), trimmed[i].y));
  }

  List<String> _lastMonthLabels(List<String> allMonths, int dataLength, int count) {
    final monthsWithData = allMonths.sublist(0, dataLength.clamp(0, allMonths.length));
    if (monthsWithData.length <= count) return monthsWithData;
    return monthsWithData.sublist(monthsWithData.length - count);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = widget.controller;
      final monthsToShow = _showLast6Months ? 6 : 12;

      final incomePoints = _lastPoints(controller.incomeData, monthsToShow);
      final expensePoints = _lastPoints(controller.expenseData, monthsToShow);
      final monthLabels = _lastMonthLabels(controller.months, controller.incomeData.length, monthsToShow);

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _Palette.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _Palette.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Income vs Expense",
                  style: GoogleFonts.poppins(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: _Palette.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    _RangeToggleButton(
                      label: "6M",
                      selected: _showLast6Months,
                      onTap: () => setState(() => _showLast6Months = true),
                    ),
                    const SizedBox(width: 6),
                    _RangeToggleButton(
                      label: "1Y",
                      selected: !_showLast6Months,
                      onTap: () => setState(() => _showLast6Months = false),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                _LegendDot(label: "Income", color: _Palette.primary),
                SizedBox(width: 14),
                _LegendDot(label: "Expense", color: _Palette.accent),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _IncomeExpenseLineChart(
                incomePoints: incomePoints,
                expensePoints: expensePoints,
                monthLabels: monthLabels,
              ),
            ),
          ],
        ),
      );
    });
  }
}

// The actual chart drawing for the card above — kept separate so the
// state-management code (the toggle) and the drawing code don't mix.
class _IncomeExpenseLineChart extends StatelessWidget {
  final List<FlSpot> incomePoints;
  final List<FlSpot> expensePoints;
  final List<String> monthLabels;

  const _IncomeExpenseLineChart({
    required this.incomePoints,
    required this.expensePoints,
    required this.monthLabels,
  });

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 0,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= monthLabels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    monthLabels[index],
                    style: GoogleFonts.poppins(fontSize: 10.sp, color: _Palette.textSecondary),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            color: _Palette.primary,
            barWidth: 2.5,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [_Palette.primary.withOpacity(0.25), _Palette.primary.withOpacity(0.0)],
              ),
            ),
            spots: incomePoints,
          ),
          LineChartBarData(
            isCurved: true,
            color: _Palette.accent,
            barWidth: 2.5,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
            spots: expensePoints,
          ),
        ],
      ),
    );
  }
}

// Small "6M" / "1Y" pill button used above the chart.
class _RangeToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeToggleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _Palette.primary : _Palette.background,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _Palette.textSecondary,
          ),
        ),
      ),
    );
  }
}

// A colored dot + label, used in the chart legend ("• Income", "• Expense").
class _LegendDot extends StatelessWidget {
  final String label;
  final Color color;
  const _LegendDot({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _Palette.textSecondary),
        ),
      ],
    );
  }
}
