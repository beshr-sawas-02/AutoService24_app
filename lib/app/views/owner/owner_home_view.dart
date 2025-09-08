import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../routes/app_routes.dart';
import '../../data/models/service_model.dart';
import '../../config/app_colors.dart';

class OwnerHomeView extends StatefulWidget {
  const OwnerHomeView({super.key});

  @override
  _OwnerHomeViewState createState() => _OwnerHomeViewState();
}

class _OwnerHomeViewState extends State<OwnerHomeView> {
  int _currentIndex = 0;
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final userId = authController.currentUser.value?.id;
    if (userId != null) {
      await workshopController.loadOwnerWorkshops(userId);
      await serviceController.loadOwnerServices();
    } else {
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'carservicehub_owner'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.message, color: AppColors.textSecondary),
            onPressed: () => Get.toNamed(AppRoutes.chatList),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
            onPressed: () => _showLogoutDialog(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: _getBody(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
        elevation: 8,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed(AppRoutes.ownerProfile);
            return;
          }
          if (index == 2) {
            Get.toNamed(AppRoutes.addWorkshop);
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'home'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.add_business),
            label: 'add_workshop'.tr,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addService),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        tooltip: 'add_service'.tr,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _getBody() {
    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                Text(
                  'service_categories'.tr,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                _buildServiceCategories(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryWithOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.business_center, color: AppColors.white, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(() => Text(
              'hello_user'.tr.replaceAll('{name}', authController.displayName),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCategories() {
    final categories = [
      {
        'title': 'vehicle_inspection',
        'type': ServiceType.VEHICLE_INSPECTION,
        'color': AppColors.primary,
        'image': 'assets/images/vehicle_inspection.jpg',
      },
      {
        'title': 'change_oil',
        'type': ServiceType.CHANGE_OIL,
        'color': AppColors.info,
        'image': 'assets/images/oil_change.jpg',
      },
      {
        'title': 'change_tires',
        'type': ServiceType.CHANGE_TIRES,
        'color': AppColors.grey500,
        'image': 'assets/images/change_tires.jpg',
      },
      {
        'title': 'remove_install_tires',
        'type': ServiceType.REMOVE_INSTALL_TIRES,
        'color': Colors.purple,
        'image': 'assets/images/remove.jpg',
      },
      {
        'title': 'cleaning',
        'type': ServiceType.CLEANING,
        'color': AppColors.success,
        'image': 'assets/images/car_cleaning.jpg',
      },
      {
        'title': 'diagnostic_test',
        'type': ServiceType.DIAGNOSTIC_TEST,
        'color': AppColors.error,
        'image': 'assets/images/diagnostic.jpg',
      },
      {
        'title': 'pre_tuv_check',
        'type': ServiceType.PRE_TUV_CHECK,
        'color': Colors.teal,
        'image': 'assets/images/pre_tuv.jpg',
      },
      {
        'title': 'balance_tires',
        'type': ServiceType.BALANCE_TIRES,
        'color': Colors.indigo,
        'image': 'assets/images/tire_balance.jpg',
      },
      {
        'title': 'wheel_alignment',
        'type': ServiceType.WHEEL_ALIGNMENT,
        'color': Colors.deepPurple,
        'image': 'assets/images/wheel_alignment.jpg',
      },
      {
        'title': 'polish',
        'type': ServiceType.POLISH,
        'color': AppColors.warning,
        'image': 'assets/images/car_polish.jpg',
      },
      {
        'title': 'change_brake_fluid',
        'type': ServiceType.CHANGE_BRAKE_FLUID,
        'color': Colors.brown,
        'image': 'assets/images/brake_fluid.jpg',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              AppRoutes.filteredServices,
              arguments: {
                'serviceType': category['type'] as ServiceType,
                'title': (category['title'] as String).tr,
                'isOwner': true,
              },
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMedium,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    category['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (category['color'] as Color).withValues(alpha: 0.8),
                              (category['color'] as Color).withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.blackWithOpacity(0.1),
                          AppColors.blackWithOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      (category['title'] as String).tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppColors.blackWithOpacity(0.7),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog() {
    Get.dialog(AlertDialog(
      title: Text('logout'.tr),
      content: Text('are_you_sure_logout'.tr),
      actions: [
        TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: AppColors.textSecondary))
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            authController.logout();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.white,
          ),
          child: Text('logout'.tr),
        ),
      ],
    ));
  }
}