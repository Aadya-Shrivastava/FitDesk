import 'package:flutter/material.dart';

// ----------------------------------------------------------------------------
// APP-WIDE COLOR PALETTE
// Same colors as the dashboard screen's theme, made public so every other
// screen in the app can share them instead of each hardcoding its own
// (mismatched) brand color. If you ever need to re-theme the app, this is
// the one place to edit — main.dart's ThemeData reads from here, and any
// screen that needs a color outside what ThemeData already covers should
// import this file directly rather than hardcoding a new hex value.
// ----------------------------------------------------------------------------
class AppPalette {
  AppPalette._();

  static const primary = Color(0xFF6B21A8); // brinjal purple — deep, rich purple-violet
  static const secondary = Color(0xFFA78BFA); // lighter violet highlight
  static const accent = Color(0xFF4C1D95); // deep violet-indigo
  static const background = Color(0xFF000000); // true black — page background
  static const surface = Color(0xFF241535); // brinjal-tinted card/input background
  static const textPrimary = Color(0xFFFFFFFF); // main text (white)
  static const textSecondary = Color(0xFFB8A4E3); // muted/label text
  static const success = Color(0xFF22C55E); // green, for "up"/success indicators
  static const error = Color(0xFFEF4444); // red, for errors/destructive actions
  static const border = Color(0xFF3A2150); // subtle card/input border
  static const warning = Color(0xFFF59E0B); // amber, for "pending"/due indicators

  // Header gradient used wherever the gym_header image sits (drawer header,
  // dashboard hero, profile header, splash): ~60% black fading into ~40%
  // purple, so the image's dark-purple background blends into the card.
  static const headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [background, Color(0xFF12081E), primary],
    stops: [0.0, 0.6, 1.0],
  );
}
