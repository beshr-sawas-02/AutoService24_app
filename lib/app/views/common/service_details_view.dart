import 'package:autoservice24/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';

class ServiceDetailsView extends StatefulWidget {
  const ServiceDetailsView({super.key});

  @override
  _ServiceDetailsViewState createState() => _ServiceDetailsViewState();
}

class _ServiceDetailsViewState extends State<ServiceDetailsView> {
  final AuthController authController = Get.find<AuthController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final PageController pageController = PageController();

  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final ServiceModel service = Get.arguments as ServiceModel;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: service.images.isNotEmpty
                  ? Stack(
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: service.images.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildImageWidget(service.images[index]),
                      );
                    },
                  ),
                  // Image counter overlay
                  if (service.images.length > 1)
                    Positioned(
                      top: 50,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentImageIndex + 1}/${service.images.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  // Page indicators
                  if (service.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          service.images.length,
                              (index) => Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 3),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Navigation arrows
                  if (service.images.length > 1) ...[
                    if (currentImageIndex > 0)
                      Positioned(
                        left: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              pageController.previousPage(
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (currentImageIndex < service.images.length - 1)
                      Positioned(
                        right: 16,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: GestureDetector(
                            onTap: () {
                              pageController.nextPage(
                                duration:
                                const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ],
              )
                  : _buildPlaceholderImage(),
            ),
            actions: [
              Obx(() {
                // Guest
                if (authController.isGuest) {
                  return IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bookmark_border,
                          color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      _showGuestDialog();
                    },
                    tooltip: 'login_to_save'.tr,
                  );
                }


                if (authController.currentUser.value?.isOwner ?? false) {
                  return const SizedBox.shrink();
                }


                final isBookmarked =
                serviceController.isServiceSaved(service.id);

                return IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isBookmarked
                          ? AppColors.primary.withValues(alpha: 0.9)
                          : Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () async {
                    final userId = authController.currentUser.value?.id;
                    if (userId != null) {
                      await serviceController.toggleSaveService(
                          service.id, userId);
                    }
                  },
                  tooltip: isBookmarked
                      ? 'remove_from_saved'.tr
                      : 'save_service'.tr,
                );
              }),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
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
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                service.serviceTypeName,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        service.formattedPrice,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'description'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Workshop Info
                  _buildInfoCard(
                    'workshop_information'.tr,
                    [
                      _buildInfoRow(
                        Icons.business,
                        'workshop_name'.tr,
                        service.workshopName,
                      ),
                      _buildInfoRow(
                        Icons.description,
                        'description'.tr,
                        service.workshopDescription,
                      ),
                      _buildInfoRow(
                        Icons.access_time,
                        'working_hours'.tr,
                        service.workshopWorkingHours,
                      ),
                    ],
                  ),

                  if (service.images.length > 1) ...[
                    const SizedBox(height: 24),
                    _buildImageGallery(service.images),
                  ],

                  const SizedBox(height: 120), // Space for the buttons
                ],
              ),
            ),
          ),
        ],
      ),

      // Action buttons at the bottom
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Obx(() {
            final currentUser = authController.currentUser.value;
            final bool isCurrentUserOwner = currentUser?.isOwner ?? false;
            final String currentUserId = currentUser?.id ?? '';

            final bool isServiceOwner = service.userId == currentUserId ||
                service.workshopData?['user_id'] == currentUserId;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chat Button - only for regular users
                if (!isCurrentUserOwner && !isServiceOwner)
                  SizedBox(
                    width: double.infinity,
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
                        size: 20,
                        color: AppColors.info,
                      ),
                      label: Text(
                        'chat'.tr,
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: AppColors.info,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),

                // Spacing between buttons
                if (!isCurrentUserOwner && !isServiceOwner)
                  const SizedBox(height: 12),

                // Contact Button - for all users
                if (!isCurrentUserOwner && !isServiceOwner)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: serviceController.isLoadingPhone.value
                          ? null
                          : () => _contactWorkshopOwner(service.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: serviceController.isLoadingPhone.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white),
                        ),
                      )
                          : const Icon(Icons.phone, size: 20),
                      label: Text(
                        serviceController.isLoadingPhone.value
                            ? 'getting_phone_number'.tr
                            : 'contact_workshop_owner'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                // Contact button for owners or service owners
                if (isCurrentUserOwner || isServiceOwner)
                  ElevatedButton.icon(
                    onPressed: serviceController.isLoadingPhone.value
                        ? null
                        : () => _contactWorkshopOwner(service.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: serviceController.isLoadingPhone.value
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.phone, size: 22),
                    label: Text(
                      serviceController.isLoadingPhone.value
                          ? 'getting_phone_number'.tr
                          : 'contact_workshop_owner'.tr,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Start chat with workshop function
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

  // Contact workshop owner function
  Future<void> _contactWorkshopOwner(String serviceId) async {
    try {
      // Check if user is logged in first
      if (authController.isGuest) {
        _showGuestDialog();
        return;
      }

      // Get phone number from ServiceController
      final phoneNumber =
      await serviceController.getWorkshopOwnerPhone(serviceId);

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        // Clean phone number from unwanted characters
        final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

        // Create call link
        final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

        // Try to open phone app
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          // If can't open phone app
          _showErrorDialog('cannot_open_phone_app'.tr);
        }
      } else {
        // If no phone number available
        _showErrorDialog('phone_number_not_available'.tr);
      }
    } catch (e) {
      // If error occurred
      _showErrorDialog('error_getting_phone_number'.tr);
    }
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'error'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('ok'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    imagePath = imagePath.trim();

    if (imagePath.isEmpty) {
      return _buildErrorContainer('empty_image_path'.tr);
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Image.network(
          imagePath,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorContainer('network_error'.tr);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: AppColors.grey200,
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 3,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          },
        ),
      );
    } else if (imagePath.startsWith('/') || imagePath.contains('/data/')) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Image.file(
          File(imagePath),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorContainer('file_not_found'.tr);
          },
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return _buildErrorContainer('invalid_image_path'.tr);
          },
        ),
      );
    }
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
              size: 80,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 12),
            Text(
              'service_image'.tr,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<String> images) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'more_images'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // Navigate to specific image in main carousel
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );

                  // Scroll to top to show the main image
                  Scrollable.ensureVisible(
                    context,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: currentImageIndex == index
                          ? AppColors.primary
                          : AppColors.border,
                      width: currentImageIndex == index ? 3 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _buildImageWidget(images[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContainer(String message) {
    return Container(
      color: AppColors.grey200,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              size: 60,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'login_required'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
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
              foregroundColor: Colors.white,
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