import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/map_controller.dart';
import '../../data/models/service_model.dart';
import '../../data/models/workshop_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class WorkshopMapSearchView extends StatefulWidget {
  const WorkshopMapSearchView({super.key});

  @override
  _WorkshopMapSearchViewState createState() => _WorkshopMapSearchViewState();
}

class _WorkshopMapSearchViewState extends State<WorkshopMapSearchView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final MapController mapController = Get.find<MapController>();

  MapboxMap? _mapboxMap;
  Point? _searchCenter;

  double _radiusKm = 10.0;
  ServiceType? _selectedServiceType;
  List<WorkshopModel> _nearbyWorkshops = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Get arguments from navigation
    final arguments = Get.arguments as Map<String, dynamic>?;
    _selectedServiceType = arguments?['serviceType'] as ServiceType?;

    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await mapController.checkLocationServices();
    _setInitialSearchCenter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('find_nearby_workshops'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Controls
          _buildSearchControls(),

          // Map
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
              ),
              child: Obx(() {
                final currentPos = mapController.currentPosition.value;
                return MapWidget(
                  key: const ValueKey("workshopSearchMap"),
                  cameraOptions: CameraOptions(
                    center: Point(
                      coordinates: Position(
                        currentPos?.longitude ?? 36.2765,
                        currentPos?.latitude ?? 33.5138,
                      ),
                    ),
                    zoom: 12.0,
                  ),
                  onMapCreated: _onMapCreated,
             //     onTapListener: this,
                );
              }),
            ),
          ),

          // Results List
          Expanded(
            flex: 1,
            child: _buildResultsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _searchNearbyWorkshops,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.white)
            : const Icon(Icons.search),
      ),
    );
  }

  Widget _buildSearchControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.white,
      child: Column(
        children: [
          // Service Type Dropdown
          if (_selectedServiceType == null)
            DropdownButtonFormField<ServiceType>(
              decoration: InputDecoration(
                labelText: 'select_service_type'.tr,
                prefixIcon: const Icon(Icons.build_circle, color: AppColors.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              items: ServiceType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedServiceType = value;
                });
              },
            ),

          if (_selectedServiceType != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.build_circle, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    _selectedServiceType!.displayName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.primary),
                    onPressed: () {
                      setState(() {
                        _selectedServiceType = null;
                        _nearbyWorkshops.clear();
                      });
                    },
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Radius Slider
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'search_radius'.tr + ': ${_radiusKm.toInt()} km',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Slider(
                      value: _radiusKm,
                      min: 1.0,
                      max: 500.0,
                      divisions: 499,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          _radiusKm = value;
                        });
                        _updateSearchRadius();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Current Location Info
          if (_searchCenter != null)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'search_center'.tr + ': ${_searchCenter!.coordinates.lat.toStringAsFixed(4)}, ${_searchCenter!.coordinates.lng.toStringAsFixed(4)}',
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // Results Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.list, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'nearby_workshops'.tr + ' (${_nearbyWorkshops.length})',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (_nearbyWorkshops.isNotEmpty)
                  TextButton(
                    onPressed: _showAllResults,
                    child: Text('view_all'.tr),
                  ),
              ],
            ),
          ),

          // Results List
          Expanded(
            child: _nearbyWorkshops.isEmpty
                ? _buildEmptyResults()
                : ListView.builder(
              itemCount: _nearbyWorkshops.length,
              itemBuilder: (context, index) {
                final workshop = _nearbyWorkshops[index];
                return _buildWorkshopListItem(workshop);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkshopListItem(WorkshopModel workshop) {
    final distance = _calculateDistance(workshop);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
        child: Text(
          workshop.name.isNotEmpty ? workshop.name[0].toUpperCase() : 'W',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        workshop.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workshop.workingHours,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                mapController.formatDistance(distance),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
      onTap: () {
        _focusOnWorkshop(workshop);
      },
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'no_workshops_found'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedServiceType != null
                  ? 'try_different_radius_or_location'.tr
                  : 'select_service_type_first'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    mapController.setMapboxMap(mapboxMap);
    _setupAnnotationManagers();
  }

  Future<void> _setupAnnotationManagers() async {
    await mapController.setupAnnotationManagers();
  }

  // Handle map tap to detect nearby workshops - Updated for new Mapbox version
  void _onMapTap(ScreenCoordinate coordinate) {
    if (_mapboxMap != null) {
      _mapboxMap!.coordinateForPixel(coordinate).then((point) {
        // Extract coordinates from Point object
        final coordinates = point.coordinates;
        final lat = coordinates.lat.toDouble();
        final lng = coordinates.lng.toDouble();

        // Create Point for search center
        final searchPoint = Point(
          coordinates: Position(lng, lat),
        );

        setState(() {
          _searchCenter = searchPoint;
        });
        _updateSearchCircle();
      }).catchError((error) {
        print('Error getting coordinates: $error');
      });
    }
  }

  Future<void> _setInitialSearchCenter() async {
    await mapController.getCurrentLocation();
    final currentPos = mapController.currentPosition.value;

    if (currentPos != null) {
      setState(() {
        _searchCenter = Point(
          coordinates: Position(currentPos.longitude, currentPos.latitude),
        );
      });

      if (_mapboxMap != null) {
        await mapController.flyToLocation(
          currentPos.latitude,
          currentPos.longitude,
          zoom: 12.0,
        );
      }

      _updateSearchCircle();
    }
  }

  void _goToCurrentLocation() {
    final currentPos = mapController.currentPosition.value;
    if (currentPos != null && _mapboxMap != null) {
      final currentPoint = Point(
        coordinates: Position(currentPos.longitude, currentPos.latitude),
      );

      setState(() {
        _searchCenter = currentPoint;
      });

      mapController.flyToLocation(
        currentPos.latitude,
        currentPos.longitude,
        zoom: 15.0,
      );

      _updateSearchCircle();
    } else {
      mapController.getCurrentLocation();
    }
  }

  Future<void> _updateSearchCircle() async {
    if (_searchCenter == null) return;

    await mapController.clearCircles();
    await mapController.addCircle(
      _searchCenter!.coordinates.lat.toDouble(),
      _searchCenter!.coordinates.lng.toDouble(),
      mapController.kilometersToMeters(_radiusKm),
      fillColor: AppColors.primary.withValues(alpha: 0.2).value,
      strokeColor: AppColors.primary.value,
      strokeWidth: 2.0,
    );
  }

  void _updateSearchRadius() {
    _updateSearchCircle();
  }

  Future<void> _searchNearbyWorkshops() async {
    if (_searchCenter == null || _selectedServiceType == null) {
      Get.snackbar(
        'error'.tr,
        'select_location_and_service'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await workshopController.loadNearbyWorkshopsByServiceType(
        serviceType: _selectedServiceType!.name,
        longitude: _searchCenter!.coordinates.lng.toDouble(),
        latitude: _searchCenter!.coordinates.lat.toDouble(),
        radiusMeters: mapController.kilometersToMeters(_radiusKm).toInt(),
      );

      setState(() {
        _nearbyWorkshops = workshopController.nearbyWorkshops.toList();
      });

      await _addWorkshopMarkers();

      Get.snackbar(
        'search_complete'.tr,
        'found_workshops'.tr.replaceAll('{count}', _nearbyWorkshops.length.toString()),
        backgroundColor: AppColors.success.withValues(alpha: 0.1),
        colorText: AppColors.success,
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'search_failed'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addWorkshopMarkers() async {
    await mapController.clearMarkers();

    for (final workshop in _nearbyWorkshops) {
      await mapController.addMarker(
        workshop.latitude,
        workshop.longitude,
        title: workshop.name,
        userData: {'workshopId': workshop.id},
      );
    }
  }

  void _focusOnWorkshop(WorkshopModel workshop) {
    if (_mapboxMap != null) {
      mapController.flyToLocation(
        workshop.latitude,
        workshop.longitude,
        zoom: 16.0,
      );

      _showWorkshopBottomSheet(workshop);
    }
  }

  void _showWorkshopBottomSheet(WorkshopModel workshop) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      workshop.name.isNotEmpty ? workshop.name[0].toUpperCase() : 'W',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              workshop.workingHours,
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              mapController.formatDistance(_calculateDistance(workshop)),
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                workshop.description,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(
                          AppRoutes.workshopDetails,
                          arguments: workshop,
                        );
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
                        Get.back();
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
        ),
      ),
    );
  }

  void _showAllResults() {
    Get.toNamed(
      AppRoutes.filteredServices,
      arguments: {
        'serviceType': _selectedServiceType,
        'title': _selectedServiceType?.displayName ?? 'Services',
        'workshops': _nearbyWorkshops,
        'isLocationBased': true,
      },
    );
  }

  void _getDirections(WorkshopModel workshop) {
    Get.snackbar(
      'directions'.tr,
      'opening_directions_to'.tr + ' ${workshop.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  double _calculateDistance(WorkshopModel workshop) {
    if (_searchCenter == null) return 0.0;

    return mapController.calculateDistance(
      _searchCenter!.coordinates.lat.toDouble(),
      _searchCenter!.coordinates.lng.toDouble(),
      workshop.latitude,
      workshop.longitude,
    );
  }
}