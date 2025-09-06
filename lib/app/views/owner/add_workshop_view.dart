import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/app_colors.dart';

class AddWorkshopView extends StatefulWidget {
  const AddWorkshopView({super.key});

  @override
  _AddWorkshopViewState createState() => _AddWorkshopViewState();
}

class _AddWorkshopViewState extends State<AddWorkshopView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _workingHoursController = TextEditingController();

  LatLng? _selectedLocation;
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Workshop'),
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
              const Text(
                'Create Your Workshop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Workshop Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Workshop Name',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.business, color: AppColors.textSecondary),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter workshop name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.description, color: AppColors.textSecondary),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Working Hours
              TextFormField(
                controller: _workingHoursController,
                decoration: InputDecoration(
                  labelText: 'Working Hours (e.g., 8:00 AM - 6:00 PM)',
                  labelStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon: const Icon(Icons.access_time, color: AppColors.textSecondary),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter working hours';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Location Section
              const Text(
                'Workshop Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap on the map to select your workshop location',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 12),

              // Map
              Container(
                height: 300,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(33.5138, 36.2765), // Damascus, Syria default
                      zoom: 12,
                    ),
                    onTap: (LatLng location) {
                      setState(() {
                        _selectedLocation = location;
                      });
                    },
                    markers: _selectedLocation != null
                        ? {
                      Marker(
                        markerId: const MarkerId('workshop'),
                        position: _selectedLocation!,
                        infoWindow: const InfoWindow(
                          title: 'Workshop Location',
                        ),
                      ),
                    }
                        : {},
                  ),
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
                          'Location selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
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
                    : const Text('Create Workshop'),
              )),
            ],
          ),
        ),
      ),
    );
  }

  void _createWorkshop() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedLocation == null) {
      Get.snackbar(
        'Error',
        'Please select a location on the map',
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    if (authController.currentUser.value?.id == null) {
      Get.snackbar('Error', 'User not logged in');
      return;
    }

    final workshopData = {
      'user_id': authController.currentUser.value!.id,
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location_x': _selectedLocation!.latitude.toString(),
      'location_y': _selectedLocation!.longitude.toString(),
      'working_hours': _workingHoursController.text.trim(),
    };

    final success = await workshopController.createWorkshop(workshopData);

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Workshop created successfully!',
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