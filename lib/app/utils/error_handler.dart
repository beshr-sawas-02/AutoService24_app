import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';

class ErrorHandler {
  // Handle Dio errors with user-friendly messages
  static String handleDioError(DioException error) {
    // Log technical details for developers only
    if (kDebugMode) {
      debugPrint('══════════════════════════════════════');
      debugPrint('Dio Error Type: ${error.type}');
      debugPrint('Status Code: ${error.response?.statusCode}');
      debugPrint('Response Data: ${error.response?.data}');
      debugPrint('Error Message: ${error.message}');
      debugPrint('══════════════════════════════════════');
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'connection_timeout'.tr;

      case DioExceptionType.sendTimeout:
        return 'request_timeout'.tr;

      case DioExceptionType.receiveTimeout:
        return 'server_timeout'.tr;

      case DioExceptionType.badResponse:
        return _handleHttpError(error.response?.statusCode, error.response?.data);

      case DioExceptionType.cancel:
        return 'request_cancelled'.tr;

      case DioExceptionType.connectionError:
        return 'connection_error'.tr;

      case DioExceptionType.unknown:
        return 'unexpected_error'.tr;

      default:
        return 'something_went_wrong'.tr;
    }
  }

  // Handle HTTP status codes with user-friendly messages
  static String _handleHttpError(int? statusCode, dynamic responseData) {
    String message = '';

    // Try to extract error message from response
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? responseData['error'] ?? '';
    }

    // Log the technical message for developers
    if (kDebugMode && message.isNotEmpty) {
      debugPrint('Server Error Message: $message');
    }

    switch (statusCode) {
      case 400:
        return 'bad_request'.tr;

      case 401:
        return 'unauthorized_login_again'.tr;

      case 403:
        return 'access_forbidden'.tr;

      case 404:
        return 'resource_not_found'.tr;

      case 409:
        return 'resource_already_exists'.tr;

      case 422:
        return 'invalid_data_provided'.tr;

      case 429:
        return 'too_many_requests'.tr;

      case 500:
        return 'server_error'.tr;

      case 502:
        return 'bad_gateway'.tr;

      case 503:
        return 'service_unavailable'.tr;

      case 504:
        return 'gateway_timeout'.tr;

      default:
        return 'server_error_occurred'.tr;
    }
  }

  // Handle general exceptions with user-friendly messages
  static String handleGeneralError(dynamic error) {
    // Log technical error for developers
    if (kDebugMode) {
      debugPrint('══════════════════════════════════════');
      debugPrint('General Error: $error');
      debugPrint('Error Type: ${error.runtimeType}');
      debugPrint('══════════════════════════════════════');
    }

    if (error is DioException) {
      return handleDioError(error);
    }

    if (error is FormatException) {
      return 'invalid_data_format'.tr;
    }

    if (error is TypeError) {
      return 'data_type_error'.tr;
    }

    // Don't show technical error messages to users
    return 'something_went_wrong'.tr;
  }

  // Show error dialog (for critical errors)
  static void showErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: Text('cancel'.tr),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('retry'.tr),
            ),
          if (onRetry == null && onCancel == null)
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text('ok'.tr),
            ),
        ],
      ),
    );
  }

  // Log error (only in debug mode)
  static void logError(dynamic error, StackTrace? stackTrace) {
    if (kDebugMode) {
      debugPrint('══════════════════════════════════════');
      debugPrint('Error Log: $error');
      if (stackTrace != null) {
        debugPrint('StackTrace: $stackTrace');
      }
      debugPrint('══════════════════════════════════════');
    }

    // In production, send to crash reporting service like Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  // Handle and show error (main method to use)
  static void handleAndShowError(
      dynamic error, {
        VoidCallback? onRetry,
        bool silent = false,
      }) {
    String errorMessage = handleGeneralError(error);

    // Log the error for developers
    logError(error, null);

    // If silent mode, don't show anything to user
    if (silent) return;

    // Show error to user with user-friendly message
    if (onRetry != null) {
      showErrorDialog(
        title: 'error'.tr,
        message: errorMessage,
        onRetry: onRetry,
        onCancel: () => Get.back(),
      );
    } else {
      _showErrorSnackbar(errorMessage);
    }
  }

  // Show user-friendly error snackbar
  static void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
      colorText: AppColors.error,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: AppColors.error),
    );
  }

  // Handle validation errors
  static Map<String, String> handleValidationErrors(Map<String, dynamic>? errors) {
    Map<String, String> fieldErrors = {};

    if (errors != null) {
      errors.forEach((key, value) {
        if (value is List) {
          fieldErrors[key] = value.first.toString();
        } else {
          fieldErrors[key] = value.toString();
        }
      });
    }

    return fieldErrors;
  }

  // Show validation errors
  static void showValidationErrors(Map<String, String> errors) {
    String message = errors.values.join('\n');
    showErrorDialog(
      title: 'validation_error'.tr,
      message: message,
    );
  }

  // Handle auth errors specifically
  static void handleAuthError(dynamic error) {
    String errorMessage = handleGeneralError(error);

    // If it's an auth error, redirect to login
    if (error is DioException && error.response?.statusCode == 401) {
      Get.offAllNamed('/login');
      _showErrorSnackbar('session_expired'.tr);
    } else {
      _showErrorSnackbar(errorMessage);
    }
  }

  // Show success message
  static void showSuccess(String message) {
    Get.snackbar(
      'success'.tr,
      message,
      backgroundColor: AppColors.success.withValues(alpha: 0.1),
      colorText: AppColors.success,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
    );
  }

  // Show info message
  static void showInfo(String message) {
    Get.snackbar(
      'info'.tr,
      message,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      colorText: AppColors.primary,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.info_outline, color: AppColors.primary),
    );
  }
}