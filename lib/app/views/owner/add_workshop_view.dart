import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import '../../controllers/workshop_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/map_controller.dart';
import '../../config/app_colors.dart';

class AddWorkshopView extends StatefulWidget {
  const AddWorkshopView({super.key});

  @override
  _AddWorkshopViewState createState() => _AddWorkshopViewState();
}

class _AddWorkshopViewState extends State<AddWorkshopView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final AuthController authController = Get.find<AuthController>();
  final MapController mapController = Get.find<MapController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workingHoursController = TextEditingController();

  geo.Position? _currentPosition;
  Point? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await mapController.checkLocationServices();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('add_workshop'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'create_your_workshop'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Workshop Name
              _buildTextField(
                controller: _nameController,
                labelText: 'workshop_name'.tr,
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_workshop_name'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                labelText: 'description'.tr,
                icon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_description'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Working Hours
              _buildTextField(
                controller: _workingHoursController,
                labelText: 'working_hours_example'.tr,
                icon: Icons.access_time,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_working_hours'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location Section
              Text(
                'workshop_location'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              // Location Selection Button
              InkWell(
                onTap: _openLocationPicker,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _selectedLocation != null
                          ? AppColors.success
                          : AppColors.border,
                      width: _selectedLocation != null ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedLocation != null
                            ? Icons.location_on
                            : Icons.location_off,
                        color: _selectedLocation != null
                            ? AppColors.success
                            : AppColors.textSecondary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedLocation != null
                                  ? 'location_selected'.tr
                                  : 'select_workshop_location'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _selectedLocation != null
                                    ? AppColors.success
                                    : AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedLocation != null
                                  ? '${'coordinates'.tr}: ${_selectedLocation!.coordinates.lat.toStringAsFixed(4)}, ${_selectedLocation!.coordinates.lng.toStringAsFixed(4)}'
                                  : 'tap_to_open_map'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                color: _selectedLocation != null
                                    ? AppColors.success.withValues(alpha: 0.8)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Create Button
              Obx(() => ElevatedButton(
                    onPressed: workshopController.isLoading.value
                        ? null
                        : _createWorkshop,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: workshopController.isLoading.value
                        ? const CircularProgressIndicator(
                            color: AppColors.white)
                        : Text('create_workshop'.tr),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.borderFocus),
        ),
        filled: true,
        fillColor: AppColors.white,
      ),
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator,
    );
  }

  Future<void> _openLocationPicker() async {
    final result = await Get.to(() => const LocationPickerView());
    if (result != null && result is Point) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await mapController.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _createWorkshop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_location'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    if (authController.currentUser.value?.id == null) {
      Get.snackbar('error'.tr, 'user_not_logged_in'.tr);
      return;
    }

    final workshopData = {
      'user_id': authController.currentUser.value!.id,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': {
        'type': 'Point',
        'coordinates': [
          _selectedLocation!.coordinates.lng.toDouble(),
          _selectedLocation!.coordinates.lat.toDouble(),
        ],
      },
      'working_hours': _workingHoursController.text.trim(),
    };

    final success = await workshopController.createWorkshop(workshopData);

    if (success) {
      Get.back();
      Get.snackbar(
        'success'.tr,
        'workshop_created_successfully'.tr,
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _workingHoursController.dispose();
    super.dispose();
  }
}

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key});

  @override
  _LocationPickerViewState createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  final MapController mapController = Get.find<MapController>();
  MapboxMap? _mapboxMap;
  Point? _selectedLocation;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('select_location'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          if (_selectedLocation != null)
            TextButton(
              onPressed: () {
                Get.back(result: _selectedLocation);
              },
              child: Text(
                'confirm'.tr,
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Full Screen Map
          Obx(() {
            final currentPos = mapController.currentPosition.value;
            return MapWidget(
              key: const ValueKey("locationPickerMap"),
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

          // Instructions Card
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'tap_map_to_select_workshop_location'.tr,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected Location Info Card
          if (_selectedLocation != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 4,
                color: AppColors.success.withValues(alpha: 0.9),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'location_selected_successfully'.tr,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_selectedLocation!.coordinates.lat.toStringAsFixed(6)}, ${_selectedLocation!.coordinates.lng.toStringAsFixed(6)}',
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Get.back(result: _selectedLocation);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: AppColors.success,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'confirm_location'.tr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Current Location Button
          Positioned(
            bottom: _selectedLocation != null ? 200 : 100,
            right: 16,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: AppColors.white,
              foregroundColor: AppColors.primary,
              mini: true,
              child: const Icon(Icons.my_location),
            ),
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
    if (_mapboxMap != null) {
      await mapController.setupAnnotationManagers();
    }
  }

  void _onMapTap(MapContentGestureContext context) {
    setState(() {
      _selectedLocation = context.point;
    });
    _addMarkerToMap(context.point);
  }

  Future<void> _addMarkerToMap(Point point) async {
    await mapController.clearMarkers();
    await mapController.addMarker(
      point.coordinates.lat.toDouble(),
      point.coordinates.lng.toDouble(),
      title: "Workshop Location",
    );
  }

  Future<void> _goToCurrentLocation() async {
    try {
      final position = await mapController.getCurrentLocation();
      if (_mapboxMap != null && position != null) {
        await mapController.flyToLocation(
          position.latitude,
          position.longitude,
          zoom: 15.0,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'cannot_get_current_location'.tr,
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
    }
  }
}
