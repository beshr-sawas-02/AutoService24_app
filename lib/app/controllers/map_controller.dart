import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import '../utils/location_service.dart';

class MapController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  var isLoading = false.obs;

  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  CircleAnnotationManager? circleAnnotationManager;
  PolylineAnnotationManager? polylineAnnotationManager;

  // Use LocationService's reactive variables
  Rx<geo.Position?> get currentPosition => _locationService.currentPosition;
  RxBool get hasLocationPermission => _locationService.hasLocationPermission;
  RxBool get isLocationServiceEnabled => _locationService.isLocationServiceEnabled;

  @override
  void onInit() {
    super.onInit();

  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration.zero, () {
      checkLocationServices();
    });
  }

  /// Check if location services are enabled and permissions are granted
  Future<void> checkLocationServices() async {
    await _locationService.checkLocationServices();
  }

  /// Get current user location
  Future<geo.Position?> getCurrentLocation() async {
    return await _locationService.getCurrentLocation();
  }

  /// Request location permission from user
  Future<void> requestLocationPermission() async {
    await _locationService.requestLocationPermission();
  }

  /// Set the Mapbox map instance
  void setMapboxMap(MapboxMap map) {
    mapboxMap = map;
  }

  /// Setup annotation managers for markers, circles, and routes
  Future<void> setupAnnotationManagers() async {
    if (mapboxMap == null) return;


    for (int attempt = 1; attempt <= 3; attempt++) {
      try {


        await Future.delayed(Duration(milliseconds: 1000 * attempt));


        if (pointAnnotationManager == null) {
          try {
            pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
          } catch (e) {
            if (attempt == 3) pointAnnotationManager = null;
          }
        }


        if (circleAnnotationManager == null) {
          try {
            circleAnnotationManager = await mapboxMap!.annotations.createCircleAnnotationManager();
          } catch (e) {
            if (attempt == 3) circleAnnotationManager = null;
          }
        }


        if (polylineAnnotationManager == null) {
          try {
            polylineAnnotationManager = await mapboxMap!.annotations.createPolylineAnnotationManager();
          } catch (e) {
            if (attempt == 3) polylineAnnotationManager = null;
          }
        }


        if (pointAnnotationManager != null || circleAnnotationManager != null) {
          break;
        }

      } catch (e) {
        if (attempt == 3) {
        }
      }
    }
  }


  Future<void> addWorkshopLocationMarker(double latitude, double longitude) async {


    if (!areValidCoordinates(latitude, longitude)) {
      return;
    }




    await clearAnnotations();


    if (circleAnnotationManager == null || pointAnnotationManager == null) {
      await setupAnnotationManagers();


      await Future.delayed(const Duration(milliseconds: 1000));
    }



    bool success = false;


    if (circleAnnotationManager != null) {
      success = await _tryMultipleCirclesPin(latitude, longitude);
      if (success) {
        await _tryAddWorkshopText(latitude, longitude);
        return;
      }
    }


    if (circleAnnotationManager != null && !success) {
      success = await _trySingleCirclePin(latitude, longitude);
      if (success) {
        await _tryAddWorkshopText(latitude, longitude);
        return;
      }
    }


    if (pointAnnotationManager != null && !success) {
      success = await _tryTextOnlyMarker(latitude, longitude);
      if (success) {
        return;
      }
    }



    Get.snackbar(
      'Map Notice',
      'Location selected but marker display may be limited',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  Future<bool> _tryMultipleCirclesPin(double latitude, double longitude) async {
    if (circleAnnotationManager == null) return false;

    try {
      final point = Point(coordinates: Position(longitude, latitude));


      final outerCircle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 18.0,
        circleColor: 0xFFFF0000,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 2.0,
      );

      await circleAnnotationManager!.create(outerCircle);


      final innerCircle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 8.0,
        circleColor: 0xFFFFFFFF,
      );

      await circleAnnotationManager!.create(innerCircle);

      return true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> _trySingleCirclePin(double latitude, double longitude) async {
    if (circleAnnotationManager == null) return false;

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      final circle = CircleAnnotationOptions(
        geometry: point,
        circleRadius: 15.0,
        circleColor: 0xFFFF0000,
        circleStrokeColor: 0xFFFFFFFF,
        circleStrokeWidth: 3.0,
      );

      await circleAnnotationManager!.create(circle);
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<bool> _tryTextOnlyMarker(double latitude, double longitude) async {
    if (pointAnnotationManager == null) return false;

    try {
      final point = Point(coordinates: Position(longitude, latitude));

      final textOptions = PointAnnotationOptions(
        geometry: point,
        textField: "WORKSHOP HERE",
        textSize: 14.0,
        textColor: 0xFFFF0000,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 2.0,
        textAnchor: TextAnchor.CENTER,
      );

      await pointAnnotationManager!.create(textOptions);
      return true;
    } catch (e) {
      return false;
    }
  }


  Future<void> _tryAddWorkshopText(double latitude, double longitude) async {
    if (pointAnnotationManager == null) {
      return;
    }

    try {
      final textPoint = Point(
          coordinates: Position(longitude, latitude - 0.0002)
      );

      final textOptions = PointAnnotationOptions(
        geometry: textPoint,
        textField: "Workshop",
        textSize: 12.0,
        textColor: 0xFFFF0000,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 2.0,
        textAnchor: TextAnchor.CENTER,
      );

      await pointAnnotationManager!.create(textOptions);
    } catch (e) {
    }
  }


  Future<void> debugAnnotationManagers() async {

    if (mapboxMap != null) {
      try {
        final cameraState = await mapboxMap!.getCameraState();
      } catch (e) {
      }
    }
  }

  /// Add a marker to the map with retry mechanism
  Future<void> addMarker(
      double latitude,
      double longitude, {
        String? title,
        String? snippet,
        Map<String, dynamic>? userData,
      }) async {


    if (pointAnnotationManager == null) {
      return;
    }


    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final point = Point(coordinates: Position(longitude, latitude));

        final options = PointAnnotationOptions(
          geometry: point,
          textField: title ?? "Marker",
          textOffset: [0.0, -2.0],
          textColor: 0xFF000000,
          textSize: 12.0,
        );

        await pointAnnotationManager!.create(options);
        return;
      } catch (e) {
        if (attempt == 1) {

          await _recreatePointAnnotationManager();
        }
      }
    }
  }

  /// Add destination marker with retry mechanism
  Future<void> addDestinationMarker(double lat, double lng, {required String title}) async {
    if (pointAnnotationManager == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final point = Point(coordinates: Position(lng, lat));

        final options = PointAnnotationOptions(
          geometry: point,
          textField: title,
          textOffset: [0.0, -2.0],
          textColor: 0xFFFF0000,
          textSize: 14.0,
        );

        await pointAnnotationManager!.create(options);
        return;
      } catch (e) {
        if (attempt == 1) {
          await _recreatePointAnnotationManager();
        }
      }
    }
  }

  /// Add real route using Mapbox Directions API with enhanced error handling
  Future<void> addRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    try {

      if (mapboxMap == null) {
        _showRouteError('Map not ready. Please try again.');
        return;
      }

      isLoading.value = true;


      await clearRoute();


      if (polylineAnnotationManager == null) {
        await _recreatePolylineAnnotationManager();

        if (polylineAnnotationManager == null) {
          await _showStraightLineFallback(startLat, startLng, endLat, endLng);
          return;
        }
      }

      // Get real route from Mapbox Directions API
      final routeCoordinates = await _getDirectionsRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      if (routeCoordinates.isNotEmpty) {

        bool routeDrawn = false;
        for (int attempt = 1; attempt <= 2; attempt++) {
          try {
            final lineString = LineString(coordinates: routeCoordinates);

            final options = PolylineAnnotationOptions(
              geometry: lineString,
              lineColor: 0xFF0066FF,
              lineWidth: 5.0,
              lineOpacity: 0.8,
            );

            await polylineAnnotationManager!.create(options);
            routeDrawn = true;
            break;
          } catch (e) {
            if (attempt == 1) {
              await _recreatePolylineAnnotationManager();
            }
          }
        }

        if (!routeDrawn) {

          await _showStraightLineFallback(startLat, startLng, endLat, endLng);
        }
      } else {

        await _showStraightLineFallback(startLat, startLng, endLat, endLng);
      }
    } catch (e) {
      await _showStraightLineFallback(startLat, startLng, endLat, endLng);
    } finally {
      isLoading.value = false;
    }
  }

  /// Show route error to user
  void _showRouteError(String message) {
    Get.snackbar(
      'Route Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show straight line when polyline fails
  Future<void> _showStraightLineFallback(double startLat, double startLng, double endLat, double endLng) async {
    try {

      await addMarker(endLat, endLng, title: "Destination");


      Get.snackbar(
        'Route Info',
        'Showing destination marker. Route line unavailable.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
    }
  }

  /// Get real route from Mapbox Directions API
  Future<List<Position>> _getDirectionsRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/$startLng,$startLat;$endLng,$endLat'
        '?access_token=${AppConstants.mapboxAccessToken}&geometries=geojson&overview=full';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

          return coordinates.map((coord) =>
              Position(coord[0].toDouble(), coord[1].toDouble())
          ).toList();
        }
      } else {
      }
    } catch (e) {
    }

    // Fallback to straight line if API call fails
    return _getStraightLineCoordinates(startLat, startLng, endLat, endLng);
  }

  /// Get route with additional options (driving, walking, cycling)
  Future<List<Position>> getDirectionsRouteWithProfile({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'driving', // driving, walking, cycling
  }) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/$profile/$startLng,$startLat;$endLng,$endLat'
        '?access_token=${AppConstants.mapboxAccessToken}&geometries=geojson&overview=full&steps=true';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final coordinates = data['routes'][0]['geometry']['coordinates'] as List;

          return coordinates.map((coord) =>
              Position(coord[0].toDouble(), coord[1].toDouble())
          ).toList();
        }
      }
    } catch (e) {
    }

    return _getStraightLineCoordinates(startLat, startLng, endLat, endLng);
  }

  /// Get route information (distance, duration, etc.)
  Future<Map<String, dynamic>?> getRouteInfo({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    String profile = 'driving',
  }) async {
    final String url =
        'https://api.mapbox.com/directions/v5/mapbox/$profile/$startLng,$startLat;$endLng,$endLat'
        '?access_token=${AppConstants.mapboxAccessToken}&overview=simplified';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          return {
            'distance': route['distance'], // in meters
            'duration': route['duration'], // in seconds
            'steps': route['legs'][0]['steps'] ?? [], // turn-by-turn instructions
          };
        }
      }
    } catch (e) {
    }

    return null;
  }

  /// Fallback method for straight line route
  Future<void> _addStraightLineRoute(double startLat, double startLng, double endLat, double endLng) async {
    try {
      if (polylineAnnotationManager != null) {
        final coordinates = _getStraightLineCoordinates(startLat, startLng, endLat, endLng);
        final lineString = LineString(coordinates: coordinates);

        final options = PolylineAnnotationOptions(
          geometry: lineString,
          lineColor: 0xFFFF6B6B, // Red color to indicate fallback
          lineWidth: 5.0,
          lineOpacity: 0.8,
        );

        await polylineAnnotationManager!.create(options);
      }
    } catch (e) {
    }
  }

  /// Get straight line coordinates
  List<Position> _getStraightLineCoordinates(double startLat, double startLng, double endLat, double endLng) {
    return [
      Position(startLng, startLat),
      Position(endLng, endLat),
    ];
  }

  /// Add route with waypoints (for more complex routing)
  Future<void> addRouteWithWaypoints(List<Position> waypoints) async {
    if (polylineAnnotationManager != null && waypoints.length >= 2) {
      try {
        await clearRoute();

        final lineString = LineString(coordinates: waypoints);

        final options = PolylineAnnotationOptions(
          geometry: lineString,
          lineColor: 0xFF0066FF,
          lineWidth: 5.0,
          lineOpacity: 0.8,
        );

        await polylineAnnotationManager!.create(options);
      } catch (e) {
      }
    }
  }

  /// Fit camera to show entire route with enhanced error handling
  Future<void> fitRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    if (mapboxMap == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        // Calculate bounds
        final double minLat = startLat < endLat ? startLat : endLat;
        final double maxLat = startLat > endLat ? startLat : endLat;
        final double minLng = startLng < endLng ? startLng : endLng;
        final double maxLng = startLng > endLng ? startLng : endLng;

        // Add padding
        const double padding = 0.01;

        // Calculate center point
        final double centerLat = (minLat + maxLat) / 2;
        final double centerLng = (minLng + maxLng) / 2;

        // Calculate appropriate zoom level
        final double latDiff = maxLat - minLat + padding;
        final double lngDiff = maxLng - minLng + padding;
        final double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

        double zoom = 10.0;
        if (maxDiff < 0.01) zoom = 14.0;
        else if (maxDiff < 0.05) zoom = 12.0;
        else if (maxDiff < 0.1) zoom = 11.0;
        else if (maxDiff < 0.5) zoom = 9.0;
        else zoom = 8.0;

        final center = Point(coordinates: Position(centerLng, centerLat));

        await mapboxMap!.flyTo(
          CameraOptions(
            center: center,
            zoom: zoom,
          ),
          MapAnimationOptions(duration: 2000, startDelay: 0),
        );
        return;
      } catch (e) {
        if (attempt == 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }


    try {
      final double centerLat = (startLat + endLat) / 2;
      final double centerLng = (startLng + endLng) / 2;
      await flyToLocation(centerLat, centerLng, zoom: 12.0);
    } catch (e) {
    }
  }

  /// Clear route from map with safe error handling
  Future<void> clearRoute() async {
    if (polylineAnnotationManager == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        await polylineAnnotationManager!.deleteAll();
        return;
      } catch (e) {

        if (attempt == 1) {

          await _recreatePolylineAnnotationManager();
        } else {

          polylineAnnotationManager = null;
        }
      }
    }
  }

  /// Recreate point annotation manager
  Future<void> _recreatePointAnnotationManager() async {
    if (mapboxMap == null) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
    } catch (e) {
      pointAnnotationManager = null;
    }
  }

  /// Recreate polyline annotation manager
  Future<void> _recreatePolylineAnnotationManager() async {
    if (mapboxMap == null) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      polylineAnnotationManager = await mapboxMap!.annotations.createPolylineAnnotationManager();
    } catch (e) {
      polylineAnnotationManager = null;
    }
  }

  /// Add multiple markers to the map
  Future<void> addMarkers(List<Map<String, dynamic>> markers) async {
    if (pointAnnotationManager != null) {
      try {
        await pointAnnotationManager!.deleteAll();

        for (final markerData in markers) {
          await addMarker(
            markerData['latitude'],
            markerData['longitude'],
            title: markerData['title'],
            snippet: markerData['snippet'],
          );
        }
      } catch (e) {
      }
    }
  }

  /// Add a circle overlay to the map
  Future<void> addCircle(
      double latitude,
      double longitude,
      double radiusMeters, {
        int fillColor = 0x330066FF,
        int strokeColor = 0xFF0066FF,
        double strokeWidth = 2.0,
      }) async {
    if (circleAnnotationManager != null) {
      try {
        final point = Point(coordinates: Position(longitude, latitude));

        double pixelRadius = _metersToPixelRadius(radiusMeters);

        final options = CircleAnnotationOptions(
          geometry: point,
          circleRadius: pixelRadius,
          circleColor: fillColor,
          circleStrokeColor: strokeColor,
          circleStrokeWidth: strokeWidth,
        );

        await circleAnnotationManager!.create(options);
      } catch (e) {
      }
    }
  }

  double _metersToPixelRadius(double radiusInMeters) {
    if (radiusInMeters <= 100) return 15.0;
    if (radiusInMeters <= 500) return 25.0;
    if (radiusInMeters <= 1000) return 35.0;
    if (radiusInMeters <= 2000) return 50.0;
    if (radiusInMeters <= 5000) return 75.0;
    if (radiusInMeters <= 10000) return 100.0;
    if (radiusInMeters <= 15000) return 120.0;
    if (radiusInMeters <= 25000) return 140.0;
    if (radiusInMeters <= 50000) return 160.0;
    if (radiusInMeters <= 75000) return 180.0;
    if (radiusInMeters <= 100000) return 200.0;
    if (radiusInMeters <= 150000) return 220.0;
    if (radiusInMeters <= 200000) return 240.0;
    if (radiusInMeters <= 250000) return 260.0;
    if (radiusInMeters <= 300000) return 280.0;
    if (radiusInMeters <= 400000) return 300.0;
    if (radiusInMeters <= 500000) return 320.0;
    return 350.0;
  }

  /// Clear all annotations with safe error handling
  Future<void> clearAnnotations() async {
    // Clear markers
    if (pointAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await pointAnnotationManager!.deleteAll();
          break;
        } catch (e) {
          if (attempt == 1) {
            await _recreatePointAnnotationManager();
          } else {
            pointAnnotationManager = null;
          }
        }
      }
    }

    // Clear circles
    if (circleAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await circleAnnotationManager!.deleteAll();
          break;
        } catch (e) {
          if (attempt == 2) {
            circleAnnotationManager = null;
          }
        }
      }
    }

    // Clear routes
    await clearRoute();
  }

  /// Clear only markers with safe error handling
  Future<void> clearMarkers() async {
    if (pointAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await pointAnnotationManager!.deleteAll();
          return;
        } catch (e) {
          if (attempt == 1) {
            await _recreatePointAnnotationManager();
          } else {
            pointAnnotationManager = null;
          }
        }
      }
    }
  }

  /// Clear only circles with safe error handling
  Future<void> clearCircles() async {
    if (circleAnnotationManager != null) {
      for (int attempt = 1; attempt <= 2; attempt++) {
        try {
          await circleAnnotationManager!.deleteAll();
          return;
        } catch (e) {
          if (attempt == 2) {
            circleAnnotationManager = null;
          }
        }
      }
    }
  }

  /// Fly to a specific location with safe error handling
  Future<void> flyToLocation(
      double latitude,
      double longitude, {
        double zoom = 15.0,
        int duration = 2000,
      }) async {
    if (mapboxMap == null) {
      return;
    }

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final center = Point(coordinates: Position(longitude, latitude));

        await mapboxMap!.flyTo(
          CameraOptions(
            center: center,
            zoom: zoom,
          ),
          MapAnimationOptions(duration: duration, startDelay: 0),
        );
        return;
      } catch (e) {
        if (attempt == 1) {

          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }


    Get.snackbar(
      'Navigation Warning',
      'Unable to move camera to location. Map may not be fully loaded.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Calculate distance between two points using LocationService
  double calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return _locationService.calculateDistance(
        startLat, startLng, endLat, endLng);
  }

  /// Convert distance from meters to kilometers using LocationService
  double metersToKilometers(double meters) {
    return _locationService.metersToKilometers(meters);
  }

  /// Convert distance from kilometers to meters using LocationService
  double kilometersToMeters(double kilometers) {
    return _locationService.kilometersToMeters(kilometers);
  }

  /// Check if a point is within a radius using LocationService
  bool isWithinRadius(
      double centerLat,
      double centerLng,
      double pointLat,
      double pointLng,
      double radiusMeters,
      ) {
    return _locationService.isWithinRadius(
        centerLat, centerLng, pointLat, pointLng, radiusMeters);
  }

  /// Format distance for display using LocationService
  String formatDistance(double meters) {
    return _locationService.formatDistance(meters);
  }

  /// Check if coordinates are valid using LocationService
  bool areValidCoordinates(double latitude, double longitude) {
    return _locationService.areValidCoordinates(latitude, longitude);
  }

  /// Get default location using LocationService
  geo.Position getDefaultLocation() {
    return _locationService.getDefaultLocation();
  }

  /// Get location service status using LocationService
  Future<LocationServiceStatus> getLocationServiceStatus() async {
    return await _locationService.getLocationServiceStatus();
  }

  /// Open location settings using LocationService
  Future<void> openLocationSettings() async {
    await _locationService.openLocationSettings();
  }

  /// Open app settings using LocationService
  Future<void> openAppSettings() async {
    await _locationService.openAppSettings();
  }

  /// Reset all annotation managers in case of complete failure
  Future<void> resetAllManagers() async {

    pointAnnotationManager = null;
    circleAnnotationManager = null;
    polylineAnnotationManager = null;

    if (mapboxMap != null) {

      await Future.delayed(const Duration(milliseconds: 3000));
      await setupAnnotationManagers();
    }
  }

  /// Emergency fallback when all platform calls fail
  void enableEmergencyMode() {

    pointAnnotationManager = null;
    circleAnnotationManager = null;
    polylineAnnotationManager = null;

    Get.snackbar(
      'Map Notice',
      'Map is running in limited mode. Some features may not be available.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 5),
    );
  }

  /// Check if any annotation manager is working
  bool hasWorkingAnnotationManager() {
    return pointAnnotationManager != null ||
        circleAnnotationManager != null ||
        polylineAnnotationManager != null;
  }

  /// Enhanced setup with platform connection check
  Future<void> setupAnnotationManagersWithHealthCheck() async {
    if (mapboxMap == null) return;


    bool isHealthy = await _isPlatformConnectionHealthy();
    if (!isHealthy) {
      await Future.delayed(const Duration(milliseconds: 2000));
      isHealthy = await _isPlatformConnectionHealthy();
      if (!isHealthy) {
        return;
      }
    }

    await setupAnnotationManagers();
  }

  /// Check if platform connection is healthy
  Future<bool> _isPlatformConnectionHealthy() async {
    if (mapboxMap == null) return false;

    try {

      final cameraState = await mapboxMap!.getCameraState();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {

    try {
      pointAnnotationManager = null;
      circleAnnotationManager = null;
      polylineAnnotationManager = null;
      mapboxMap = null;
    } catch (e) {
    }
    super.onClose();
  }
}