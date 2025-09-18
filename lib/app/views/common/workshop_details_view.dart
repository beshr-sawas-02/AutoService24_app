import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/map_controller.dart';
import '../../data/models/workshop_model.dart';
import '../../widgets/service_card.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';
import '../../utils/constants.dart';

class WorkshopDetailsView extends StatefulWidget {
  const WorkshopDetailsView({super.key});

  @override
  _WorkshopDetailsViewState createState() => _WorkshopDetailsViewState();
}

class _WorkshopDetailsViewState extends State<WorkshopDetailsView> {
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();
  final MapController mapController = Get.find<MapController>();

  late WorkshopModel workshop;
  MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();
    workshop = Get.arguments as WorkshopModel;

    // تأخير تحميل الخدمات
    Future.delayed(Duration.zero, () {
      _loadWorkshopServices();
    });
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
                AppConstants.buildImageUrl(workshop.profileImage!),
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
            _buildInfoRow(
                Icons.description, 'description'.tr, workshop.description),
            _buildInfoRow(
                Icons.access_time, 'working_hours'.tr, workshop.workingHours),
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
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textPrimary),
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
        child: MapWidget(
          key: const ValueKey("workshopDetailsMap"),
          cameraOptions: CameraOptions(
            center: Point(
              coordinates: Position(
                workshop.longitude,
                workshop.latitude,
              ),
            ),
            zoom: 15.0,
          ),
          onMapCreated: _onMapCreated,
          onTapListener: (MapContentGestureContext context) {
            _onMapTap(context);
          },
        ),
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    mapController.setMapboxMap(mapboxMap);

    // استخدام الوظيفة المُحسنة مع فحص الاتصال
    Future.delayed(const Duration(milliseconds: 2000), () {
      _setupMapWithWorkshopMarker();
    });
  }

  Future<void> _setupMapWithWorkshopMarker() async {
    if (_mapboxMap != null) {
      try {
        // استخدام الوظيفة المُحسنة
        await mapController.setupAnnotationManagersWithHealthCheck();

        // تأخير إضافي قبل إضافة العلامة
        await Future.delayed(const Duration(milliseconds: 500));

        // Add workshop marker
        await mapController.addMarker(
          workshop.latitude,
          workshop.longitude,
          title: workshop.name,
          userData: {'workshopId': workshop.id},
        );

        print('Workshop marker added successfully');
      } catch (e) {
        print('Error setting up workshop marker: $e');
        // لا تُظهر خطأ للمستخدم، فقط سجل في console
      }
    }
  }

  void _onMapTap(MapContentGestureContext context) {
    // Open full map view when tapped
    Get.toNamed(AppRoutes.map);
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
                // Show all services for this workshop
                _showAllWorkshopServices();
              },
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (serviceController.isLoading.value) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
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
            itemCount: workshopServices.length > 3
                ? 3
                : workshopServices.length, // Show max 3 services
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
    // Load services for this workshop
    serviceController.loadServices();
  }

  void _showAllWorkshopServices() {
    final workshopServices = serviceController.services
        .where((service) => service.workshopId == workshop.id)
        .toList();

    if (workshopServices.isNotEmpty) {

      Get.to(() => Scaffold(
        appBar: AppBar(
          title: Text('${workshop.name} ${'services'.tr}'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
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
        ),
      ));
    }
  }
  void _startChat() {
    // Navigate to chat with workshop owner
    Get.snackbar(
      'chat'.tr,
      '${'starting_conversation'.tr} ${workshop.name}',
      snackPosition: SnackPosition.BOTTOM,
    );

    // In a real app, you would:
    // 1. Create or find existing chat
    // 2. Navigate to chat view
    Get.toNamed(
      AppRoutes.chat,
      arguments: {
        'receiverId': workshop.userId,
        'receiverName': workshop.name,
        'currentUserId': authController.currentUser.value?.id,
      },
    );
  }

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'login_required'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'login_contact_workshops'.tr,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'cancel'.tr,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('login'.tr),
          ),
        ],
      ),
    );
  }
}