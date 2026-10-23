import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gymtrainee/controller/profilecontroller.dart';
import 'package:gymtrainee/widgets/localStorage/localstorage.dart';
import 'package:gymtrainee/widgets/routes/page_constants.dart';
import 'package:gymtrainee/theme/app_palette.dart';
import 'package:gymtrainee/widgets/ui_kit.dart';

class AppDrawer extends StatelessWidget {
  /// Route of the screen the drawer is opened from, to highlight it.
  final String current;
  const AppDrawer({super.key, this.current = ''});

  static const _items = <(IconData, String, String)>[
    (Icons.dashboard_rounded, 'Dashboard', RouteName.dashboard),
    (Icons.person_rounded, 'My Profile', RouteName.profile),
    (Icons.fitness_center_rounded, 'Workouts', RouteName.viewworkout),
    (Icons.class_rounded, 'Classes', RouteName.viewclass),
    (Icons.sports_rounded, 'Trainer', RouteName.viewtrainer),
    (Icons.how_to_reg_rounded, 'Check in / out', RouteName.addAttendance),
    (Icons.history_rounded, 'Attendance history', RouteName.viewattendance),
    (Icons.currency_rupee_rounded, 'Fees', RouteName.viewfees),
    (Icons.event_rounded, 'Events', RouteName.viewevent),
    (Icons.notifications_rounded, 'Notifications', RouteName.notifications),
  ];

  @override
  Widget build(BuildContext context) {
    final profile = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : null;

    return Drawer(
      backgroundColor: AppPalette.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 🔹 Drawer Header — 60% black → 40% purple so gym_header blends in
          Container(
            decoration: const BoxDecoration(gradient: AppPalette.headerGradient),
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/gym_header.jpeg',
                      width: 64, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FitDesk', style: appText(20, weight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        (profile?.name.isNotEmpty ?? false)
                            ? profile!.name
                            : 'Member',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: appText(13, color: Colors.white),
                      ),
                      if ((profile?.email.isNotEmpty ?? false))
                        Text(profile!.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: appText(11, color: AppPalette.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🔹 Main Navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              children: [
                for (final (icon, title, route) in _items)
                  _tile(context, icon, title, route),
              ],
            ),
          ),

          // 🔹 Logout Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout_rounded, color: AppPalette.error),
              label: Text('Logout',
                  style: appText(14, weight: FontWeight.w600, color: AppPalette.error)),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppPalette.error.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                Navigator.pop(context); // close drawer
                showLogoutDialog();
              },
            ),
          ),

          // 🔹 Footer
          Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 12 + MediaQuery.of(context).padding.bottom),
            child: Text(
              '© 2026 Apex Innovation',
              textAlign: TextAlign.center,
              style: appText(11, color: AppPalette.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String route) {
    final selected = route == current;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        dense: true,
        selected: selected,
        selectedTileColor: AppPalette.primary.withValues(alpha: 0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(icon, color: selected ? Colors.white : AppPalette.secondary),
        title: Text(title,
            style: appText(14.5,
                weight: selected ? FontWeight.w600 : FontWeight.w500)),
        onTap: () {
          Navigator.pop(context); // close the drawer
          if (selected) return;
          if (route == RouteName.dashboard) {
            Get.until((r) => r.settings.name == RouteName.dashboard);
          } else {
            Get.toNamed(route);
          }
        },
      ),
    );
  }
}

void showLogoutDialog() {
  Get.dialog(
    AlertDialog(
      backgroundColor: AppPalette.surface,
      title: const Text('Logout'),
      content: const Text('Are you sure you want to log out?'),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppPalette.error),
          onPressed: () async {
            // Clears token, cached profile and attendance cache.
            await PrefManager().clearPref(key: '');
            Get.offAllNamed(RouteName.signin); // Navigate to login and clear history
            Get.snackbar(
              "Logged Out",
              "You have successfully logged out.",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppPalette.surface,
              colorText: AppPalette.textPrimary,
            );
          },
          child: const Text('Logout'),
        ),
      ],
    ),
  );
}
