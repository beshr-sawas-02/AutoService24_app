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
  bool _isDisposed = false;
  bool _showSearchOptions = false;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>?;
    _selectedServiceType = arguments?['serviceType'] as ServiceType?;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (_isDisposed) return;
    await mapController.checkLocationServices();
    _setInitialSearchCenter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Map
          Positioned.fill(
            child: Obx(() {
              final currentPos = mapController.currentPosition.value;
              return MapWidget(
                key: ValueKey("workshopSearchMap"),
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
                onTapListener: (MapContentGestureContext context) {
                  _onMapTap(context);
                },
              );
            }),
          ),

          // Top Search Bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildTopSearchBar(),
          ),

          // Radius Slider (positioned on left side)
          Positioned(
            left: 16,
            top: MediaQuery.of(context).padding.top + 120,
            child: _buildRadiusSlider(),
          ),

          // Current Location Button
          Positioned(
            right: 16,
            top: MediaQuery.of(context).padding.top + 120,
            child: Column(
              children: [
                _buildLocationButton(),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.radio_button_unchecked,
                        color: Colors.white),
                    onPressed: () {
                      if (_searchCenter != null) {
                        _updateSearchCircle();
                      } else {
                        setState(() {
                          _searchCenter = Point(
                            coordinates: Position(36.2765, 33.5138),
                          );
                        });
                        _updateSearchCircle();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Search Options Panel (expandable)
          if (_showSearchOptions)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 16,
              right: 16,
              child: _buildSearchOptionsPanel(),
            ),

          // Bottom Results Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomResultsPanel(),
          ),

          // Search FAB
          Positioned(
            bottom: _nearbyWorkshops.isEmpty ? 120 : 200,
            right: 16,
            child: _buildSearchFAB(),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Get.back(),
          ),

          // Search Input
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showSearchOptions = !_showSearchOptions;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _selectedServiceType?.displayName ?? 'select_service_type'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: _selectedServiceType != null
                        ? Colors.black87
                        : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),

          // Search Icon
          IconButton(
            icon: Icon(
              _showSearchOptions ? Icons.expand_less : Icons.expand_more,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showSearchOptions = !_showSearchOptions;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOptionsPanel() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'select_service_type'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Service Types Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: ServiceType.values.length,
            itemBuilder: (context, index) {
              final serviceType = ServiceType.values[index];
              final isSelected = _selectedServiceType == serviceType;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedServiceType = serviceType;
                    _showSearchOptions = false;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      serviceType.displayName,
                      style: TextStyle(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[700],
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSlider() {
    return Container(
      height: 200,
      width: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Radius Text
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${_radiusKm.toInt()}\nkm',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Vertical Slider
          Expanded(
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
                  overlayShape:
                      const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: _radiusKm,
                  min: 1.0,
                  max: 100.0,
                  divisions: 99,
                  activeColor: AppColors.primary,
                  onChanged: (value) {
                    if (mounted && !_isDisposed) {
                      setState(() {
                        _radiusKm = value;
                      });
                      _updateSearchRadius();
                    }
                  },
                ),
              ),
            ),
          ),

          // Radius Label
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.radio_button_unchecked,
              size: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.my_location, color: AppColors.primary),
        onPressed: _goToCurrentLocation,
      ),
    );
  }

  Widget _buildBottomResultsPanel() {
    if (_nearbyWorkshops.isEmpty) {
      return Container(
        height: 100,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search,
                size: 32,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedServiceType != null
                    ? 'tap_search_to_find_workshops'.tr
                    : 'select_service_type_first'.tr,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.1,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text(
                      'nearby_workshops'.tr + ' (${_nearbyWorkshops.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _showAllResults,
                      child: Text('view_all'.tr),
                    ),
                  ],
                ),
              ),

              // Results List
              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _nearbyWorkshops.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final workshop = _nearbyWorkshops[index];
                    return _buildWorkshopListItem(workshop);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchFAB() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: _searchNearbyWorkshops,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else
                  const Icon(Icons.search, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  'search'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopListItem(WorkshopModel workshop) {
    final distance = _calculateDistance(workshop);

    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8),
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          workshop.name.isNotEmpty ? workshop.name[0].toUpperCase() : 'W',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        workshop.name,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            workshop.workingHours,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                mapController.formatDistance(distance),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing:
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {
        _focusOnWorkshop(workshop);
      },
    );
  }

  // Map Event Handlers
  void _onMapCreated(MapboxMap mapboxMap) {
    if (_isDisposed) return;
    _mapboxMap = mapboxMap;
    mapController.setMapboxMap(mapboxMap);
    _setupAnnotationManagers();
  }

  Future<void> _setupAnnotationManagers() async {
    if (_isDisposed || _mapboxMap == null) return;
    await mapController.setupAnnotationManagers();
  }

  void _onMapTap(MapContentGestureContext context) {
    if (_isDisposed) return;
    setState(() {
      _searchCenter = context.point;
      _showSearchOptions = false; // Hide options when tapping map
    });
    _updateSearchCircle();
  }

  Future<void> _setInitialSearchCenter() async {
    if (_isDisposed) return;
    await mapController.getCurrentLocation();
    final currentPos = mapController.currentPosition.value;

    if (currentPos != null && !_isDisposed) {
      if (mounted) {
        setState(() {
          _searchCenter = Point(
            coordinates: Position(currentPos.longitude, currentPos.latitude),
          );
        });
      }

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
    if (_isDisposed) return;
    final currentPos = mapController.currentPosition.value;
    if (currentPos != null && _mapboxMap != null) {
      final currentPoint = Point(
        coordinates: Position(currentPos.longitude, currentPos.latitude),
      );

      if (mounted) {
        setState(() {
          _searchCenter = currentPoint;
        });
      }

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
    if (_searchCenter == null || _isDisposed) return;

    await mapController.clearCircles();
    await mapController.addCircle(
      _searchCenter!.coordinates.lat.toDouble(),
      _searchCenter!.coordinates.lng.toDouble(),
      mapController.kilometersToMeters(_radiusKm),
      fillColor: AppColors.primary.withOpacity(0.2).value,
      strokeColor: AppColors.primary.value,
      strokeWidth: 2.0,
    );
  }

  void _updateSearchRadius() {
    if (_isDisposed) return;
    _updateSearchCircle();
  }

  Future<void> _searchNearbyWorkshops() async {
    if (_searchCenter == null || _selectedServiceType == null || _isDisposed) {
      Get.snackbar(
        'error'.tr,
        'select_location_and_service'.tr,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await workshopController.loadNearbyWorkshopsByServiceType(
        serviceType: _selectedServiceType!.name,
        longitude: _searchCenter!.coordinates.lng.toDouble(),
        latitude: _searchCenter!.coordinates.lat.toDouble(),
        radiusMeters: mapController.kilometersToMeters(_radiusKm).toInt(),
      );

      if (mounted && !_isDisposed) {
        setState(() {
          _nearbyWorkshops = workshopController.nearbyWorkshops.toList();
        });
      }

      if (_nearbyWorkshops.isNotEmpty) {
        await _addWorkshopMarkers();

        Get.snackbar(
          'search_complete'.tr,
          'found_workshops'
              .tr
              .replaceAll('{count}', _nearbyWorkshops.length.toString()),
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
      } else {
        Get.snackbar(
          'search_complete'.tr,
          'no_workshops_found_in_area'.tr,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          colorText: AppColors.warning,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'search_failed'.tr,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addWorkshopMarkers() async {
    if (_isDisposed) return;
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
    if (_mapboxMap != null && !_isDisposed) {
      mapController.flyToLocation(
        workshop.latitude,
        workshop.longitude,
        zoom: 16.0,
      );
      _showWorkshopBottomSheet(workshop);
    }
  }

  void _showWorkshopBottomSheet(WorkshopModel workshop) {
    if (_isDisposed) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.3,
        maxChildSize: 0.8,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primary.withOpacity(0.2),
                      child: Text(
                        workshop.name.isNotEmpty
                            ? workshop.name[0].toUpperCase()
                            : 'W',
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
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  workshop.workingHours,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(
                                mapController.formatDistance(
                                    _calculateDistance(workshop)),
                                style: const TextStyle(color: Colors.grey),
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
                    color: Colors.grey,
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
                          foregroundColor: Colors.white,
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
      ),
    );
  }

  void _showAllResults() {
    if (_isDisposed) return;
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

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
