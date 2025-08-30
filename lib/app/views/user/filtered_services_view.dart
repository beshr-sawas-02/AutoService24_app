import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';

class FilteredServicesView extends StatefulWidget {
  @override
  _FilteredServicesViewState createState() => _FilteredServicesViewState();
}

class _FilteredServicesViewState extends State<FilteredServicesView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();
  late ServiceType selectedServiceType;
  late String categoryTitle;
  late bool isOwner;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    selectedServiceType = arguments['serviceType'] as ServiceType;
    categoryTitle = arguments['title'] as String;
    isOwner = arguments['isOwner'] ?? false; // افتراضياً false إذا لم يتم تمريرها

    // تحميل جميع الخدمات أولاً ثم الفلترة محلياً
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndFilterServices();
    });
  }

  Future<void> _loadAndFilterServices() async {
    // تحميل الخدمات المناسبة حسب نوع المستخدم
    if (isOwner) {
      // للـ Owner، نحمل خدماته الخاصة
      await serviceController.loadOwnerServices();
    } else {
      // للـ User العادي، نحمل جميع الخدمات
      await serviceController.loadServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          categoryTitle,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: Colors.black54),
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
              color: Colors.orange,
            ),
          );
        }

        // فلترة الخدمات محلياً حسب النوع المختار من المصدر المناسب
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with workshop info
          _buildPostHeader(service),

          // Service image
          _buildServiceImage(service),

          // Service content
          _buildServiceContent(service),

          // Action buttons
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
          // Workshop avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.orange.withOpacity(0.2),
            child: Text(
              service.workshopName.isNotEmpty
                  ? service.workshopName[0].toUpperCase()
                  : 'W',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          SizedBox(width: 12),

          // Workshop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.workshopData?['name'] ?? 'Unknown Workshop',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (service.workshopData?['working_hours'] != null)
                  Text(
                    service.workshopData!['working_hours'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),

          // Service type badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.serviceTypeName,
              style: TextStyle(
                fontSize: 10,
                color: Colors.orange[700],
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
                color: Colors.orange,
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
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.build_circle,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 8),
            Text(
              'Service Image',
              style: TextStyle(
                color: Colors.grey[600],
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
          // Service title
          Text(
            service.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),

          // Service description
          Text(
            service.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 12),

          // Price
          Row(
            children: [
              // Icon(
              //   Icons.attach_money,
              //   color: Colors.green,
              //   size: 20,
              // ),
              Text(
                service.formattedPrice,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              Spacer(),

              // Location if available
              if (service.workshopData?['location_x'] != null && service.workshopData?['location_y'] != null)
                GestureDetector(
                  onTap: () {
                    // يمكنك إضافة فتح الخريطة هنا
                  },
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
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
          // صف أول - Save + Chat فقط للمستخدم العادي
          if (!isOwner)
            Row(
              children: [
                // Save button
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
                        color: isSaved ? Colors.orange : Colors.grey[600],
                      ),
                      label: Text(
                        isSaved ? 'Saved' : 'Save',
                        style: TextStyle(
                          color: isSaved ? Colors.orange : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isSaved ? Colors.orange : Colors.grey[300]!,
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

                // Chat button
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
                      color: Colors.blue[600],
                    ),
                    label: Text(
                      'Chat',
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Colors.blue[300]!,
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

          // مسافة بين الصفوف
          if (!isOwner) SizedBox(height: 12),

          // الصف الثاني - View Details للجميع
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
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
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


  void _startChatWithWorkshop(ServiceModel service) {
    // الحصول على معلومات صاحب الورشة
    final workshopOwnerId = service.workshopData?['owner_id'] ?? service.workshopId;
    final workshopName = service.workshopData?['name'] ?? 'Unknown Workshop';

    if (workshopOwnerId == null || workshopOwnerId.isEmpty) {
      Get.snackbar(
        'Error',
        'Cannot start chat - Workshop information not available',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red[800],
      );
      return;
    }

    // الانتقال إلى صفحة المحادثة مع تمرير معلومات صاحب الورشة
    Get.toNamed(
      AppRoutes.chat,
      arguments: {
        'receiverId': workshopOwnerId,
        'receiverName': workshopName,
        'serviceId': service.id,
        'serviceTitle': service.title,
      },
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
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No services found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            isOwner
                ? 'You haven\'t created any services for $categoryTitle'
                : 'No services available for $categoryTitle',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          if (isOwner) ...[
            SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addService),
              icon: Icon(Icons.add),
              label: Text('Add Service'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
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