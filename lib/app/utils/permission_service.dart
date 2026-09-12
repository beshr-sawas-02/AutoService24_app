import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'helpers.dart';

class PermissionService {
  // Check and request location permission
  static Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await _showLocationServiceDialog();
        return false;
      }

      // Check current permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Helpers.showErrorSnackbar('Location permissions are denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await _showPermissionDeniedDialog('location');
        return false;
      }

      return true;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to request location permission: ${e.toString()}');
      return false;
    }
  }

  // Get current location
  static Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) return null;

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to get current location: ${e.toString()}');
      return null;
    }
  }

  // Check if location permission is granted
  static Future<bool> hasLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  // Show dialog when location service is disabled
  static Future<void> _showLocationServiceDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Service Disabled'),
        content: const Text(
          'Location services are disabled. Please enable location services in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Show dialog when permission is permanently denied
  static Future<void> _showPermissionDeniedDialog(String permissionType) async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$permissionType permission is permanently denied. Please enable it in your device settings to use this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  // Request camera permission (for image picking)
  static Future<bool> requestCameraPermission() async {
    try {
      // Note: image_picker handles camera permissions automatically
      // This is a placeholder for additional camera permission handling if needed
      return true;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to request camera permission: ${e.toString()}');
      return false;
    }
  }

  // Request storage permission (for image saving)
  static Future<bool> requestStoragePermission() async {
    try {
      // Note: Modern Android and iOS handle storage permissions differently
      // This is a placeholder for storage permission handling if needed
      return true;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to request storage permission: ${e.toString()}');
      return false;
    }
  }

  // Check if all required permissions are granted
  static Future<bool> checkAllPermissions() async {
    bool locationPermission = await hasLocationPermission();
    // Add other permission checks as needed

    return locationPermission;
  }

  // Request all required permissions
  static Future<bool> requestAllPermissions() async {
    bool locationPermission = await requestLocationPermission();
    // Add other permission requests as needed

    return locationPermission;
  }

  // Show general permission explanation dialog
  static Future<void> showPermissionExplanationDialog({
    required String title,
    required String message,
    required VoidCallback onAccept,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Not Now'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              onAccept();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }
}