import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/theme/app_palette.dart';
import 'package:gymadmin/widgets/localStorage/PrefConst.dart';
import 'package:gymadmin/widgets/localStorage/localstorage.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _loadProfile() async {
    final name = await PrefManager().readValue(key: PrefConst.userName);
    final email = await PrefManager().readValue(key: PrefConst.userEmail);
    final phone = await PrefManager().readValue(key: PrefConst.userPhone);
    return {
      'name': (name ?? '').toString(),
      'email': (email ?? '').toString(),
      'phone': (phone ?? '').toString(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _loadProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final name = snapshot.data!['name']!;
          final email = snapshot.data!['email']!;
          final phone = snapshot.data!['phone']!;
          final avatarLetter = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : "?";

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: Container(
                  width: 84,
                  height: 84,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppPalette.primary,
                    border: Border.all(color: AppPalette.secondary, width: 2),
                  ),
                  child: Text(
                    avatarLetter,
                    style: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  name.trim().isEmpty ? "Gym Owner" : name.trim(),
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: AppPalette.textPrimary),
                ),
              ),
              const SizedBox(height: 28),
              _InfoTile(icon: Icons.email_outlined, label: "Email", value: email.trim().isEmpty ? "Not set" : email.trim()),
              const SizedBox(height: 12),
              _InfoTile(icon: Icons.phone_outlined, label: "Phone", value: phone.trim().isEmpty ? "Not set" : phone.trim()),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Get.offAllNamed(RouteName.signin);
              await PrefManager().writeValue(key: PrefConst.login, value: false);
              await PrefManager().clearPref(key: PrefConst.token);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: AppPalette.secondary, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.poppins(fontSize: 11.5, color: AppPalette.textSecondary)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppPalette.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
