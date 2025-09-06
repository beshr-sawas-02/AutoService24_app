import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF8A50);
  static const Color white = Color(0xFFFFFFFF);

  // Primary Color Variations
  static const Color primaryLight = Color(0xFFFFB84D);
  static const Color primaryDark = Color(0xFFCC7000);
  static const mediumGrey = Color(0xFF9E9E9E);
  static const lightGrey = Color(0xFFF5F5F5);

  // Background Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF666666);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textLight = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = Color(0xFFFF8C00);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF8A50), Color(0xFFFFB84D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient headerGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFCC7000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Shadow Colors
  static Color shadow = Colors.black.withValues(alpha: 0.1);
  static Color shadowLight = Colors.black.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.15);

  // Helper method to create MaterialColor
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor((0xFF000000 | (r << 16) | (g << 8) | b), swatch);
  }

  // Transparent variations
  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);
  static Color whiteWithOpacity(double opacity) => white.withValues(alpha: opacity);
  static Color blackWithOpacity(double opacity) => Colors.black.withValues(alpha: opacity);
}