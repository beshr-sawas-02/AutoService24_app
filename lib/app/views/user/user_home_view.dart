import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/guest_banner.dart';
import '../../config/app_colors.dart';

class UserHomeView extends StatelessWidget {
  UserHomeView({super.key});

  final AuthController authController = Get.find<AuthController>();
  final LanguageController languageController = Get.find<LanguageController>();

  final RxString searchQuery = ''.obs;

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
      'title': 'au_tuv',
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
    {
      'title': 'tire_storage',
      'type': ServiceType.TIRR_STORAGE,
      'color': Colors.brown,
      'image': 'assets/images/tire_storage.jpg',
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
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          _LanguageSwitcher(languageController: languageController),
        ],
      ),
      body: _HomeBody(
        authController: authController,
        categories: categories,
        searchQuery: searchQuery,
        onRefresh: _handleRefresh,
      ),
      bottomNavigationBar: _BottomNav(),
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  final LanguageController languageController;

  const _LanguageSwitcher({required this.languageController});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: AppColors.textSecondary),
      tooltip: 'switch_language'.tr,
      onSelected: (String languageCode) {
        languageController.changeLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        _buildItem('en', '🇺🇸', 'english'.tr),
        _buildItem('de', '🇩🇪', 'german'.tr),
      ],
    );
  }

  PopupMenuItem<String> _buildItem(String code, String flag, String text) {
    final isSelected = languageController.locale.value.languageCode == code;
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        children: [
          Text(flag),
          const SizedBox(width: 8),
          Text(text),
          const Spacer(),
          if (isSelected) const Icon(Icons.check, color: AppColors.primary),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final AuthController authController;
  final List<Map<String, dynamic>> categories;
  final RxString searchQuery;
  final Future<void> Function() onRefresh;

  const _HomeBody({
    required this.authController,
    required this.categories,
    required this.searchQuery,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() => authController.isGuest
            ? const GuestBanner()
            : const SizedBox.shrink()),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: AppColors.primary,
            child: Obx(() {
              final filtered = categories.where((cat) {
                final title = (cat['title'] as String).tr.toLowerCase();
                return title.contains(searchQuery.value.toLowerCase());
              }).toList();

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(searchQuery: searchQuery),
                    const SizedBox(height: 24),
                    Text(
                      'categories'.tr,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                    ),
                    const SizedBox(height: 20),
                    _ServiceCategories(categoriesToShow: filtered),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final RxString searchQuery;

  const _SearchBar({required this.searchQuery});

  @override
  Widget build(BuildContext context) {
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
        onChanged: (query) => searchQuery.value = query,
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
      ),
    );
  }
}

class _ServiceCategories extends StatelessWidget {
  final List<Map<String, dynamic>> categoriesToShow;

  const _ServiceCategories({required this.categoriesToShow});

  @override
  Widget build(BuildContext context) {
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
        return InkWell(
          borderRadius: BorderRadius.circular(16),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
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

class _BottomNav extends StatefulWidget {
  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
    );
  }
}
