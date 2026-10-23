import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymadmin/theme/app_palette.dart';

// There's no notifications API/backend wired up in this app yet, so this
// screen only ever shows the empty state below — it exists so the bell
// icon on the dashboard has somewhere real to go instead of doing nothing.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none, size: 64, color: AppPalette.textSecondary),
              const SizedBox(height: 16),
              Text(
                "No notifications yet",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppPalette.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                "You're all caught up. Alerts about your gym will show up here.",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 13, color: AppPalette.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
