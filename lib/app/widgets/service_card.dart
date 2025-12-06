import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../data/models/service_model.dart';
import '../controllers/service_controller.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../config/app_colors.dart';
import '../widgets/custom_text_field.dart';
import '../utils/image_service.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
  });

  Widget _buildImageWidget(String imagePath) {
    imagePath = imagePath.trim();

    if (imagePath.isEmpty) return _buildErrorContainer();

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorContainer(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppColors.grey100,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                  strokeWidth: 2,
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              ),
            ),
          );
        },
      );
    } else if (imagePath.startsWith('/') || imagePath.contains('/data/')) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorContainer(),
      );
    } else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorContainer(),
      );
    }
  }

  Widget _buildErrorContainer() {
    return Container(
      color: AppColors.grey100,
      child: const Icon(
        Icons.image_not_supported,
        color: AppColors.grey400,
        size: 32,
      ),
    );
  }

  bool _isServiceOwner() {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser.value?.id;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return service.userId == currentUserId ||
        service.workshopData?['user_id'] == currentUserId;
  }

  void _showEditServiceBottomSheet(BuildContext context) {
    final titleCtrl = TextEditingController(text: service.title);
    final descCtrl = TextEditingController(text: service.description);
    final priceCtrl = TextEditingController(text: service.price.toString());
    List<File> newImages = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) => Column(
              children: [
                // ===== Header =====
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    border: Border(
                      bottom: BorderSide(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'edit_service'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              service.title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Get.back();
                        },
                        child: const Icon(Icons.close,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // ===== Body =====
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextField(
                            controller: titleCtrl,
                            labelText: 'service_title'.tr,
                            prefixIcon: Icons.build),
                        const SizedBox(height: 16),
                        CustomTextField(
                            controller: descCtrl,
                            labelText: 'description'.tr,
                            prefixIcon: Icons.description,
                            maxLines: 3),
                        const SizedBox(height: 16),
                        CustomTextField(
                            controller: priceCtrl,
                            labelText: 'price_usd'.tr,
                            prefixIcon: Icons.euro,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true)),
                        const SizedBox(height: 20),

                        if (service.images.isNotEmpty) ...[
                          Text(
                            'current_images'.tr,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: service.images.length,
                              itemBuilder: (context, index) => Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                    Border.all(color: AppColors.grey300)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(service.images[index],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(
                                              color: AppColors.grey200,
                                              child: const Icon(
                                                  Icons.broken_image,
                                                  color: AppColors.grey400))),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        Text(
                          'add_new_images'.tr,
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () async {
                            final images = await ImageService
                                .pickMultipleImages(maxImages: 5);
                            setState(() {
                              newImages.addAll(images);
                              if (newImages.length > 5) {
                                newImages = newImages.take(5).toList();
                              }
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 110,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: AppColors.primary, width: 2),
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.primary.withValues(alpha: 0.05),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_photo_alternate,
                                    size: 44, color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text('add_images'.tr,
                                    style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('max_5_images'.tr,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 11)),
                              ],
                            ),
                          ),
                        ),

                        if (newImages.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('new_images'.tr,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary)),
                              Text('${newImages.length}/5',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 90,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: newImages.length,
                              itemBuilder: (context, index) => Container(
                                width: 90,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppColors.primary, width: 2),
                                ),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(8),
                                      child: Image.file(newImages[index],
                                          width: 90,
                                          height: 90,
                                          fit: BoxFit.cover),
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 2,
                                      child: GestureDetector(
                                        onTap: () => setState(
                                                () => newImages.removeAt(index)),
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle),
                                          child: const Icon(Icons.close,
                                              color: Colors.white, size: 14),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                // ===== Footer Buttons =====
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border:
                    Border(top: BorderSide(color: AppColors.grey200)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          Get.back();
                        },
                        child: Text('cancel'.tr,
                            style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 12),
                      GetBuilder<ServiceController>(
                        builder: (serviceController) => Obx(
                              () => ElevatedButton.icon(
                            onPressed: serviceController.isLoading.value
                                ? null
                                : () {
                              FocusScope.of(context).unfocus();
                              _updateService(titleCtrl, descCtrl,
                                  priceCtrl, newImages);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            icon: serviceController.isLoading.value
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Colors.white)),
                            )
                                : const Icon(Icons.check, size: 18),
                            label: Text(
                              serviceController.isLoading.value
                                  ? 'saving'.tr
                                  : 'save_changes'.tr,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).whenComplete(() {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (titleCtrl.hasListeners) titleCtrl.dispose();
        if (descCtrl.hasListeners) descCtrl.dispose();
        if (priceCtrl.hasListeners) priceCtrl.dispose();
      });
    });
  }

  Future<void> _updateService(
      TextEditingController titleCtrl,
      TextEditingController descCtrl,
      TextEditingController priceCtrl,
      List<File> newImages,
      ) async {
    final serviceController = Get.find<ServiceController>();
    try {
      if (titleCtrl.text.trim().isEmpty) {
        Get.snackbar(
          'error'.tr,
          'please_enter_service_title'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }

      final updateData = {
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'price': double.parse(
            priceCtrl.text.isEmpty ? '0' : priceCtrl.text),
      };

      bool success = false;
      if (newImages.isNotEmpty) {
        success = await serviceController.updateService(service.id, updateData);
        if (success) {
          success = await serviceController.uploadServiceImages(
              service.id, newImages);
        }
      } else {
        success = await serviceController.updateService(service.id, updateData);
      }

      if (success) {
        Get.back();

        // ✅ حدّث البيانات فوراً
        await serviceController.loadServices();

        Get.snackbar(
          'success'.tr,
          'service_updated_successfully'.tr,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: AppColors.success),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'error'.tr,
          'failed_update_service'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.error_outline, color: AppColors.error),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_update_service'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error_outline, color: AppColors.error),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showDeleteDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 12),
            Text('delete_service'.tr,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('confirm_delete_service'.tr,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 16)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(service.formattedPrice,
                      style: const TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('action_cannot_be_undone'.tr,
                style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr,
                style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performDelete();
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: Text('delete'.tr),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _performDelete() async {
    final serviceController = Get.find<ServiceController>();
    try {
      final success = await serviceController.deleteService(service.id);
      if (success) {
        Get.snackbar(
          'success'.tr,
          'service_deleted_successfully'.tr,
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: AppColors.success),
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'failed_delete_service'.tr,
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error_outline, color: AppColors.error),
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 10,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildDescription(),
                if (service.images.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildImagesSection(),
                ],
                const SizedBox(height: 16),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildServiceTypeChip(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _buildActionButton(context),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser.value;

    if (_isServiceOwner()) {
      return PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert,
            color: AppColors.textSecondary, size: 20),
        offset: const Offset(0, 40),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 8,
        onSelected: (value) {
          if (value == 'edit') {
            _showEditServiceBottomSheet(context);
          } else if (value == 'delete') {
            _showDeleteDialog(context);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                const Icon(Icons.edit_outlined,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 12),
                Text('edit_service'.tr,
                    style: const TextStyle(
                        color: AppColors.primary, fontSize: 14)),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                const Icon(Icons.delete_outline,
                    size: 18, color: AppColors.error),
                const SizedBox(width: 12),
                Text('delete_service'.tr,
                    style:
                    const TextStyle(color: AppColors.error, fontSize: 14)),
              ],
            ),
          ),
        ],
      );
    } else if (currentUser?.isUser ?? false) {
      return _buildSaveButton();
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildServiceTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryWithOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryWithOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        service.serviceTypeName,
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Text(
      service.description,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 15,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildImagesSection() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: service.images.length > 4 ? 4 : service.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.grey100,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowLight,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImageWidget(service.images[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryWithOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            service.formattedPrice,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        if (service.images.length > 4)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'more_images'.tr
                  .replaceAll('{count}', '${service.images.length - 4}'),
              style: const TextStyle(
                color: AppColors.textHint,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GetBuilder<ServiceController>(
      builder: (serviceController) {
        final authController = Get.find<AuthController>();

        if (authController.isGuest) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: _showGuestDialog,
              icon: const Icon(
                Icons.bookmark_border,
                color: AppColors.grey400,
                size: 22,
              ),
              tooltip: 'login_to_save'.tr,
            ),
          );
        }

        return Obx(() {
          final isBookmarked = serviceController.isServiceSaved(service.id);

          return Container(
            decoration: BoxDecoration(
              color: isBookmarked
                  ? AppColors.primaryWithOpacity(0.1)
                  : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: () async {
                final userId = authController.currentUser.value?.id;
                if (userId != null) {
                  await serviceController.toggleSaveService(service.id, userId);
                }
              },
              icon: Icon(
                isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                color: isBookmarked
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 22,
              ),
              tooltip: isBookmarked
                  ? 'remove_from_saved'.tr
                  : 'save_service'.tr,
            ),
          );
        });
      },
    );
  }

  void _showGuestDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bookmark,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'save_service_title'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'save_service_description'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: Text(
                        'create_account'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(AppRoutes.login);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'sign_in'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}