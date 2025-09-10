import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../controllers/workshop_controller.dart';
import '../../controllers/map_controller.dart';
import '../../data/models/workshop_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final MapController mapController = Get.find<MapController>();

  MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await mapController.checkLocationServices();
    await _loadWorkshopMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('workshop_locations'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Get.toNamed(AppRoutes.workshopMapSearch);
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _goToCurrentLocation,
          ),
        ],
      ),
      body: Obx(() {
        final currentPos = mapController.currentPosition.value;
        return MapWidget(
          key: const ValueKey("workshopMapWidget"),
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
          //onTapListener: _onMapTap,
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "search",
            onPressed: () {
              Get.toNamed(AppRoutes.workshopMapSearch);
            },
            backgroundColor: AppColors.info,
            foregroundColor: AppColors.white,
            mini: true,
            child: const Icon(Icons.search),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "refresh",
            onPressed: _loadWorkshopMarkers,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            mini: true,
            child: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "location",
            onPressed: _goToCurrentLocation,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            child: const Icon(Icons.my_location),
          ),
        ],
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
    _loadWorkshopMarkers();
  }

  // Handle map tap to detect nearby workshops - Updated for new Mapbox version
  @override
  void onMapTap(ScreenCoordinate coordinate) {
    if (_mapboxMap != null) {
      _mapboxMap!.coordinateForPixel(coordinate).then((point) {
        // Extract coordinates from Point object with proper type casting
        final coordinates = point.coordinates;
        final lat = coordinates.lat.toDouble();
        final lng = coordinates.lng.toDouble();

        // Find the nearest workshop to the tap location
        WorkshopModel? nearestWorkshop = _findNearestWorkshop(lat, lng);

        if (nearestWorkshop != null) {
          _showWorkshopBottomSheet(nearestWorkshop);
        }
      }).catchError((error) {
        // Handle any errors in coordinate conversion
        print('Error getting coordinates: $error');
      });
    }
  }

  // Find nearest workshop to tap location
  WorkshopModel? _findNearestWorkshop(double lat, double lng) {
    WorkshopModel? nearest;
    double minDistance = double.infinity;
    const double maxTapDistance = 1000; // 1km maximum tap distance

    for (WorkshopModel workshop in workshopController.workshops) {
      if (workshop.latitude != 0.0 && workshop.longitude != 0.0) {
        double distance = mapController.calculateDistance(
            lat, lng,
            workshop.latitude, workshop.longitude
        );

        if (distance < minDistance && distance < maxTapDistance) {
          minDistance = distance;
          nearest = workshop;
        }
      }
    }

    return nearest;
  }

  void _goToCurrentLocation() {
    final currentPos = mapController.currentPosition.value;
    if (currentPos != null && _mapboxMap != null) {
      mapController.flyToLocation(
        currentPos.latitude,
        currentPos.longitude,
        zoom: 15.0,
      );
    } else {
      mapController.getCurrentLocation();
    }
  }

  Future<void> _loadWorkshopMarkers() async {
    await mapController.clearMarkers();

    // Add workshop markers (simplified - no userData)
    for (WorkshopModel workshop in workshopController.workshops) {
      if (workshop.latitude != 0.0 && workshop.longitude != 0.0) {
        await mapController.addMarker(
          workshop.latitude,
          workshop.longitude,
          title: workshop.name,
        );
      }
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
              // Handle bar
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

              // Workshop info
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.grey200,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: workshop.profileImage != null
                          ? Image.network(
                        workshop.profileImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.business, color: AppColors.grey400);
                        },
                      )
                          : const Icon(Icons.business, color: AppColors.grey400),
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

              // Action buttons
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

              // Distance info
              Obx(() {
                final currentPos = mapController.currentPosition.value;
                if (currentPos != null) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.directions_car, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          'distance'.tr + ': ${mapController.formatDistance(_calculateDistance(workshop, currentPos))}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              }),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateDistance(WorkshopModel workshop, geo.Position currentPosition) {
    return mapController.calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      workshop.latitude,
      workshop.longitude,
    );
  }

  void _getDirections(WorkshopModel workshop) {
    Get.snackbar(
      'directions'.tr,
      'opening_directions_to'.tr + ' ${workshop.name}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}