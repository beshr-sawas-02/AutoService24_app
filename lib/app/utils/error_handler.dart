import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'helpers.dart';
import 'constants.dart';

class ErrorHandler {
  // Handle Dio errors
  static String handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';

      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';

      case DioExceptionType.badResponse:
        return _handleHttpError(error.response?.statusCode, error.response?.data);

      case DioExceptionType.cancel:
        return 'Request was cancelled.';

      case DioExceptionType.connectionError:
        return 'Connection error. Please check your internet connection.';

      case DioExceptionType.unknown:
        return 'An unexpected error occurred. Please try again.';

      default:
        return AppConstants.unknownError;
    }
  }

  // Handle HTTP status codes
  static String _handleHttpError(int? statusCode, dynamic responseData) {
    String message = '';

    // Try to extract error message from response
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? responseData['error'] ?? '';
    }

    switch (statusCode) {
      case 400:
        return message.isNotEmpty ? message : 'Bad request. Please check your input.';

      case 401:
        return 'Unauthorized. Please login again.';

      case 403:
        return 'Access forbidden. You don\'t have permission to perform this action.';

      case 404:
        return 'Resource not found.';

      case 409:
        return message.isNotEmpty ? message : 'Conflict. Resource already exists.';

      case 422:
        return message.isNotEmpty ? message : 'Invalid data provided.';

      case 429:
        return 'Too many requests. Please try again later.';

      case 500:
        return 'Internal server error. Please try again later.';

      case 502:
        return 'Bad gateway. Server is temporarily unavailable.';

      case 503:
        return 'Service unavailable. Please try again later.';

      case 504:
        return 'Gateway timeout. Please try again.';

      default:
        return message.isNotEmpty ? message : AppConstants.serverError;
    }
  }

  // Handle general exceptions
  static String handleGeneralError(dynamic error) {
    if (error is DioException) {
      return handleDioError(error);
    }

    if (error is FormatException) {
      return 'Invalid data format received from server.';
    }

    if (error is TypeError) {
      return 'Data type error occurred.';
    }

    return error.toString().isEmpty ? AppConstants.unknownError : error.toString();
  }

  // Show error dialog
  static void showErrorDialog({
    required String title,
    required String message,
    VoidCallback? onRetry,
    VoidCallback? onCancel,
  }) {
    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          if (onCancel != null)
            TextButton(
              onPressed: onCancel,
              child: const Text('Cancel'),
            ),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          if (onRetry == null && onCancel == null)
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('OK'),
            ),
        ],
      ),
    );
  }

  // Log error (in production, you might want to send to crash reporting service)
  static void logError(dynamic error, StackTrace? stackTrace) {
    debugPrint('Error: $error');
    if (stackTrace != null) {
      debugPrint('StackTrace: $stackTrace');
    }

    // In production, send to crash reporting service like Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stackTrace);
  }

  // Handle and show error
  static void handleAndShowError(dynamic error, {VoidCallback? onRetry}) {
    String errorMessage = handleGeneralError(error);

    // Log the error
    logError(error, null);

    // Show error to user
    if (onRetry != null) {
      showErrorDialog(
        title: 'Error',
        message: errorMessage,
        onRetry: onRetry,
        onCancel: () => Get.back(),
      );
    } else {
      Helpers.showErrorSnackbar(errorMessage);
    }
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
      title: 'Validation Error',
      message: message,
    );
  }

  // Handle auth errors specifically
  static void handleAuthError(dynamic error) {
    String errorMessage = handleGeneralError(error);

    // If it's an auth error, redirect to login
    if (error is DioException && error.response?.statusCode == 401) {
      Get.offAllNamed('/login');
      Helpers.showErrorSnackbar('Session expired. Please login again.');
    } else {
      Helpers.showErrorSnackbar(errorMessage);
    }
  }
}