import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class FilteredServicesView extends StatefulWidget {
  const FilteredServicesView({super.key});

  @override
  _FilteredServicesViewState createState() => _FilteredServicesViewState();
}

class _FilteredServicesViewState extends State<FilteredServicesView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();
  final WorkshopController workshopController = Get.find<WorkshopController>();

  late ServiceType selectedServiceType;
  late String categoryTitle;
  late bool isOwner;
  bool isLocationBased = false;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments as Map<String, dynamic>;
    selectedServiceType = arguments['serviceType'] as ServiceType;
    categoryTitle = arguments['title'] as String;
    isOwner = arguments['isOwner'] ?? false;
    isLocationBased = arguments['isLocationBased'] ?? false;

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

  bool _isServiceOwner(ServiceModel service) {
    final currentUserId = authController.currentUser.value?.id;
    if (currentUserId == null || currentUserId.isEmpty) return false;

    return service.userId == currentUserId ||
        service.workshopData?['user_id'] == currentUserId;
  }

  Future<void> _navigateToWorkshopOnMap(ServiceModel service) async {
    try {
      double? latitude;
      double? longitude;

      if (service.workshopData?['location'] != null &&
          service.workshopData!['location']['coordinates'] != null) {
        final coordinates = service.workshopData!['location']['coordinates'];
        if (coordinates is List && coordinates.length >= 2) {
          longitude = double.tryParse(coordinates[0].toString());
          latitude = double.tryParse(coordinates[1].toString());
        }
      }

      if (latitude == null || longitude == null) {
        final locationX = service.workshopData?['location_x'];
        final locationY = service.workshopData?['location_y'];

        if (locationX != null && locationY != null) {
          try {
            latitude = double.parse(locationY.toString());
            longitude = double.parse(locationX.toString());
          } catch (e) {}
        }
      }

      if (latitude == null || longitude == null) {
        Get.snackbar(
          'error'.tr,
          'workshop_location_not_available'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }

      if (latitude == 0.0 || longitude == 0.0) {
        Get.snackbar(
          'error'.tr,
          'workshop_location_not_set'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }

      Get.toNamed(
        AppRoutes.map,
        arguments: {
          'focusOnWorkshop': true,
          'workshopId': service.workshopId,
          'latitude': latitude,
          'longitude': longitude,
          'workshopName': service.workshopData?['name'] ?? service.workshopName,
          'zoom': 16.0,
        },
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_to_open_workshop_location'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }

  Widget _buildLocationButton(ServiceModel service) {
    bool hasLocation = false;
    double? latitude;
    double? longitude;

    if (service.workshopData?['location'] != null &&
        service.workshopData!['location']['coordinates'] != null) {
      final coordinates = service.workshopData!['location']['coordinates'];
      if (coordinates is List && coordinates.length >= 2) {
        longitude = double.tryParse(coordinates[0].toString());
        latitude = double.tryParse(coordinates[1].toString());

        if (longitude != null &&
            latitude != null &&
            longitude != 0.0 &&
            latitude != 0.0) {
          hasLocation = true;
        }
      }
    }

    if (!hasLocation) {
      final locationX = service.workshopData?['location_x'];
      final locationY = service.workshopData?['location_y'];

      if (locationX != null && locationY != null) {
        longitude = double.tryParse(locationX.toString());
        latitude = double.tryParse(locationY.toString());

        if (longitude != null &&
            latitude != null &&
            longitude != 0.0 &&
            latitude != 0.0) {
          hasLocation = true;
        }
      }
    }

    if (!hasLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.grey200,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off,
              color: AppColors.grey400,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              'no_location'.tr,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.grey400,
              ),
            ),
          ],
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: () {
        if (authController.isGuest) {
          _showGuestDialog();
          return;
        }
        _navigateToWorkshopOnMap(service);
      },
      icon: const Icon(
        Icons.location_on,
        color: AppColors.primary,
        size: 16,
      ),
      label: Text(
        'workshop_location'.tr,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(
          color: AppColors.primary,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 12,
        ),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    imagePath = imagePath.trim();

    if (imagePath.isEmpty) {
      return _buildErrorContainer('empty_image_path'.tr);
    }

    String finalImagePath = imagePath;

    if (imagePath.startsWith('/uploads/')) {
      finalImagePath = 'https://www.autoservicely.com$imagePath';
    } else if (imagePath.startsWith('uploads/')) {
      finalImagePath = 'https://www.autoservicely.com/$imagePath';
    } else if (!imagePath.startsWith('http://') &&
        !imagePath.startsWith('https://') &&
        !imagePath.startsWith('/data/') &&
        !imagePath.startsWith('assets/')) {
      if (imagePath.startsWith('/')) {
        finalImagePath = 'https://www.autoservicely.com$imagePath';
      } else {
        finalImagePath = 'https://www.autoservicely.com/$imagePath';
      }
    }

    if (finalImagePath.startsWith('http://') ||
        finalImagePath.startsWith('https://')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.grey200,
        child: Image.network(
          finalImagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.grey200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.broken_image,
                      size: 48,
                      color: AppColors.grey400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'image_not_available'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.grey200,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            );
          },
        ),
      );
    } else if (finalImagePath.startsWith('/data/')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.grey200,
        child: Image.file(
          File(finalImagePath),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorContainer('file_not_found'.tr);
          },
        ),
      );
    } else if (finalImagePath.startsWith('assets/')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.grey200,
        child: Image.asset(
          finalImagePath,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorContainer('asset_not_found'.tr);
          },
        ),
      );
    }

    return _buildErrorContainer('invalid_path'.tr);
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      color: AppColors.grey200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.build_circle,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 8),
            Text(
              'service_image'.tr,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            if (message != 'service_image'.tr)
              Text(
                message,
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChatWithWorkshop(ServiceModel service) async {
    try {
      final currentUserId = authController.currentUser.value?.id ?? '';

      if (currentUserId.isEmpty) {
        Get.snackbar(
          'error'.tr,
          'user_not_logged_in'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }

      final workshop =
      await workshopController.getWorkshopById(service.workshopId);

      if (workshop == null) {
        Get.snackbar(
          'error'.tr,
          'workshop_not_found'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }

      final workshopOwnerId = workshop.userId;
      final workshopName = workshop.name;

      if (workshopOwnerId == currentUserId) {
        Get.snackbar(
          'info'.tr,
          'cannot_chat_yourself'.tr,
          backgroundColor: AppColors.info.withValues(alpha: 0.1),
          colorText: AppColors.info,
        );
        return;
      }

      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'receiverId': workshopOwnerId,
          'receiverName': workshopName,
          'currentUserId': currentUserId,
          'serviceId': service.id,
          'serviceTitle': service.title,
        },
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_start_chat'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
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
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (serviceController.isLoading.value) {
          return const Center(
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

        if (filteredServices.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _loadAndFilterServices();
          },
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredServices.length + (isOwner ? 0 : 1), // +1 للـ banner
            itemBuilder: (context, index) {
              if (!isOwner && index == 0) {
                return _buildSearchBanner();
              }

              final service = filteredServices[!isOwner ? index - 1 : index];
              return _buildServicePostCard(service);
            },
          ),
        );
      }),
    );
  }

  Widget _buildSearchBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'find_nearby_workshops'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'search_workshops_by_location'.tr,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (authController.isGuest) {
                  _showGuestDialog();
                  return;
                }

                Get.toNamed(
                  AppRoutes.workshopMapSearch,
                  arguments: {
                    'serviceType': selectedServiceType,
                  },
                );
              },
              icon: const Icon(Icons.map, size: 20),
              label: Text('open_map_search'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildServicePostCard(ServiceModel service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 15,
            offset: const Offset(0, 5),
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
    final isServiceOwner = _isServiceOwner(service);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primaryWithOpacity(0.2),
            child: Text(
              service.workshopName.isNotEmpty
                  ? service.workshopName[0].toUpperCase()
                  : 'W',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.workshopData?['name'] ?? 'unknown_workshop'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (service.workshopData?['working_hours'] != null)
                  Text(
                    service.workshopData!['working_hours'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              service.serviceTypeName,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isServiceOwner) ...[
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: AppColors.textSecondary,
                size: 20,
              ),
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _showDeleteConfirmation(service);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'delete_service'.tr,
                        style: const TextStyle(
                          color: AppColors.error,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceImage(ServiceModel service) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: service.images.isNotEmpty
          ? ClipRRect(
              child: _buildImageWidget(service.images.first),
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
            const Icon(
              Icons.build_circle,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 8),
            Text(
              'service_image'.tr,
              style: const TextStyle(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            service.description,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                service.formattedPrice,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildLocationButton(service),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ServiceModel service) {
    final isServiceOwner = _isServiceOwner(service);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isServiceOwner)
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
                              .firstWhere(
                                  (saved) => saved.serviceId == service.id);
                          await serviceController
                              .unsaveService(savedService.id);
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
                        color: isSaved
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      label: Text(
                        isSaved ? 'saved'.tr : 'save'.tr,
                        style: TextStyle(
                          color: isSaved
                              ? AppColors.primary
                              : AppColors.textSecondary,
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      if (authController.isGuest) {
                        _showGuestDialog();
                        return;
                      }
                      _startChatWithWorkshop(service);
                    },
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: AppColors.info,
                    ),
                    label: Text(
                      'chat'.tr,
                      style: const TextStyle(
                        color: AppColors.info,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.info,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                    ),
                  ),
                ),
              ],
            ),
          if (!isServiceOwner) const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (authController.isGuest && !isServiceOwner) {
                  _showGuestDialog();
                  return;
                }

                Get.toNamed(
                  AppRoutes.serviceDetails,
                  arguments: service,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text('view_details'.tr),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ServiceModel service) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            Text(
              'delete_service'.tr,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'confirm_delete_service'.tr,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    service.formattedPrice,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'action_cannot_be_undone'.tr,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
              _performDelete(service);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _performDelete(ServiceModel service) async {
    try {
      final success = await serviceController.deleteService(service.id);
      if (success) {
        Get.snackbar(
          'deleted'.tr,
          'service_deleted_successfully'.tr,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: AppColors.success),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          snackPosition: SnackPosition.TOP,
        );

        await _loadAndFilterServices();
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_delete_service'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: AppColors.error),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'error_deleting_service'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error_outline, color: AppColors.error),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 80,
            color: AppColors.grey400,
          ),
          const SizedBox(height: 16),
          Text(
            'no_services_found'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOwner
                ? '${'havent_created_services'.tr} $categoryTitle'
                : '${'no_services_for_category'.tr} $categoryTitle',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _loadAndFilterServices();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: Text('refresh'.tr),
          ),
          if (isOwner) ...[
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addService),
              icon: const Icon(Icons.add),
              label: Text('add_service'.tr),
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

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'login_required'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'login_register_access'.tr,
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







////
