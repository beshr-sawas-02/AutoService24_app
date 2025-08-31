import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class AddWorkshopView extends StatefulWidget {
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
        title: Text('Add Workshop'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Workshop',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              // Workshop Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Workshop Name',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.business, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.borderFocus),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                style: TextStyle(color: AppColors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter workshop name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.description, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.borderFocus),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                style: TextStyle(color: AppColors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Working Hours
              TextFormField(
                controller: _workingHoursController,
                decoration: InputDecoration(
                  labelText: 'Working Hours (e.g., 8:00 AM - 6:00 PM)',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(Icons.access_time, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.borderFocus),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                style: TextStyle(color: AppColors.textPrimary),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter working hours';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Location Section
              Text(
                'Workshop Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Tap on the map to select your workshop location',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 12),

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
                    initialCameraPosition: CameraPosition(
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
                        markerId: MarkerId('workshop'),
                        position: _selectedLocation!,
                        infoWindow: InfoWindow(
                          title: 'Workshop Location',
                        ),
                      ),
                    }
                        : {},
                  ),
                ),
              ),

              if (_selectedLocation != null) ...[
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Location selected: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(color: AppColors.success),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 32),

              // Create Button
              Obx(() => ElevatedButton(
                onPressed: workshopController.isLoading.value ? null : _createWorkshop,
                child: workshopController.isLoading.value
                    ? CircularProgressIndicator(color: AppColors.white)
                    : Text('Create Workshop'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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