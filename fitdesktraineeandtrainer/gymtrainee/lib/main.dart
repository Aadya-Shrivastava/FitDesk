
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';

import 'package:gymtrainee/Bindings/splashbinding.dart';
import 'package:gymtrainee/theme/app_palette.dart';import 'package:gymtrainee/widgets/routes/page_constants.dart';
import 'package:gymtrainee/widgets/routes/page_routes.dart';






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
                drawerTheme: const DrawerThemeData(backgroundColor: AppPalette.surface),
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
              ),
              initialBinding: Splashscreenbinding(),
              initialRoute: RouteName.splash_screen,
              getPages: AppRoutes.appRoutes(),
            );
          },
        );
      
    
  }
}
