import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../routes/app_routes.dart';
import '../../data/models/service_model.dart';

class OwnerHomeView extends StatefulWidget {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      workshopController.loadOwnerWorkshops();
      serviceController.loadOwnerServices();
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
          'CarServiceHub - Owner',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.message, color: Colors.black54),
            onPressed: () => Get.toNamed(AppRoutes.chatList),
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black54),
            onPressed: () => _showLogoutDialog(),
          ),
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
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_business),
            label: 'Add Workshop',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addService),
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
        tooltip: 'Add Service',
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
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeCard(),
                const SizedBox(height: 24),
                const Text(
                  'Service Categories',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                _buildServiceCategories(),

                const SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------- WELCOME CARD ----------------------
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.business_center, color: Colors.white, size: 36),
          SizedBox(width: 12),
          Expanded(
            child: Obx(() => Text(
              'Hello ${authController.displayName}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
        ],
      ),
    );
  }



  Widget _buildFilterChip(String label, ServiceType? type) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Obx(() => FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: serviceController.selectedType.value == type?.name
                ? Colors.white
                : Colors.grey[700],
          ),
        ),
        onSelected: (selected) {
          serviceController.filterByType(type?.name);
        },
        selected: serviceController.selectedType.value == type?.name,
        selectedColor: Colors.orange,
        backgroundColor: Colors.white,
      )),
    );
  }

  // ---------------------- SERVICE CATEGORIES ----------------------
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
                              (category['color'] as Color).withOpacity(0.8),
                              (category['color'] as Color).withOpacity(0.6),
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
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
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

  // ---------------------- DIALOGS ----------------------
  void _showLogoutDialog() {
    Get.dialog(AlertDialog(
      title: Text('Logout'),
      content: Text('Are you sure you want to logout?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            Get.back();
            authController.logout();
          },
          child: Text('Logout'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        ),
      ],
    ));
  }
}
