import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/map_controller.dart';
import '../../data/models/workshop_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // Controllers
  final WorkshopController _workshopController = Get.find<WorkshopController>();
  final MapController _mapController = Get.find<MapController>();

  // Map instance
  MapboxMap? _mapboxMap;

  // Focus on specific workshop variables
  bool _shouldFocusOnWorkshop = false;
  String? _targetWorkshopId;
  double? _targetLatitude;
  double? _targetLongitude;
  String _targetWorkshopName = '';
  double _targetZoom = 16.0;



  // Constants
  static const double _defaultZoom = 12.0;
  static const double _focusZoom = 16.0;
  static const double _currentLocationZoom = 15.0;
  static const double _maxTapDistance = 1000; // 1km maximum tap distance
  static const double _circleRadius = 500; // Circle radius in meters

  @override
  void initState() {
    super.initState();
    _parseArguments();

    Future.delayed(Duration.zero, () {
      _initializeMap();
    });
  }

  void _parseArguments() {
    final arguments = Get.arguments;
    if (arguments is Map<String, dynamic>) {
      _shouldFocusOnWorkshop = arguments['focusOnWorkshop'] ?? false;
      _targetWorkshopId = arguments['workshopId'];
      _targetLatitude = arguments['latitude'];
      _targetLongitude = arguments['longitude'];
      _targetWorkshopName = arguments['workshopName'] ?? '';
      _targetZoom = arguments['zoom']?.toDouble() ?? _focusZoom;
    }
  }

  /// Initialize map and handle focus on specific workshop
  Future<void> _initializeMap() async {
    try {
      await _mapController.checkLocationServices();

      final currentPos = _mapController.currentPosition.value;
      if (currentPos != null) {
        await _mapController.addCurrentLocationMarker(
          currentPos.latitude,
          currentPos.longitude,
        );
      }

      await _loadWorkshopMarkers();

      if (_shouldFocusOnSpecificWorkshop()) {
        await _focusOnTargetWorkshop();
      }
    } catch (e) {
    }
  }

  /// Check if should focus on specific workshop
  bool _shouldFocusOnSpecificWorkshop() {
    return _shouldFocusOnWorkshop &&
        _targetLatitude != null &&
        _targetLongitude != null;
  }

  /// Focus map on target workshop
  Future<void> _focusOnTargetWorkshop() async {
    // Wait for map to load
    await Future.delayed(const Duration(milliseconds: 1000));

    // Add red pin marker for workshop BEFORE moving camera
    await _mapController.addWorkshopLocationMarker(
      _targetLatitude!,
      _targetLongitude!,
      workshopName: _targetWorkshopName,
    );

    // Wait a bit for marker to render
    await Future.delayed(const Duration(milliseconds: 300));

    // Move to workshop location
    await _mapController.flyToLocation(
      _targetLatitude!,
      _targetLongitude!,
      zoom: _targetZoom,
    );

    // Show workshop details if ID is provided
    if (_targetWorkshopId != null) {
      final workshop = _workshopController.findWorkshopById(_targetWorkshopId!);
      if (workshop != null) {
        await Future.delayed(const Duration(milliseconds: 500));
        _showWorkshopBottomSheet(workshop);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildMapBody(),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  /// Build app bar with dynamic title
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _shouldFocusOnWorkshop && _targetWorkshopName.isNotEmpty
            ? _targetWorkshopName
            : 'workshop_locations'.tr,
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      actions: _buildAppBarActions(),
    );
  }

  /// Build app bar actions
  List<Widget> _buildAppBarActions() {
    return [
      if (_shouldFocusOnWorkshop && _targetLatitude != null && _targetLongitude != null)
        IconButton(
          icon: const Icon(Icons.map),
          onPressed: () => _openGoogleMaps(
            latitude: _targetLatitude!,
            longitude: _targetLongitude!,
            label: _targetWorkshopName,
          ),
          tooltip: 'open_maps'.tr,
        ),
      if (!_shouldFocusOnWorkshop)
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () => Get.toNamed(AppRoutes.workshopMapSearch),
          tooltip: 'search'.tr,
        ),
    ];
  }

  /// Build map widget with reactive positioning
  Widget _buildMapBody() {
    return Obx(() {
      final currentPos = _mapController.currentPosition.value;

      return MapWidget(
        key: const ValueKey("workshopMapWidget"),
        cameraOptions: CameraOptions(
          center: Point(
            coordinates: Position(
              _getInitialLongitude(currentPos),
              _getInitialLatitude(currentPos),
            ),
          ),
          zoom: _shouldFocusOnWorkshop ? _targetZoom : _defaultZoom,
        ),
        onMapCreated: _onMapCreated,
        onTapListener: _onMapTap,
      );
    });
  }

  /// Get initial latitude for map center
  double _getInitialLatitude(geo.Position? currentPos) {
    if (_shouldFocusOnWorkshop && _targetLatitude != null) {
      return _targetLatitude!;
    }
    return currentPos?.latitude ?? 33.5138; // Default to Damascus
  }

  /// Get initial longitude for map center
  double _getInitialLongitude(geo.Position? currentPos) {
    if (_shouldFocusOnWorkshop && _targetLongitude != null) {
      return _targetLongitude!;
    }
    return currentPos?.longitude ?? 36.2765; // Default to Damascus
  }

  /// Build floating action buttons
  Widget _buildFloatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (!_shouldFocusOnWorkshop) ...[
          _buildSearchFAB(),
          const SizedBox(height: 10),
        ],
        _buildRefreshFAB(),
        const SizedBox(height: 10),
        _buildLocationFAB(),
      ],
    );
  }

  /// Build search floating action button
  Widget _buildSearchFAB() {
    return FloatingActionButton(
      heroTag: "search_fab",
      onPressed: () => Get.toNamed(AppRoutes.workshopMapSearch),
      backgroundColor: AppColors.info,
      foregroundColor: AppColors.white,
      mini: true,
      tooltip: 'search'.tr,
      child: const Icon(Icons.search),
    );
  }

  /// Build refresh floating action button
  Widget _buildRefreshFAB() {
    return FloatingActionButton(
      heroTag: "refresh_fab",
      onPressed: _loadWorkshopMarkers,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      mini: true,
      tooltip: 'refresh'.tr,
      child: const Icon(Icons.refresh),
    );
  }

  /// Build location floating action button
  Widget _buildLocationFAB() {
    return FloatingActionButton(
      heroTag: "location_fab",
      onPressed: _goToCurrentLocation,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      tooltip: 'current_location'.tr,
      child: const Icon(Icons.my_location),
    );
  }

  /// Handle map creation
  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    _mapController.setMapboxMap(mapboxMap);

    Future.delayed(const Duration(milliseconds: 2000), () {
      _setupAnnotationManagers();
    });
  }

  Future<void> _setupAnnotationManagers() async {
    try {
      await _mapController.setupAnnotationManagersWithHealthCheck();

      await Future.delayed(const Duration(milliseconds: 1000));
      await _loadWorkshopMarkers();
    } catch (e) {
    }
  }

  /// Handle map tap to show nearby workshop
  void _onMapTap(MapContentGestureContext context) {
    final coordinates = context.point.coordinates;
    final lat = coordinates.lat.toDouble();
    final lng = coordinates.lng.toDouble();

    final nearestWorkshop = _findNearestWorkshop(lat, lng);
    if (nearestWorkshop != null) {
      _showWorkshopBottomSheet(nearestWorkshop);
    }
  }

  /// Find nearest workshop to tap location
  WorkshopModel? _findNearestWorkshop(double lat, double lng) {
    WorkshopModel? nearestWorkshop;
    double minDistance = double.infinity;

    for (WorkshopModel workshop in _workshopController.workshops) {
      if (_isValidWorkshopLocation(workshop)) {
        double distance = _mapController.calculateDistance(
          lat,
          lng,
          workshop.latitude,
          workshop.longitude,
        );

        if (distance < minDistance && distance < _maxTapDistance) {
          minDistance = distance;
          nearestWorkshop = workshop;
        }
      }
    }

    return nearestWorkshop;
  }

  /// Show workshop details bottom sheet - compact version
  void _showWorkshopBottomSheet(WorkshopModel workshop) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Workshop name
            Text(
              workshop.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Working hours
            Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    workshop.workingHours ?? '',
                    style: const TextStyle(color: AppColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Description - compact
            Text(
              workshop.description ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),

            // Action buttons: View Details & Directions
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _navigateToWorkshopDetails(workshop);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('view_details'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _getDirections(workshop);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text('directions'.tr),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Distance info
            Obx(() {
              final currentPos = _mapController.currentPosition.value;
              if (currentPos != null) {
                final distance = _calculateDistance(workshop, currentPos);
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${'distance'.tr}: ${_mapController.formatDistance(distance)}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            }),

            // Back button if focused on specific workshop
            if (_shouldFocusOnWorkshop) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.back();
                  },
                  icon: const Icon(Icons.arrow_back),
                  label: Text('back_to_services'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Check if workshop has valid location
  bool _isValidWorkshopLocation(WorkshopModel workshop) {
    return workshop.latitude != 0.0 && workshop.longitude != 0.0;
  }

  /// Go to current user location
  void _goToCurrentLocation() {
    final currentPos = _mapController.currentPosition.value;

    if (currentPos != null && _mapboxMap != null) {
      _mapController.addCurrentLocationMarker(
        currentPos.latitude,
        currentPos.longitude,
      );

      _mapController.flyToLocation(
        currentPos.latitude,
        currentPos.longitude,
        zoom: _currentLocationZoom,
      );
    } else {
      _mapController.getCurrentLocation().then((pos) {
        if (pos != null) {
          _mapController.addCurrentLocationMarker(
            pos.latitude,
            pos.longitude,
          );
        }
      });
      _showInfo('getting_location'.tr);
    }
  }

  /// Load workshop markers on map with enhanced error handling
  Future<void> _loadWorkshopMarkers() async {
    try {
      final currentPos = _mapController.currentPosition.value;

      await _mapController.clearMarkers();

      // Add current location marker first
      if (currentPos != null) {
        await _mapController.addCurrentLocationMarker(
          currentPos.latitude,
          currentPos.longitude,
        );
      }

      int successCount = 0;
      int totalWorkshops = _workshopController.workshops.length;

      for (WorkshopModel workshop in _workshopController.workshops) {
        if (_isValidWorkshopLocation(workshop)) {
          try {
            await _mapController.addMarker(
              workshop.latitude,
              workshop.longitude,
              title: workshop.name,
            );
            successCount++;
          } catch (e) {}
        }
      }

      // If focusing on specific workshop, add red pin
      if (_shouldFocusOnSpecificWorkshop()) {
        await _mapController.addWorkshopLocationMarker(
          _targetLatitude!,
          _targetLongitude!,
          workshopName: _targetWorkshopName,
        );
      }

      if (successCount == 0 && totalWorkshops > 0) {
        _showInfo('markers_load_error'.tr);
      }
    } catch (e) {
      _showError('markers_load_error'.tr, e.toString());
    }
  }

  /// Navigate to workshop details
  void _navigateToWorkshopDetails(WorkshopModel workshop) {
    Get.back();
    Get.toNamed(
      AppRoutes.workshopDetails,
      arguments: workshop,
    );
  }

  /// Calculate distance between workshop and current position
  double _calculateDistance(
      WorkshopModel workshop, geo.Position currentPosition) {
    return _mapController.calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      workshop.latitude,
      workshop.longitude,
    );
  }

  /// Get directions using Mapbox Navigation
  void _getDirections(WorkshopModel workshop) async {
    try {
      final currentPos = _mapController.currentPosition.value;

      if (currentPos == null) {
        _showError('error'.tr, 'current_location_not_found'.tr);
        return;
      }

      if (_mapController.mapboxMap == null) {
        _showError('error'.tr, 'map_not_ready'.tr);
        return;
      }

      Get.snackbar(
        'loading'.tr,
        'creating_route'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.info,
        colorText: AppColors.white,
        duration: const Duration(seconds: 2),
      );

      await _createNavigationRoute(
        startLat: currentPos.latitude,
        startLng: currentPos.longitude,
        endLat: workshop.latitude,
        endLng: workshop.longitude,
        workshopName: workshop.name,
      );
    } catch (e) {
      _showError('navigation_error'.tr, e.toString());
    }
  }

  /// Create navigation route using Mapbox
  Future<void> _createNavigationRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String workshopName,
  }) async {
    try {
      await _mapController.addRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      await _mapController.fitRoute(
        startLat: startLat,
        startLng: startLng,
        endLat: endLat,
        endLng: endLng,
      );

      _showRouteInfo(startLat, startLng, endLat, endLng, workshopName);
    } catch (e) {
    }
  }

  /// Show route information in bottom sheet
  void _showRouteInfo(double startLat, double startLng, double endLat,
      double endLng, String workshopName) {
    final distance =
    _mapController.calculateDistance(startLat, startLng, endLat, endLng);
    final estimatedTime = _calculateEstimatedTime(distance);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Route header
            Row(
              children: [
                const Icon(Icons.navigation,
                    color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${'navigation_to'.tr} $workshopName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Route info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Distance
                Column(
                  children: [
                    const Icon(Icons.straighten,
                        color: AppColors.textSecondary),
                    const SizedBox(height: 4),
                    Text(
                      _mapController.formatDistance(distance),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'distance'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Estimated time
                Column(
                  children: [
                    const Icon(Icons.access_time,
                        color: AppColors.textSecondary),
                    const SizedBox(height: 4),
                    Text(
                      estimatedTime,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'estimated_time'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                // Start Navigation Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();

                      _startNavigation(endLat, endLng, workshopName);
                    },
                    icon: const Icon(Icons.navigation),
                    label: Text('start_navigation'.tr),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Clear Route Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();

                      _clearRoute();
                    },
                    icon: const Icon(Icons.clear),
                    label: Text('clear_route'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Start turn-by-turn navigation
  void _startNavigation(double lat, double lng, String workshopName) {
    Get.snackbar(
      'navigation_started'.tr,
      '${'navigating_to'.tr} $workshopName',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.success,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Clear route from map
  Future<void> _clearRoute() async {
    await _mapController.clearRoute();
    _showInfo('route_cleared'.tr);
  }

  /// Calculate estimated time based on distance
  String _calculateEstimatedTime(double distanceInMeters) {
    const double averageSpeedKmh = 40.0;
    const double averageSpeedMs = averageSpeedKmh * 1000 / 3600;

    final double timeInSeconds = distanceInMeters / averageSpeedMs;
    final int minutes = (timeInSeconds / 60).round();

    if (minutes < 60) {
      return '$minutes min';
    } else {
      final int hours = minutes ~/ 60;
      final int remainingMinutes = minutes % 60;
      return '${hours}h ${remainingMinutes}m';
    }
  }

  /// Open workshop location in Google Maps
  Future<void> _openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    try {
      final Uri uri = Uri.parse(
        label != null && label.isNotEmpty
            ? 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(label)}'
            : 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
      );

      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('خطأ في فتح Google Maps: $e');
      Get.snackbar(
        'error'.tr,
        'google_maps_not_available'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }


  /// Show error message
  void _showError(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
      duration: const Duration(seconds: 3),
    );
  }

  /// Show info message
  void _showInfo(String message) {
    Get.snackbar(
      'info'.tr,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.info,
      colorText: AppColors.white,
      duration: const Duration(seconds: 2),
    );
  }
}