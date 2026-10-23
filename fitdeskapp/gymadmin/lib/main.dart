
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:gymadmin/binding/splashbinding.dart';
import 'package:gymadmin/theme/app_palette.dart';
import 'package:gymadmin/widgets/routes/page_constants.dart';
import 'package:gymadmin/widgets/routes/page_routes.dart';






void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await GetStorage.init();


  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
 
        return ScreenUtilInit(
          designSize: const Size(480, 800),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'FitDesk Admin',
              theme: ThemeData(
                brightness: Brightness.dark,
                useMaterial3: true,
                // Same dark purple/violet/black palette as the dashboard
                // screen (see lib/theme/app_palette.dart) — every screen
                // that relies on Theme.of(context) defaults (Scaffold
                // background, Card color, default text/icon color, form
                // field fills, buttons) now automatically matches it,
                // instead of each screen hardcoding its own old brand blue.
                scaffoldBackgroundColor: AppPalette.background,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: AppPalette.primary,
                  brightness: Brightness.dark,
                  primary: AppPalette.primary,
                  secondary: AppPalette.secondary,
                  surface: AppPalette.surface,
                  onPrimary: AppPalette.textPrimary,
                  onSurface: AppPalette.textPrimary,
                  error: AppPalette.error,
                ),
                cardColor: AppPalette.surface,
                dividerColor: AppPalette.border,
                iconTheme: const IconThemeData(color: AppPalette.textPrimary),
                appBarTheme: const AppBarTheme(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: AppPalette.textPrimary,
                  elevation: 0,
                  centerTitle: true,
                ),
                inputDecorationTheme: InputDecorationTheme(
                  filled: true,
                  fillColor: AppPalette.surface,
                  hintStyle: const TextStyle(color: AppPalette.textSecondary),
                  labelStyle: const TextStyle(color: AppPalette.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppPalette.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppPalette.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppPalette.secondary, width: 1.5),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    foregroundColor: AppPalette.textPrimary,
                  ),
                ),
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: AppPalette.textPrimary,
                ),
                // Rounded sans-serif app-wide, so every screen (not just the
                // dashboard, which already sets Poppins per-widget) gets the
                // softer look — Material widgets that don't set their own
                // GoogleFonts style (buttons, dialogs, etc.) fall back to this.
                textTheme: GoogleFonts.poppinsTextTheme(ThemeData(brightness: Brightness.dark).textTheme),
                fontFamily: GoogleFonts.poppins().fontFamily,
              ),
              initialBinding: Splashscreenbinding(),
              initialRoute: RouteName.splash_screen,
              getPages: AppRoutes.appRoutes(),
            );
          },
        );
      
    
  }
}
