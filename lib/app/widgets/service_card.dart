import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/models/service_model.dart';
import '../controllers/service_controller.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_routes.dart';
import '../config/app_colors.dart';

class ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;
  final bool isOwner;
  final bool showSaveButton;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.isOwner = false,
    this.showSaveButton = true,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryWithOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            service.serviceTypeName,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showSaveButton && !isOwner) _buildSaveButton(),
                  if (isOwner)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) {
                          onEdit!();
                        } else if (value == 'delete' && onDelete != null) {
                          onDelete!();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16, color: AppColors.info),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete,
                                  size: 16, color: AppColors.error),
                              SizedBox(width: 8),
                              Text('Delete',
                                  style: TextStyle(color: AppColors.error)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (service.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: service.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: AppColors.grey200,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            service.images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.grey200,
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: AppColors.grey400,
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.formattedPrice,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '4.5', // Placeholder rating
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return GetBuilder<ServiceController>(
      builder: (serviceController) {
        final authController = Get.find<AuthController>();

        if (authController.isGuest) {
          return IconButton(
            onPressed: () {
              _showGuestDialog();
            },
            icon: const Icon(
              Icons.bookmark_border,
              color: AppColors.grey400,
              size: 20,
            ),
            tooltip: 'Login to save',
          );
        }

        return Obx(() {
          final isBookmarked = serviceController.isServiceSaved(service.id);

          return IconButton(
            onPressed: () async {
              final userId = authController.currentUser.value?.id;
              if (userId != null) {
                await serviceController.toggleSaveService(service.id, userId);
              }
            },
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            tooltip: isBookmarked ? 'Remove from saved' : 'Save service',
          );
        });
      },
    );
  }

  void _showGuestDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryWithOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bookmark, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            const Text('Save Service',
                style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
          'Create an account to save your favorite services and access them anytime.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.login);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                ),
                child: const Text('Sign In'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.register);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Register'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
