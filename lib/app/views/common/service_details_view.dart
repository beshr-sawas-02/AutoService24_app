import 'package:autoservice24/app/config/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';

class ServiceDetailsView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final ServiceController serviceController = Get.find<ServiceController>();
  final PageController pageController = PageController();

  ServiceDetailsView({super.key});

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
                    itemBuilder: (context, index) {
                      return SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: _buildImageWidget(service.images[index]),
                      );
                    },
                  ),
                  if (service.images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: _buildImageIndicator(service.images.length),
                    ),
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
                        child: Obx(() {
                          final currentPage = pageController.hasClients
                              ? (pageController.page?.round() ?? 0) + 1
                              : 1;
                          return Text(
                            'image_counter'.tr
                                .replaceAll('{current}', currentPage.toString())
                                .replaceAll('{total}', service.images.length.toString()),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              )
                  : _buildPlaceholderImage(),
            ),
            actions: [
              Obx(() {
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
                  tooltip:
                  isBookmarked ? 'remove_from_saved'.tr : 'save_service'.tr,
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
                          Icons.business, 'workshop_id'.tr, service.workshopId),
                      _buildInfoRow(Icons.access_time, 'service_duration'.tr,
                          '1_2_hours'.tr),
                      _buildInfoRow(
                          Icons.check_circle, 'warranty'.tr, '30_days'.tr),
                    ],
                  ),

                  if (service.images.length > 1) ...[
                    const SizedBox(height: 24),
                    _buildImageGallery(service.images),
                  ],

                  const SizedBox(height: 100), // مساحة للزر
                ],
              ),
            ),
          ),
        ],
      ),

      // زر الاتصال بأسفل الشاشة
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              // لسه ما في وظيفة، فقط منظر
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.phone, size: 22),
            label: Text(
              'Contact Workshop Owner',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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

  Widget _buildImageIndicator(int imageCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        imageCount,
            (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.7),
          ),
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
                  pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );

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
                      color: AppColors.border,
                      width: 2,
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
