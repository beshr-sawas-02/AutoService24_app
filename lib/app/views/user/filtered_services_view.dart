import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/workshop_controller.dart'; // إضافة جديدة
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class FilteredServicesView extends StatefulWidget {
  @override
  _FilteredServicesViewState createState() => _FilteredServicesViewState();
}

class _FilteredServicesViewState extends State<FilteredServicesView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();
  final WorkshopController workshopController = Get.find<WorkshopController>(); // إضافة جديدة

  late ServiceType selectedServiceType;
  late String categoryTitle;
  late bool isOwner;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    selectedServiceType = arguments['serviceType'] as ServiceType;
    categoryTitle = arguments['title'] as String;
    isOwner = arguments['isOwner'] ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndFilterServices();
    });
  }

  Future<void> _loadAndFilterServices() async {
    if (isOwner) {
      await serviceController.loadOwnerServices();
    } else {
      await serviceController.loadServices();
    }
  }

  // الدالة المُعدّلة لبدء المحادثة - هنا الحل الأساسي
  Future<void> _startChatWithWorkshop(ServiceModel service) async {
    try {
      final currentUserId = authController.currentUser.value?.id ?? '';

      if (currentUserId.isEmpty) {
        Get.snackbar(
          'Error',
          'User not logged in',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
        return;
      }

      print('FilteredServicesView: Starting chat with workshop');
      print('Service ID: ${service.id}');
      print('Workshop ID from service: ${service.workshopId}');
      print('Current User ID: $currentUserId');

      // 1. جلب الورشة بواسطة workshop_id للحصول على user_id الحقيقي
      final workshop = await workshopController.getWorkshopById(service.workshopId);

      if (workshop == null) {
        Get.snackbar(
          'Error',
          'Workshop not found',
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
        return;
      }

      final workshopOwnerId = workshop.userId; // معرف صاحب الورشة الحقيقي
      final workshopName = workshop.name;

      print('Workshop found: ${workshop.name}');
      print('Workshop Owner ID (Real): $workshopOwnerId');

      // التحقق من أن المستخدم لا يحاول محادثة نفسه
      if (workshopOwnerId == currentUserId) {
        Get.snackbar(
          'Info',
          'You cannot chat with yourself',
          backgroundColor: AppColors.info.withOpacity(0.1),
          colorText: AppColors.info,
        );
        return;
      }

      // التنقل إلى صفحة المحادثة مع البيانات الصحيحة
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'receiverId': workshopOwnerId, // استخدام معرف صاحب الورشة الحقيقي
          'receiverName': workshopName,
          'currentUserId': currentUserId,
          'serviceId': service.id,
          'serviceTitle': service.title,
        },
      );

    } catch (e) {
      print('Error starting chat: $e');
      Get.snackbar(
        'Error',
        'Failed to start chat. Please try again.',
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
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
          categoryTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: AppColors.textSecondary),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (serviceController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final sourceServices = isOwner
            ? serviceController.ownerServices
            : serviceController.services;

        final filteredServices = sourceServices
            .where((service) => service.serviceType == selectedServiceType)
            .toList();

        print('FilteredServicesView: Total ${isOwner ? "owner" : "all"} services: ${sourceServices.length}');
        print('FilteredServicesView: Filtered services: ${filteredServices.length}');
        print('FilteredServicesView: Looking for type: ${selectedServiceType.name}');

        if (filteredServices.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadAndFilterServices();
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: filteredServices.length,
            itemBuilder: (context, index) {
              final service = filteredServices[index];
              return _buildServicePostCard(service);
            },
          ),
        );
      }),
    );
  }

  Widget _buildServicePostCard(ServiceModel service) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(service),
          _buildServiceImage(service),
          _buildServiceContent(service),
          _buildActionButtons(service),
        ],
      ),
    );
  }

  Widget _buildPostHeader(ServiceModel service) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryWithOpacity(0.2),
            child: Text(
              service.workshopName.isNotEmpty
                  ? service.workshopName[0].toUpperCase()
                  : 'W',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.workshopData?['name'] ?? 'Unknown Workshop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (service.workshopData?['working_hours'] != null)
                  Text(
                    service.workshopData!['working_hours'],
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.serviceTypeName,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceImage(ServiceModel service) {
    return Container(
      height: 250,
      width: double.infinity,
      child: service.images.isNotEmpty
          ? ClipRRect(
        child: Image.network(
          service.images.first,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
        ),
      )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.grey200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle,
              size: 64,
              color: AppColors.grey400,
            ),
            SizedBox(height: 8),
            Text(
              'Service Image',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceContent(ServiceModel service) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),

          Text(
            service.description,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          Row(
            children: [
              Text(
                service.formattedPrice,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              Spacer(),

              if (service.workshopData?['location_x'] != null && service.workshopData?['location_y'] != null)
                GestureDetector(
                  onTap: () {},
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppColors.textSecondary,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ServiceModel service) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isOwner)
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final isSaved = serviceController.savedServices
                        .any((saved) => saved.serviceId == service.id);

                    return OutlinedButton.icon(
                      onPressed: () async {
                        if (authController.isGuest) {
                          _showGuestDialog();
                          return;
                        }

                        if (isSaved) {
                          final savedService = serviceController.savedServices
                              .firstWhere((saved) => saved.serviceId == service.id);
                          await serviceController.unsaveService(savedService.id);
                        } else {
                          await serviceController.saveService(
                            service.id,
                            authController.currentUser.value?.id ?? '',
                          );
                        }
                      },
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        size: 18,
                        color: isSaved ? AppColors.primary : AppColors.textSecondary,
                      ),
                      label: Text(
                        isSaved ? 'Saved' : 'Save',
                        style: TextStyle(
                          color: isSaved ? AppColors.primary : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isSaved ? AppColors.primary : AppColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                    );
                  }),
                ),
                SizedBox(width: 12),

                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (authController.isGuest) {
                        _showGuestDialog();
                        return;
                      }
                      _startChatWithWorkshop(service);
                    },
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: AppColors.info,
                    ),
                    label: Text(
                      'Chat',
                      style: TextStyle(
                        color: AppColors.info,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.info,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),

          if (!isOwner) SizedBox(height: 12),

          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (authController.isGuest && !isOwner) {
                  _showGuestDialog();
                  return;
                }

                Get.toNamed(
                  AppRoutes.serviceDetails,
                  arguments: service,
                );
              },
              child: Text('View Details'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.grey400,
          ),
          SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            isOwner
                ? 'You haven\'t created any services for $categoryTitle'
                : 'No services available for $categoryTitle',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _loadAndFilterServices();
            },
            child: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
          ),
          if (isOwner) ...[
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addService),
              icon: Icon(Icons.add),
              label: Text('Add Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    // يمكنك إضافة فلاتر إضافية هنا
  }

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Login Required',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Please login or register to access this feature.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.login);
            },
            child: const Text('Login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
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