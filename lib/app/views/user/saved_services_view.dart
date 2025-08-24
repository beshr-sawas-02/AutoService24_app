import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/service_card.dart';
import '../../widgets/empty_state_widget.dart';
import '../../data/models/service_model.dart';

class SavedServicesView extends StatefulWidget {
  @override
  _SavedServicesViewState createState() => _SavedServicesViewState();
}

class _SavedServicesViewState extends State<SavedServicesView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    // تأجيل تحميل الخدمات بعد اكتمال build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      serviceController.loadSavedServices();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Services'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => serviceController.loadSavedServices(),
          ),
        ],
      ),
      body: Obx(() {
        if (serviceController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
            ),
          );
        }

        if (serviceController.savedServices.isEmpty) {
          return NoSavedServices(
            onBrowse: () => Get.back(),
          );
        }

        return RefreshIndicator(
          onRefresh: () => serviceController.loadSavedServices(),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: serviceController.savedServices.length,
            itemBuilder: (context, index) {
              final savedService = serviceController.savedServices[index];

              return FutureBuilder<ServiceModel?>(
                future: _getServiceFromSaved(savedService.serviceId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingCard();
                  }

                  if (snapshot.hasError || snapshot.data == null) {
                    return _buildErrorCard(savedService);
                  }

                  final service = snapshot.data!;
                  return SavedServiceCard(
                    service: service,
                    savedService: savedService,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.serviceDetails,
                        arguments: service,
                      );
                    },
                    onUnsave: () => _unsaveService(savedService),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  Future<ServiceModel?> _getServiceFromSaved(String serviceId) async {
    try {
      final existingService = serviceController.services
          .firstWhereOrNull((service) => service.id == serviceId);

      if (existingService != null) {
        return existingService;
      }

      // لو الخدمة مش موجودة محليًا يمكن لاحقًا تحميلها من API
      return null;
    } catch (e) {
      return null;
    }
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Container(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.orange,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(savedService) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(Icons.error, color: Colors.red),
        title: Text('Service not available'),
        subtitle: Text('This service may have been removed'),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () => _unsaveService(savedService),
        ),
      ),
    );
  }

  Future<void> _unsaveService(savedService) async {
    final success = await serviceController.unsaveService(savedService.id);
    if (success) {
      serviceController.savedServices.removeWhere((s) => s.id == savedService.id);
    }
  }
}

// Widget مخصص للخدمات المحفوظة
class SavedServiceCard extends StatelessWidget {
  final ServiceModel service;
  final savedService;
  final VoidCallback onTap;
  final VoidCallback onUnsave;

  const SavedServiceCard({
    Key? key,
    required this.service,
    required this.savedService,
    required this.onTap,
    required this.onUnsave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            service.serviceTypeName,
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onUnsave,
                    icon: Icon(
                      Icons.bookmark,
                      color: Colors.orange,
                    ),
                    tooltip: 'Remove from saved',
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                service.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.formattedPrice,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Saved ${_formatSavedDate()}',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSavedDate() {
    final now = DateTime.now();
    final savedDate = savedService.savedAt;
    final difference = now.difference(savedDate);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'recently';
    }
  }
}
