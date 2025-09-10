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

  MapboxMap? _mapboxMap;
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
              const SizedBox(height: 8),
              Text(
                'tap_map_select_location'.tr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Mapbox Map
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Obx(() {
                    final currentPos = mapController.currentPosition.value;
                    return MapWidget(
                      key: const ValueKey("mapWidget"),
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
                      // onTapListener: OnMapTapListener(
                      //   onMapTap: _onMapTap,
                      // ),
                    );
                  }),
                ),
              ),

              if (_selectedLocation != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'location_selected'.tr +
                              ': ${_selectedLocation!.coordinates.lat.toStringAsFixed(4)}, ${_selectedLocation!.coordinates.lng.toStringAsFixed(4)}',
                          style: const TextStyle(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Create Button
              Obx(() => ElevatedButton(
                onPressed: workshopController.isLoading.value ? null : _createWorkshop,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: workshopController.isLoading.value
                    ? const CircularProgressIndicator(color: AppColors.white)
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

  void _onMapTap(ScreenCoordinate coordinate) {
    if (_mapboxMap != null) {
      _mapboxMap!.coordinateForPixel(coordinate).then((point) {
        // Point object is returned directly, no need to convert from Map
        setState(() {
          _selectedLocation = point;
        });
        _addMarkerToMap(point);
      }).catchError((error) {
        print('Error getting coordinates: $error');
      });
    }
  }

  Future<void> _addMarkerToMap(Point point) async {
    await mapController.clearMarkers();
    await mapController.addMarker(
      point.coordinates.lat.toDouble(),
      point.coordinates.lng.toDouble(),
      title: "Workshop Location",
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await mapController.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });

      // Move camera to current location
      if (_mapboxMap != null && position != null) {
        await mapController.flyToLocation(
          position.latitude,
          position.longitude,
          zoom: 15.0,
        );
      }
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