import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../utils/location_service.dart';
import '../utils/helpers.dart';

class MapController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();

  var isLoading = false.obs;

  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  CircleAnnotationManager? circleAnnotationManager;

  // Use LocationService's reactive variables
  Rx<geo.Position?> get currentPosition => _locationService.currentPosition;
  RxBool get hasLocationPermission => _locationService.hasLocationPermission;
  RxBool get isLocationServiceEnabled => _locationService.isLocationServiceEnabled;

  @override
  void onInit() {
    super.onInit();
    checkLocationServices();
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

  /// Setup annotation managers for markers and circles
  Future<void> setupAnnotationManagers() async {
    if (mapboxMap != null) {
      pointAnnotationManager = await mapboxMap!.annotations.createPointAnnotationManager();
      circleAnnotationManager = await mapboxMap!.annotations.createCircleAnnotationManager();
    }
  }

  /// Add a marker to the map (updated for new Mapbox version)
  Future<void> addMarker(
      double latitude,
      double longitude, {
        String? title,
        String? snippet,
        Map<String, dynamic>? userData, // Keep parameter for compatibility but don't use
      }) async {
    if (pointAnnotationManager != null) {
      // Create Point object instead of Map
      final point = Point(coordinates: Position(longitude, latitude));

      final options = PointAnnotationOptions(
        geometry: point,
        textField: title ?? "Marker",
        textOffset: [0.0, -2.0],
        textColor: 0xFF000000,
        iconSize: 1.2,
      );

      await pointAnnotationManager!.create(options);
    }
  }

  /// Add multiple markers to the map
  Future<void> addMarkers(List<Map<String, dynamic>> markers) async {
    if (pointAnnotationManager != null) {
      await pointAnnotationManager!.deleteAll();

      for (final markerData in markers) {
        await addMarker(
          markerData['latitude'],
          markerData['longitude'],
          title: markerData['title'],
          snippet: markerData['snippet'],
        );
      }
    }
  }

  /// Add a circle overlay to the map (updated for new Mapbox version)
  Future<void> addCircle(
      double latitude,
      double longitude,
      double radiusMeters, {
        int fillColor = 0x330066FF,
        int strokeColor = 0xFF0066FF,
        double strokeWidth = 2.0,
      }) async {
    if (circleAnnotationManager != null) {
      // Create Point object instead of Map
      final point = Point(coordinates: Position(longitude, latitude));

      final options = CircleAnnotationOptions(
        geometry: point,
        circleRadius: radiusMeters,
        circleColor: fillColor,
        circleStrokeColor: strokeColor,
        circleStrokeWidth: strokeWidth,
      );

      await circleAnnotationManager!.create(options);
    }
  }

  /// Clear all annotations (markers and circles)
  Future<void> clearAnnotations() async {
    if (pointAnnotationManager != null) {
      await pointAnnotationManager!.deleteAll();
    }
    if (circleAnnotationManager != null) {
      await circleAnnotationManager!.deleteAll();
    }
  }

  /// Clear only markers
  Future<void> clearMarkers() async {
    if (pointAnnotationManager != null) {
      await pointAnnotationManager!.deleteAll();
    }
  }

  /// Clear only circles
  Future<void> clearCircles() async {
    if (circleAnnotationManager != null) {
      await circleAnnotationManager!.deleteAll();
    }
  }

  /// Fly to a specific location (updated for new Mapbox version)
  Future<void> flyToLocation(
      double latitude,
      double longitude, {
        double zoom = 15.0,
        int duration = 2000,
      }) async {
    if (mapboxMap != null) {
      // Create Point object instead of Map
      final center = Point(coordinates: Position(longitude, latitude));

      await mapboxMap!.flyTo(
        CameraOptions(
          center: center,
          zoom: zoom,
        ),
        MapAnimationOptions(duration: duration, startDelay: 0),
      );
    }
  }

  /// Calculate distance between two points using LocationService
  double calculateDistance(
      double startLat,
      double startLng,
      double endLat,
      double endLng,
      ) {
    return _locationService.calculateDistance(startLat, startLng, endLat, endLng);
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
        centerLat, centerLng, pointLat, pointLng, radiusMeters
    );
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

  @override
  void onClose() {
    pointAnnotationManager = null;
    circleAnnotationManager = null;
    mapboxMap = null;
    super.onClose();
  }
}