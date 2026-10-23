import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:gymtrainee/theme/app_palette.dart';

/// Small shared building blocks for the trainee screens.

TextStyle appText(double size,
        {FontWeight weight = FontWeight.w400, Color color = AppPalette.textPrimary}) =>
    GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);

AppBar simpleAppBar(String title, {List<Widget>? actions}) => AppBar(
      title: Text(title, style: appText(18, weight: FontWeight.w600)),
      centerTitle: false,
      backgroundColor: AppPalette.background,
      foregroundColor: Colors.white,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppPalette.headerGradient),
      ),
      actions: actions,
    );

class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Gradient? gradient;
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(18);
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: gradient == null ? AppPalette.surface : null,
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: AppPalette.border),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          splashColor: AppPalette.secondary.withValues(alpha: 0.12),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: appText(16, weight: FontWeight.w600))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!,
                  style: appText(12.5,
                      weight: FontWeight.w600, color: AppPalette.secondary)),
            ),
        ],
      ),
    );
  }
}

class IconBadge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  const IconBadge(this.icon, {super.key, required this.color, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }
}

/// Circle avatar from a network photo, falling back to initials.
class UserAvatar extends StatelessWidget {
  final String url;
  final String initials;
  final double size;
  const UserAvatar({super.key, required this.url, required this.initials, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      color: AppPalette.accent,
      alignment: Alignment.center,
      child: Text(initials,
          style: appText(size * 0.38, weight: FontWeight.w700)),
    );
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppPalette.secondary.withValues(alpha: 0.6), width: 1.5),
      ),
      child: ClipOval(
        child: url.isEmpty
            ? fallback
            : Image.network(url,
                fit: BoxFit.cover, errorBuilder: (_, _, _) => fallback),
      ),
    );
  }
}

// ---------------- formatting ----------------

String fmtDate(String? raw, {String pattern = 'dd MMM yyyy'}) {
  final d = DateTime.tryParse(raw ?? '');
  if (d == null) return (raw == null || raw.trim().isEmpty) ? '-' : raw;
  return DateFormat(pattern).format(d.toLocal());
}

String fmtMoney(num v) {
  final f = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: v % 1 == 0 ? 0 : 2);
  return f.format(v);
}

String timeAgo(String? raw) {
  final d = DateTime.tryParse(raw ?? '')?.toLocal();
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('dd MMM').format(d);
}

/// "07:05:00" / "07:05" -> "07:05 AM"
String fmtTime(String? raw) {
  final v = (raw ?? '').trim();
  if (v.isEmpty) return '-';
  final parts = v.split(':');
  final h = int.tryParse(parts[0]);
  final m = parts.length > 1 ? int.tryParse(parts[1]) : 0;
  if (h == null || m == null) return v;
  return DateFormat('hh:mm a').format(DateTime(2000, 1, 1, h, m));
}
