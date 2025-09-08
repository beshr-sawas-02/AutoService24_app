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
  const WorkshopDetailsView({super.key});

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
                style: const TextStyle(
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
                    child: const Icon(
                      Icons.business,
                      size: 80,
                      color: AppColors.textSecondary,
                    ),
                  );
                },
              )
                  : Container(
                color: AppColors.grey300,
                child: const Icon(
                  Icons.business,
                  size: 80,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.message),
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
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Workshop Info
                  _buildWorkshopInfo(),

                  const SizedBox(height: 24),

                  // Map
                  _buildLocationMap(),

                  const SizedBox(height: 24),

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
        label: Text('contact_workshop'.tr),
        icon: const Icon(Icons.message),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
    );
  }

  Widget _buildWorkshopInfo() {
    return Card(
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'workshop_information'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            _buildInfoRow(Icons.description, 'description'.tr, workshop.description),
            _buildInfoRow(Icons.access_time, 'working_hours'.tr, workshop.workingHours),
            _buildInfoRow(Icons.location_on, 'location'.tr,
                'Lat: ${workshop.latitude.toStringAsFixed(4)}, Lng: ${workshop.longitude.toStringAsFixed(4)}'),

            const SizedBox(height: 16),

            // Rating and Reviews (placeholder)
            Row(
              children: [
                const Icon(Icons.star, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'rating_reviews'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Show reviews
                  },
                  child: Text('view_reviews'.tr),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
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
              'services'.tr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                // Show all services
              },
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Obx(() {
          if (serviceController.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
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
            physics: const NeverScrollableScrollPhysics(),
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
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(
              Icons.build_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'no_services_available'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'workshop_no_services'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
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
      'chat'.tr,
      'starting_conversation'.tr + ' ${workshop.name}',
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
        title: Text('login_required'.tr, style: const TextStyle(color: AppColors.textPrimary)),
        content: Text('login_contact_workshops'.tr, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text('login'.tr),
          ),
        ],
      ),
    );
  }
}