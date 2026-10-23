import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:gymadmin/controller/createcategorytype.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/widgets/onboarding/showcase_keys.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/theme/app_palette.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Drawer Header
            DrawerHeader(
              // 60% black → 40% purple so gym_header blends in
              decoration: const BoxDecoration(
                gradient: AppPalette.headerGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset('assets/images/gym_header.jpeg', width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'FitDesk Dashboard',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Gym Management System',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            // 🔹 Main Navigation
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Showcase(
                    key: ShowcaseKeys.trainer,
                    title: 'Trainer',
                    description: 'Add and manage your trainers here.',
                    child: _buildListTile(Icons.person, 'Trainer', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.trainee,
                    title: 'Trainee',
                    description: 'Add and manage your gym members here.',
                    child: _buildListTile(Icons.groups, 'Trainee', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.classes,
                    title: 'Classes',
                    description: 'Create and schedule your gym\'s classes here.',
                    child: _buildListTile(Icons.class_, 'Classes', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.membership,
                    title: 'Membership',
                    description: 'Set up membership plans and pricing here.',
                    child: _buildListTile(Icons.card_membership, 'Membership', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.workouts,
                    title: 'Workouts',
                    description: 'Assign workout plans to your members here.',
                    child: _buildListTile(Icons.fitness_center, 'Workouts', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.attendance,
                    title: 'Attendance',
                    description: 'Mark and monitor daily attendance here.',
                    child: _buildListTile(Icons.check_circle, 'Attendance', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.fees,
                    title: 'Fees',
                    description: 'Track and collect membership fees here.',
                    child: _buildListTile(Icons.currency_rupee, 'Fees', context),
                  ),
                  _buildListTile(Icons.event, 'Event', context),

                  const Divider(thickness: 1, height: 30),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                    child: Text(
                      'System Configuration',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.textSecondary,
                      ),
                    ),
                  ),

                  Showcase(
                    key: ShowcaseKeys.category,
                    title: 'Category',
                    description: 'Organize your trainees into categories here.',
                    child: _buildListTile(Icons.category, 'Category', context),
                  ),
                  Showcase(
                    key: ShowcaseKeys.workoutActivity,
                    title: 'Workout Activity',
                    description: 'Define the workout activities your gym offers.',
                    child: _buildListTile(Icons.run_circle, 'Workout Activity', context),
                  ),
                  _buildListTile(Icons.event_note, 'Event Type', context),
                ],
              ),
            ),

            // 🔹 Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.pop(context); // close drawer
                  _showLogoutDialog(context);
                },
              ),
            ),

            // 🔹 Footer
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                '© 2026 Apex Innovation',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppPalette.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

ListTile _buildListTile(IconData icon, String title, BuildContext context) {
  return ListTile(
    leading: Icon(icon, color: AppPalette.secondary),
    title: Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    ),
    onTap: () {
      Navigator.pop(context); // close the drawer

      switch (title) {
        case 'Trainer':
          Get.toNamed(RouteName.Addtrainer);
          break;

        case 'Trainee':
         Get.toNamed(RouteName.Addtrainee);
          break;

        case 'Classes':
          Get.toNamed(RouteName.createclass);
          break;

        case 'Membership':
          Get.toNamed(RouteName.createmembership);
          break;

        case 'Workouts':
          Get.toNamed(RouteName.createworkout);
          break;

        case 'Attendance':
          Get.toNamed(RouteName.addAttendance);
          break;

          case 'Fees':
          Get.toNamed(RouteName.viewfees);
          break;

        case 'Event':
          Get.toNamed(RouteName.addevent);
          break;

          

        case 'Category':
          Get.toNamed(RouteName.CategorytypeController);
          break;

        case 'Workout Activity':
          Get.toNamed(RouteName.createactivity);
          break;

        case 'Event Type':
          Get.toNamed(RouteName.createeventtype);
          break;

        default:
          Get.snackbar(
            "Coming Soon",
            "$title page is under development.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orange.shade50,
            colorText: Colors.black87,
          );
      }

      // Optional: success message
      // Get.snackbar(
      //   "Navigation",
      //   "Opening $title page...",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.blue.shade50,
      //   colorText: Colors.black87,
      // );
    },
  );
}


  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout Confirmation'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
             Get.offAllNamed(RouteName.signin); // Navigate to login and clear history
             PrefManager().writeValue(key: PrefConst.login, value: false);
             PrefManager().clearPref(key:   PrefConst.token); // Clear token
              Get.snackbar(
                "Logged Out",
                "You have successfully logged out.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade50,
                colorText: Colors.black87,
              );
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
