import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'app/lang/Translations.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/app_binding.dart';
import 'app/utils/constants.dart';
import 'app/utils/storage_service.dart';
import 'app/config/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MapboxOptions.setAccessToken(AppConstants.mapboxAccessToken);

  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Auto Service 24',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBinding(),
      translations: AppTranslations(),
      locale: _getInitialLocale(),
      fallbackLocale: const Locale('de'),
      theme: ThemeData(
        // Custom Primary Color Swatch
        primarySwatch: AppColors.createMaterialColor(AppColors.primary),
        primaryColor: AppColors.primary,
        primaryColorDark: AppColors.primaryDark,
        primaryColorLight: AppColors.primaryLight,

        // Color Scheme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: AppColors.createMaterialColor(AppColors.primary),
          brightness: Brightness.light,
        ).copyWith(
          secondary: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
        ),

        // Background Colors
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.white,

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: AppColors.textSecondary),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // BottomNavigationBar Theme
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textSecondary,
          backgroundColor: AppColors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        // Card Theme
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.borderFocus, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.error, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: const TextStyle(color: AppColors.textHint),
        ),

        // FloatingActionButton Theme
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 4,
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: AppColors.primary,
          linearTrackColor: AppColors.primaryWithOpacity(0.2),
          circularTrackColor: AppColors.primaryWithOpacity(0.2),
        ),

        // Chip Theme
        chipTheme: const ChipThemeData(
          backgroundColor: AppColors.grey100,
          selectedColor: AppColors.primary,
          secondarySelectedColor: AppColors.primaryDark,
          labelStyle: TextStyle(color: AppColors.textPrimary),
          secondaryLabelStyle: TextStyle(color: AppColors.white),
          brightness: Brightness.light,
        ),

        // Dialog Theme
        dialogTheme: DialogTheme(
          backgroundColor: AppColors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),

        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.grey800,
          contentTextStyle: const TextStyle(color: AppColors.white),
          actionTextColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Text Theme
        textTheme: const TextTheme(
          displayLarge: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodySmall: TextStyle(color: AppColors.textSecondary),
          labelLarge: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: AppColors.textSecondary),
        ),

        // Icon Theme
        iconTheme: const IconThemeData(
          color: AppColors.textSecondary,
          size: 24,
        ),
        primaryIconTheme: const IconThemeData(
          color: AppColors.white,
          size: 24,
        ),

        // List Tile Theme
        listTileTheme: ListTileThemeData(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: AppColors.white,
          selectedTileColor: AppColors.primaryWithOpacity(0.1),
          iconColor: AppColors.textSecondary,
          textColor: AppColors.textPrimary,
          selectedColor: AppColors.primary,
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }

  Locale _getInitialLocale() {
    final savedLang = StorageService.getLanguage();
    if (savedLang != null && savedLang.isNotEmpty) {
      return Locale(savedLang);
    }
    return const Locale('de');
  }
}
