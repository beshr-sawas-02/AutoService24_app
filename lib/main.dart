import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'app/routes/app_routes.dart';
import 'app/app_module.dart';
import 'app/utils/storage_service.dart';
import 'app/utils/network_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.init();

  // Initialize dependencies
  AppModule.init();

  // Initialize network service
  Get.put(NetworkService(), permanent: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'CarServiceHub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Custom Primary Color Swatch
        primarySwatch: _createMaterialColor(Color(0xFFFF8A50)),
        primaryColor: Color(0xFFFF8A50),
        primaryColorDark: Color(0xFFFF6B35),
        primaryColorLight: Color(0xFFFFB380),

        // Color Scheme (replaces accentColor)
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: _createMaterialColor(Color(0xFFFF8A50)),
          brightness: Brightness.light,
        ).copyWith(
          secondary: Color(0xFFFF6B35),
          primary: Color(0xFFFF8A50),
          surface: Colors.white,
          background: Color(0xFFF5F5F5),
        ),

        // Background Colors
        scaffoldBackgroundColor: Color(0xFFF5F5F5), // Light grey background
        canvasColor: Colors.white,

        // AppBar Theme
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black54),
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),

        // BottomNavigationBar Theme
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFFFF8A50),
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
        ),

        // Button Themes
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF8A50),
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Color(0xFFFF8A50),
            side: BorderSide(color: Color(0xFFFF8A50), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFFFF8A50),
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),

        // Card Theme
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        ),

        // Input Decoration Theme
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Color(0xFFFF8A50), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: TextStyle(color: Colors.grey[500]),
        ),

        // FloatingActionButton Theme
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFFF8A50),
          foregroundColor: Colors.white,
          elevation: 4,
        ),

        // Progress Indicator Theme
        progressIndicatorTheme: ProgressIndicatorThemeData(
          color: Color(0xFFFF8A50),
          linearTrackColor: Color(0xFFFF8A50).withOpacity(0.2),
          circularTrackColor: Color(0xFFFF8A50).withOpacity(0.2),
        ),

        // Chip Theme
        chipTheme: ChipThemeData(
          backgroundColor: Colors.grey[100]!,
          selectedColor: Color(0xFFFF8A50),
          secondarySelectedColor: Color(0xFFFF6B35),
          labelStyle: TextStyle(color: Colors.black87),
          secondaryLabelStyle: TextStyle(color: Colors.white),
          brightness: Brightness.light,
        ),

        // Dialog Theme
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          contentTextStyle: TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
        ),

        // Snackbar Theme
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Colors.black87,
          contentTextStyle: TextStyle(color: Colors.white),
          actionTextColor: Color(0xFFFF8A50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),

        // Text Theme
        textTheme: TextTheme(
          displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          displaySmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          headlineMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          headlineSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          titleLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          titleSmall: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
          bodySmall: TextStyle(color: Colors.grey[600]),
          labelLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(color: Colors.grey[600]),
        ),

        // Icon Theme
        iconTheme: IconThemeData(
          color: Colors.grey[600],
          size: 24,
        ),
        primaryIconTheme: IconThemeData(
          color: Colors.white,
          size: 24,
        ),

        // List Tile Theme
        listTileTheme: ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tileColor: Colors.white,
          selectedTileColor: Color(0xFFFF8A50).withOpacity(0.1),
          iconColor: Colors.grey[600],
          textColor: Colors.black87,
          selectedColor: Color(0xFFFF8A50),
        ),
      ),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
    );
  }

  // Helper method to create MaterialColor from a single color
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });

    return MaterialColor(color.value, swatch);
  }
}