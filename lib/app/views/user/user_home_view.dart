import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/Language_Controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/guest_banner.dart';
import '../../config/app_colors.dart';

class UserHomeView extends StatefulWidget {
  const UserHomeView({super.key});

  @override
  _UserHomeViewState createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  int _currentIndex = 0;
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  final List<Map<String, dynamic>> categories = [
    {
      'title': 'vehicle_inspection',
      'type': ServiceType.VEHICLE_INSPECTION,
      'color': AppColors.primary,
      'image': 'assets/images/vehicle.jpg',
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
      'image': 'assets/images/cleaning.jpg',
    },
    {
      'title': 'diagnostic_test',
      'type': ServiceType.DIAGNOSTIC_TEST,
      'color': AppColors.error,
      'image': 'assets/images/diagnostic.jpg',
    },
    {
      'title': 'AU & TÜV',
      'type': ServiceType.AU_TUV,
      'color': Colors.teal,
      'image': 'assets/images/au_tuv.jpg',
    },
    {
      'title': 'balance_tires',
      'type': ServiceType.BALANCE_TIRES,
      'color': Colors.indigo,
      'image': 'assets/images/balance.jpg',
    },
    {
      'title': 'wheel_alignment',
      'type': ServiceType.WHEEL_ALIGNMENT,
      'color': Colors.deepPurple,
      'image': 'assets/images/wheel.jpg',
    },
    {
      'title': 'polish',
      'type': ServiceType.POLISH,
      'color': AppColors.warning,
      'image': 'assets/images/polish.jpg',
    },
    {
      'title': 'change_brake_fluid',
      'type': ServiceType.CHANGE_BRAKE_FLUID,
      'color': Colors.brown,
      'image': 'assets/images/brake_fluid.jpg',
    },
  ];

  Future<void> _handleRefresh() async {
    try {
      final serviceController = Get.find<ServiceController>();
      await serviceController.loadServices();
    } catch (e) {
      Get.snackbar(
        "error".tr,
        "failed_refresh_services".tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.8),
        colorText: AppColors.white,
      );
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
          'auto_services'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          _buildLanguageSwitcher(),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: AppColors.white,
        elevation: 8,
        onTap: (index) {
          if (index == 1) {
            Get.toNamed(AppRoutes.savedServices);
            return;
          }
          if (index == 2) {
            Get.toNamed(AppRoutes.chatList);
            return;
          }
          if (index == 3) {
            Get.toNamed(AppRoutes.userProfile);
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
            icon: const Icon(Icons.bookmark),
            label: 'saved'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.message),
            label: 'chat'.tr,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: 'profile'.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    final LanguageController languageController = Get.find<LanguageController>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: AppColors.textSecondary),
      tooltip: 'switch_language'.tr,
      onSelected: (String languageCode) {
        languageController.changeLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              Text('english'.tr),
              if (languageController.locale.value.languageCode == 'en')
                const Spacer()
              else
                const SizedBox.shrink(),
              if (languageController.locale.value.languageCode == 'en')
                const Icon(Icons.check, color: AppColors.primary)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'de',
          child: Row(
            children: [
              const Text('🇩🇪'),
              const SizedBox(width: 8),
              Text('german'.tr),
              if (languageController.locale.value.languageCode == 'de')
                const Spacer()
              else
                const SizedBox.shrink(),
              if (languageController.locale.value.languageCode == 'de')
                const Icon(Icons.check, color: AppColors.primary)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _getBody() {
    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    final filteredCategories = categories.where((cat) {
      final title = (cat['title'] as String).tr.toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Obx(() => authController.isGuest
            ? const GuestBanner()
            : const SizedBox.shrink()),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: AppColors.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  Text(
                    'categories'.tr,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildServiceCategories(filteredCategories),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'search_categories'.tr,
          hintStyle: const TextStyle(color: AppColors.textHint),
          prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildServiceCategories(List<Map<String, dynamic>> categoriesToShow) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: categoriesToShow.length,
      itemBuilder: (context, index) {
        final category = categoriesToShow[index];
        return GestureDetector(
          onTap: () {
            Get.toNamed(
              AppRoutes.filteredServices,
              arguments: {
                'serviceType': category['type'] as ServiceType,
                'title': (category['title'] as String).tr,
                'isOwner': false,
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
                              (category['color'] as Color)
                                  .withValues(alpha: 0.8),
                              (category['color'] as Color)
                                  .withValues(alpha: 0.6),
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

}