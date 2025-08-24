import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/service_card.dart';
import '../../widgets/guest_banner.dart';

class UserHomeView extends StatefulWidget {
  @override
  _UserHomeViewState createState() => _UserHomeViewState();
}

class _UserHomeViewState extends State<UserHomeView> {
  int _currentIndex = 0;
  final AuthController authController = Get.find<AuthController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      serviceController.loadServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'CarServiceHub',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: Colors.black54),
            onPressed: () {
              if (authController.isGuest) {
                _showGuestDialog();
              } else {
                Get.toNamed(AppRoutes.chatList);
              }
            },
          ),
          Obx(() {
            if (authController.isGuest) return SizedBox.shrink();
            return IconButton(
              icon: Icon(Icons.logout, color: Colors.black54),
              onPressed: () async {
                await authController.logout();
              },
            );
          }),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 8,
        onTap: (index) {
          if (authController.isGuest && index != 0) {
            _showGuestDialog();
            return;
          }

          if (index == 2) {
            Get.toNamed(AppRoutes.userProfile);
            return;
          }

          if (index == 1) {
            Get.toNamed(AppRoutes.savedServices);
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    return _buildHomeContent();
  }

  Widget _buildHomeContent() {
    return Column(
      children: [
        Obx(() => authController.isGuest ? GuestBanner() : SizedBox.shrink()),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //_buildSearchBar(),
                const SizedBox(height: 24),
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildServiceCategories(),
                const SizedBox(height: 24),
                Obx(() {
                  if (serviceController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: serviceController.services.length,
                    itemBuilder: (context, index) {
                      final service = serviceController.services[index];
                      return ServiceCard(
                        service: service,
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.serviceDetails,
                            arguments: service,
                          );
                        },
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildSearchBar() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.05),
  //           blurRadius: 10,
  //           offset: Offset(0, 2),
  //         ),
  //       ],
  //     ),
  //     child: TextField(
  //       decoration: InputDecoration(
  //         hintText: 'Search services...',
  //         hintStyle: TextStyle(color: Colors.grey[500]),
  //         prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
  //         border: OutlineInputBorder(
  //           borderRadius: BorderRadius.circular(12),
  //           borderSide: BorderSide.none,
  //         ),
  //         filled: true,
  //         fillColor: Colors.white,
  //         contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  //       ),
  //       onChanged: (query) {
  //         serviceController.searchServices(query);
  //       },
  //     ),
  //   );
  // }

  Widget _buildServiceCategories() {
    final categories = [
      {
        'title': 'Vehicle\nInspection',
        'type': ServiceType.VEHICLE_INSPECTION,
        'color': Colors.orange,
        'image': 'assets/images/vehicle_inspection.jpg',
      },
      {
        'title': 'Change Oil',
        'type': ServiceType.CHANGE_OIL,
        'color': Colors.blue,
        'image': 'assets/images/oil_change.jpg',
      },
      {
        'title': 'Change Tires',
        'type': ServiceType.CHANGE_TIRES,
        'color': Colors.grey,
        'image': 'assets/images/change_tires.jpg',
      },
      {
        'title': 'Remove & Install\nTires',
        'type': ServiceType.REMOVE_INSTALL_TIRES,
        'color': Colors.purple,
        'image': 'assets/images/remove.jpg',
      },
      {
        'title': 'Cleaning',
        'type': ServiceType.CLEANING,
        'color': Colors.green,
        'image': 'assets/images/car_cleaning.jpg',
      },
      {
        'title': 'Diagnostic Test',
        'type': ServiceType.DIAGNOSTIC_TEST,
        'color': Colors.red,
        'image': 'assets/images/diagnostic.jpg',
      },
      {
        'title': 'Pre-TÜV Check',
        'type': ServiceType.PRE_TUV_CHECK,
        'color': Colors.teal,
        'image': 'assets/images/pre_tuv.jpg',
      },
      {
        'title': 'Balance Tires',
        'type': ServiceType.BALANCE_TIRES,
        'color': Colors.indigo,
        'image': 'assets/images/tire_balance.jpg',
      },
      {
        'title': 'Wheel\nAlignment',
        'type': ServiceType.WHEEL_ALIGNMENT,
        'color': Colors.deepPurple,
        'image': 'assets/images/wheel_alignment.jpg',
      },
      {
        'title': 'Polish',
        'type': ServiceType.POLISH,
        'color': Colors.amber,
        'image': 'assets/images/car_polish.jpg',
      },
      {
        'title': 'Change Brake\nFluid',
        'type': ServiceType.CHANGE_BRAKE_FLUID,
        'color': Colors.brown,
        'image': 'assets/images/brake_fluid.jpg',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
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
            // فلترة الخدمات حسب النوع
            serviceController.filterByType((category['type'] as ServiceType).name);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // صورة الخلفية
                  Image.asset(
                    category['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // في حالة عدم وجود الصورة، استخدم لون متدرج
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              (category['color'] as Color).withOpacity(0.8),
                              (category['color'] as Color).withOpacity(0.6),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  // طبقة شفافة مظلمة خفيفة للنص
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                  // النص في المنتصف
                  Center(
                    child: Text(
                      category['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.7),
                            offset: Offset(0, 2),
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

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Login Required',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Please login or register to access this feature.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            child: const Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}