class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://192.168.201.167:8000';
  static const String wsUrl = 'ws://192.168.201.167:3005';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';

  // App Info
  static const String appName = 'AutoService24';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Your Car Service Partner';

  // Default Values
  static const double defaultLatitude = 33.5138;
  static const double defaultLongitude = 36.2765;
  static const String defaultCity = 'Damascus';
  static const String defaultCountry = 'Syria';

  // Validation Rules
  static const int minPasswordLength = 6;
  static const int minUsernameLength = 3;
  static const int maxDescriptionLength = 500;

  // UI Constants
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 10.0;
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  // Image Constraints
  static const int maxImageSizeMB = 5;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Chat Constants
  static const int maxMessageLength = 1000;
  static const int messagesPerPage = 50;

  // Service Types (matching backend enum)
  static const List<String> serviceTypes = [
    'Vehicle inspection & emissions test',
    'Change oil',
    'Change tires',
    'Remove & install tires',
    'Cleaning',
    'Test with diagnostic',
    'Pre-TÜV check',
    'Balance tires',
    'Adjust wheel alignment',
    'Polish',
    'Change brake fluid',
  ];

  // Error Messages
  static const String networkError = 'Network connection failed';
  static const String serverError = 'Server error occurred';
  static const String unknownError = 'An unknown error occurred';
  static const String loginRequired = 'Please login to continue';
  static const String permissionDenied = 'Permission denied';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String registerSuccess = 'Registration successful';
  static const String updateSuccess = 'Updated successfully';
  static const String deleteSuccess = 'Deleted successfully';
  static const String saveSuccess = 'Saved successfully';
}

// class AppColors {
//   // Primary Colors
//   static const primaryOrange = Color(0xFFFF9800);
//   static const primaryWhite = Color(0xFFFFFFFF);
//   static const splashBackground = Color(0xFF2D2D2D);
//
//   // Secondary Colors
//   static const lightGrey = Color(0xFFF5F5F5);
//   static const mediumGrey = Color(0xFF9E9E9E);
//   static const darkGrey = Color(0xFF424242);
//
//   // Status Colors
//   static const success = Color(0xFF4CAF50);
//   static const error = Color(0xFFF44336);
//   static const warning = Color(0xFFFF9800);
//   static const info = Color(0xFF2196F3);
//
//   // Text Colors
//   static const textPrimary = Color(0xFF212121);
//   static const textSecondary = Color(0xFF757575);
//   static const textHint = Color(0xFFBDBDBD);
// }

class AppSizes {
  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Text Sizes
  static const double textSmall = 12.0;
  static const double textMedium = 14.0;
  static const double textLarge = 16.0;
  static const double textXLarge = 18.0;
  static const double textXXLarge = 20.0;
  static const double titleSmall = 22.0;
  static const double titleMedium = 24.0;
  static const double titleLarge = 28.0;

  // Spacing
  static const double spaceXSmall = 4.0;
  static const double spaceSmall = 8.0;
  static const double spaceMedium = 16.0;
  static const double spaceLarge = 24.0;
  static const double spaceXLarge = 32.0;
  static const double spaceXXLarge = 48.0;
}