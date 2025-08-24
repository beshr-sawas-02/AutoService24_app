import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'permission_service.dart';
import 'helpers.dart';
import 'constants.dart';

class LocationService extends GetxService {
  var currentPosition = Rx<Position?>(null);
  var isLoading = false.obs;

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      isLoading.value = true;

      // Check and request permissions
      bool hasPermission = await PermissionService.requestLocationPermission();
      if (!hasPermission) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      currentPosition.value = position;
      return position;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to get location: ${e.toString()}');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // Get last known location
  Future<Position?> getLastKnownLocation() async {
    try {
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        currentPosition.value = position;
      }
      return position;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to get last known location: ${e.toString()}');
      return null;
    }
  }

  // Calculate distance between two points
  double calculateDistance(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Calculate bearing between two points
  double calculateBearing(
      double startLatitude,
      double startLongitude,
      double endLatitude,
      double endLongitude,
      ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // Format distance in human readable format
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      double kilometers = distanceInMeters / 1000;
      return '${kilometers.toStringAsFixed(1)} km';
    }
  }

  // Check if location is within radius
  bool isWithinRadius(
      double centerLat,
      double centerLng,
      double pointLat,
      double pointLng,
      double radiusInMeters,
      ) {
    double distance = calculateDistance(centerLat, centerLng, pointLat, pointLng);
    return distance <= radiusInMeters;
  }

  // Get address from coordinates (reverse geocoding)
  Future<String?> getAddressFromCoordinates(
      double latitude,
      double longitude,
      ) async {
    try {
      // Note: This would require a geocoding service like Google Geocoding API
      // For now, return a placeholder address
      return 'Lat: ${latitude.toStringAsFixed(4)}, Lng: ${longitude.toStringAsFixed(4)}';
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to get address: ${e.toString()}');
      return null;
    }
  }

  // Start location tracking
  Stream<Position> startLocationTracking() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
        timeLimit: Duration(seconds: 30),
      ),
    );
  }

  // Stop location tracking
  void stopLocationTracking() {
    // The stream will automatically stop when no longer listened to
  }

  // Get default location (Damascus, Syria)
  Position getDefaultLocation() {
    return Position(
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
    );
  }

  // Check if two locations are approximately equal
  bool areLocationsEqual(
      Position position1,
      Position position2,
      {double toleranceInMeters = 100}
      ) {
    double distance = calculateDistance(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    );
    return distance <= toleranceInMeters;
  }

  // Get location status
  Future<LocationServiceStatus> getLocationServiceStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationServiceStatus.disabled;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        return LocationServiceStatus.permissionDenied;
      case LocationPermission.deniedForever:
        return LocationServiceStatus.permissionDeniedForever;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return LocationServiceStatus.enabled;
      default:
        return LocationServiceStatus.unknown;
    }
  }

  // Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  // Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}

enum LocationServiceStatus {
  enabled,
  disabled,
  permissionDenied,
  permissionDeniedForever,
  unknown,
}