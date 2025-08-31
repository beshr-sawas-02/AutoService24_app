import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/workshop_model.dart';
import '../../widgets/service_card.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class WorkshopDetailsView extends StatefulWidget {
  @override
  _WorkshopDetailsViewState createState() => _WorkshopDetailsViewState();
}

class _WorkshopDetailsViewState extends State<WorkshopDetailsView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();

  late WorkshopModel workshop;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    workshop = Get.arguments as WorkshopModel;
    _loadWorkshopServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                workshop.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              background: workshop.profileImage != null
                  ? Image.network(
                workshop.profileImage!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.grey300,
                    child: Icon(
                      Icons.business,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              )
                  : Container(
                color: AppColors.grey300,
                child: Icon(
                  Icons.business,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  if (authController.isGuest) {
                    _showGuestDialog();
                  } else {
                    _startChat();
                  }
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workshop Info
                  _buildWorkshopInfo(),

                  SizedBox(height: 24),

                  // Map
                  _buildLocationMap(),

                  SizedBox(height: 24),

                  // Services Section
                  _buildServicesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (authController.isGuest) {
            _showGuestDialog();
          } else {
            _startChat();
          }
        },
        label: Text('Contact Workshop'),
        icon: Icon(Icons.message),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildWorkshopInfo() {
    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workshop Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16),

            _buildInfoRow(Icons.description, 'Description', workshop.description),
            _buildInfoRow(Icons.access_time, 'Working Hours', workshop.workingHours),
            _buildInfoRow(Icons.location_on, 'Location',
                'Lat: ${workshop.latitude.toStringAsFixed(4)}, Lng: ${workshop.longitude.toStringAsFixed(4)}'),

            SizedBox(height: 16),

            // Rating and Reviews (placeholder)
            Row(
              children: [
                Icon(Icons.star, color: AppColors.warning),
                SizedBox(width: 8),
                Text(
                  '4.5 (24 reviews)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: () {
                    // Show reviews
                  },
                  child: Text('View Reviews'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(workshop.latitude, workshop.longitude),
            zoom: 15,
          ),
          markers: {
            Marker(
              markerId: MarkerId(workshop.id),
              position: LatLng(workshop.latitude, workshop.longitude),
              infoWindow: InfoWindow(
                title: workshop.name,
                snippet: workshop.workingHours,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            ),
          },
          zoomControlsEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          onTap: (LatLng location) {
            // Open full map view
            Get.toNamed(AppRoutes.map);
          },
        ),
      ),
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show all services
              },
              child: Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 16),

        Obx(() {
          if (serviceController.isLoading.value) {
            return Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          // Filter services for this workshop
          final workshopServices = serviceController.services
              .where((service) => service.workshopId == workshop.id)
              .toList();

          if (workshopServices.isEmpty) {
            return _buildEmptyServices();
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: workshopServices.length,
            itemBuilder: (context, index) {
              return ServiceCard(
                service: workshopServices[index],
                onTap: () {
                  Get.toNamed(
                    AppRoutes.serviceDetails,
                    arguments: workshopServices[index],
                  );
                },
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyServices() {
    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.build_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No services available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This workshop hasn\'t added any services yet',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _loadWorkshopServices() {
    // This would typically filter services by workshop ID
    serviceController.loadServices();
  }

  void _startChat() {
    // Navigate to chat with workshop owner
    Get.snackbar(
      'Chat',
      'Starting conversation with ${workshop.name}',
      snackPosition: SnackPosition.BOTTOM,
    );

    // In a real app, you would:
    // 1. Create or find existing chat
    // 2. Navigate to chat view
    Get.toNamed(AppRoutes.chatList);
  }

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: Text('Login Required', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Please login or register to contact workshops.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            child: Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}