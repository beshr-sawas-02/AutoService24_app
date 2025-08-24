import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';

class ServiceDetailsView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  @override
  Widget build(BuildContext context) {
    final ServiceModel service = Get.arguments as ServiceModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.orange,
            flexibleSpace: FlexibleSpaceBar(
              background: service.images.isNotEmpty
                  ? PageView.builder(
                itemCount: service.images.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    service.images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: Icon(
                          Icons.build,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  );
                },
              )
                  : Container(
                color: Colors.grey[300],
                child: Icon(
                  Icons.build,
                  size: 80,
                  color: Colors.grey[600],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.bookmark_border), // TODO: Change based on saved state
                onPressed: () {
                  if (authController.isGuest) {
                    _showGuestDialog();
                  } else {
                    _toggleSaveService(service);
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
                  // Service Header
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.serviceTypeName,
                                style: TextStyle(
                                  color: Colors.orange.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        service.formattedPrice,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    service.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 24),

                  // Workshop Info
                  _buildInfoCard(
                    'Workshop Information',
                    [
                      _buildInfoRow(Icons.business, 'Workshop ID', service.workshopId),
                      _buildInfoRow(Icons.access_time, 'Service Duration', '1-2 hours'),
                      _buildInfoRow(Icons.check_circle, 'Warranty', '30 days'),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Rating and Reviews
                  _buildInfoCard(
                    'Reviews',
                    [
                      Row(
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Icon(
                                Icons.star,
                                color: index < 4 ? Colors.amber : Colors.grey[300],
                                size: 20,
                              );
                            }),
                          ),
                          SizedBox(width: 8),
                          Text('4.5 (32 reviews)', style: TextStyle(fontSize: 16)),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (authController.isGuest) {
                              _showGuestDialog();
                            } else {
                              _contactWorkshop(service);
                            }
                          },
                          child: Text('Contact Workshop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Get.toNamed(
                              AppRoutes.workshopDetails,
                              arguments: service.workshopId,
                            );
                          },
                          child: Text('View Workshop'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange,
                            side: BorderSide(color: Colors.orange),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSaveService(ServiceModel service) async {
    final userId = authController.currentUser.value?.id;
    if (userId != null) {
      await serviceController.saveService(service.id, userId);
    }
  }

  void _contactWorkshop(ServiceModel service) {
    // Navigate to chat or contact workshop
    Get.snackbar(
      'Contact Workshop',
      'This feature will open a chat with the workshop owner',
    );
  }

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Login Required'),
        content: Text('Please login or register to access this feature.'),
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}