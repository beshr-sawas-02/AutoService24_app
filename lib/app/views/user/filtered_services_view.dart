import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../data/models/service_model.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';
import '../../utils/image_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';

class FilteredServicesView extends StatefulWidget {
  const FilteredServicesView({super.key});

  @override
  State<FilteredServicesView> createState() => _FilteredServicesViewState();
}

class _FilteredServicesViewState extends State<FilteredServicesView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();
  final WorkshopController workshopController = Get.find<WorkshopController>();

  late ServiceType selectedServiceType;
  late String categoryTitle;
  late bool isOwner;
  late ScrollController _scrollController;
  final Map<String, int> _currentImagePages = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    final arguments = Get.arguments as Map<String, dynamic>;
    selectedServiceType = arguments['serviceType'] as ServiceType;
    categoryTitle = arguments['title'] as String;
    isOwner = arguments['isOwner'] ?? false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndFilterServices();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (serviceController.isLoadingMore.value) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      if (isOwner) {
        if (serviceController.hasMoreOwnerServices.value &&
            !serviceController.isLoadingMore.value) {
          serviceController.loadMoreOwnerServices(
            serviceType: selectedServiceType.name,
          );
        }
      } else {
        if (serviceController.lastSearchQuery.value.isNotEmpty) {
          if (serviceController.hasMoreSearchResults.value &&
              !serviceController.isLoadingMore.value) {
            serviceController.loadMoreSearchResults();
          }
        } else {
          if (serviceController.hasMoreServices.value &&
              !serviceController.isLoadingMore.value) {
            serviceController.loadMoreServices(
              serviceType: selectedServiceType.name,
            );
          }
        }
      }
    }
  }

  Future<void> _loadAndFilterServices() async {
    if (isOwner) {
      await serviceController.loadOwnerServices(
        serviceType: selectedServiceType.name,
      );
    } else {
      await serviceController.loadServices(
        serviceType: selectedServiceType.name,
      );
    }
  }

  bool _isServiceOwner(ServiceModel service) {
    final currentUserId = authController.currentUser.value?.id;
    if (currentUserId == null || currentUserId.isEmpty) return false;
    return service.userId == currentUserId ||
        service.workshopData?['user_id'] == currentUserId;
  }

  // ============== Edit Service Dialog ==============
  void _showEditServiceDialog(ServiceModel service) {
    final TextEditingController _titleController =
        TextEditingController(text: service.title);
    final TextEditingController _descriptionController =
        TextEditingController(text: service.description);
    final TextEditingController _priceController =
        TextEditingController(text: service.price.toString());
    List<File> _newImages = [];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return WillPopScope(
              onWillPop: () async {
                FocusScope.of(context).unfocus();
                return true;
              },
              child: GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                },
                child: Dialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  backgroundColor: AppColors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ======= Header =======
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
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
                              child: const Icon(Icons.edit,
                                  color: AppColors.primary),
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

                      // ======= Content =======
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              CustomTextField(
                                controller: _titleController,
                                labelText: 'service_title'.tr,
                                prefixIcon: Icons.build,
                              ),
                              const SizedBox(height: 16),

                              // Description
                              CustomTextField(
                                controller: _descriptionController,
                                labelText: 'description'.tr,
                                prefixIcon: Icons.description,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),

                              // Price
                              CustomTextField(
                                controller: _priceController,
                                labelText: 'price_usd'.tr,
                                prefixIcon: Icons.euro,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                              ),
                              const SizedBox(height: 20),

                              // ======= Current Images =======
                              if (service.images.isNotEmpty) ...[
                                Text(
                                  'current_images'.tr,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: service.images.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 90,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: AppColors.grey300,
                                              width: 1),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: Image.network(
                                            service.images[index],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                color: AppColors.grey200,
                                                child: const Icon(
                                                  Icons.broken_image,
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
                                const SizedBox(height: 20),
                              ],

                              // ======= Add New Images =======
                              Text(
                                'add_new_images'.tr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),

                              GestureDetector(
                                onTap: () async {
                                  final images =
                                      await ImageService.pickMultipleImages(
                                          maxImages: 5);
                                  setDialogState(() {
                                    _newImages.addAll(images);
                                    if (_newImages.length > 5) {
                                      _newImages = _newImages.take(5).toList();
                                    }
                                  });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 110,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 2,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.primary
                                        .withValues(alpha: 0.05),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.add_photo_alternate,
                                          size: 44, color: AppColors.primary),
                                      const SizedBox(height: 8),
                                      Text(
                                        'add_images'.tr,
                                        style: const TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'max_5_images'.tr,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              if (_newImages.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'new_images'.tr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    Text(
                                      '${_newImages.length}/5',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  height: 90,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _newImages.length,
                                    itemBuilder: (context, index) {
                                      return Container(
                                        width: 90,
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                              color: AppColors.primary,
                                              width: 2),
                                        ),
                                        child: Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                _newImages[index],
                                                width: 90,
                                                height: 90,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            Positioned(
                                              top: 2,
                                              right: 2,
                                              child: GestureDetector(
                                                onTap: () {
                                                  setDialogState(() {
                                                    _newImages.removeAt(index);
                                                  });
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: AppColors.error,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                    size: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // ======= Footer Buttons =======
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.grey200,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                Get.back();
                              },
                              child: Text(
                                'cancel'.tr,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Obx(() => ElevatedButton.icon(
                                  onPressed: serviceController.isLoading.value
                                      ? null
                                      : () {
                                          FocusScope.of(context).unfocus();
                                          _performUpdate(
                                            service,
                                            _titleController,
                                            _descriptionController,
                                            _priceController,
                                            _newImages,
                                          );
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
                                                    Colors.white),
                                          ),
                                        )
                                      : const Icon(Icons.check, size: 18),
                                  label: Text(
                                    serviceController.isLoading.value
                                        ? 'saving'.tr
                                        : 'save_changes'.tr,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _performUpdate(
    ServiceModel service,
    TextEditingController titleController,
    TextEditingController descriptionController,
    TextEditingController priceController,
    List<File> newImages,
  ) async {
    try {
      if (titleController.text.trim().isEmpty) {
        Get.snackbar(
          'error'.tr,
          'please_enter_service_title'.tr,
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
        return;
      }

      final updateData = {
        'title': titleController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.parse(
            priceController.text.isEmpty ? '0' : priceController.text),
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
        await _loadAndFilterServices();
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

  void _showDeleteConfirmation(ServiceModel service) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                border:
                    Border.all(color: AppColors.error.withValues(alpha: 0.3)),
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
                  borderRadius: BorderRadius.circular(8)),
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
        await _loadAndFilterServices();
      } else {
        _showErrorSnackbar('failed_delete_service'.tr);
      }
    } catch (e) {
      _showErrorSnackbar('error_deleting_service'.tr);
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'error'.tr,
      message,
      backgroundColor: AppColors.error.withValues(alpha: 0.1),
      colorText: AppColors.error,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.error_outline, color: AppColors.error),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      snackPosition: SnackPosition.TOP,
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
          _buildServiceImageCarousel(service),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
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
                const SizedBox(height: 2),
                if (service.workshopData?['working_hours'] != null)
                  Text(
                    service.workshopData!['working_hours'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
              ],
            ),
          ),
          if (isServiceOwner)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert,
                  color: AppColors.textSecondary, size: 20),
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 8,
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditServiceDialog(service);
                } else if (value == 'delete') {
                  _showDeleteConfirmation(service);
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
                      Text(
                        'edit_service'.tr,
                        style: const TextStyle(
                            color: AppColors.primary, fontSize: 14),
                      ),
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
                      Text(
                        'delete_service'.tr,
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 14),
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

  Widget _buildServiceImageCarousel(ServiceModel service) {
    if (service.images.isEmpty) {
      return SizedBox(
        height: 250,
        width: double.infinity,
        child: _buildPlaceholderImage(),
      );
    }

    if (!_currentImagePages.containsKey(service.id)) {
      _currentImagePages[service.id] = 0;
    }

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: service.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentImagePages[service.id] = index;
              });
            },
            itemBuilder: (context, index) {
              return ClipRRect(
                child: _buildImageWidget(service.images[index]),
              );
            },
          ),
          if (service.images.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentImagePages[service.id]! + 1}/${service.images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          if (service.images.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  service.images.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImagePages[service.id] == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // أيقونة أفضل
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.car_repair,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            // نص أوضح
            Text(
              'Professional Service'.tr,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Image preview'.tr,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(String imagePath) {
    imagePath = imagePath.trim();
    if (imagePath.isEmpty) return _buildErrorContainer('empty_image_path'.tr);

    String finalImagePath = imagePath;
    if (imagePath.startsWith('/uploads/')) {
      finalImagePath = 'https://www.autoservicely.com$imagePath';
    } else if (imagePath.startsWith('uploads/')) {
      finalImagePath = 'https://www.autoservicely.com/$imagePath';
    } else if (!imagePath.startsWith('http://') &&
        !imagePath.startsWith('https://')) {
      finalImagePath = imagePath.startsWith('/')
          ? 'https://www.autoservicely.com$imagePath'
          : 'https://www.autoservicely.com/$imagePath';
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
          errorBuilder: (context, error, stackTrace) =>
              _buildErrorContainer('image_not_available'.tr),
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
            const Icon(Icons.build_circle, size: 64, color: AppColors.grey400),
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
              Expanded(child: _buildLocationButton(service)),
            ],
          ),
        ],
      ),
    );
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
          } catch (e) {
            //
          }
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
      icon: const Icon(Icons.location_on, color: AppColors.primary, size: 16),
      label: Text(
        'workshop_location'.tr,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.primary, width: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  Widget _buildActionButtons(ServiceModel service) {
    final currentUser = authController.currentUser.value;
    final bool isCurrentUserOwner = currentUser?.isOwner ?? false;
    final String currentUserId = currentUser?.id ?? '';
    final bool isServiceOwner = service.userId == currentUserId ||
        service.workshopData?['user_id'] == currentUserId;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!isCurrentUserOwner)
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
                              .unSaveService(savedService.id);
                        } else {
                          await serviceController.saveService(
                            service.id,
                            currentUserId,
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
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 12),
                if (!isServiceOwner)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        if (authController.isGuest) {
                          _showGuestDialog();
                          return;
                        }
                        _startChatWithWorkshop(service);
                      },
                      icon: const Icon(Icons.chat_bubble_outline,
                          size: 18, color: AppColors.info),
                      label: Text(
                        'chat'.tr,
                        style: const TextStyle(
                          color: AppColors.info,
                          fontSize: 14,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.info),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                  ),
              ],
            ),
          if (!isCurrentUserOwner) const SizedBox(height: 12),
          if (!isCurrentUserOwner && !isServiceOwner)
            Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: serviceController.isLoadingPhone.value
                        ? null
                        : () {
                            if (authController.isGuest) {
                              _showGuestDialog();
                              return;
                            }
                            _contactWorkshopOwner(service.id);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    icon: serviceController.isLoadingPhone.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.phone, size: 20),
                    label: Text(
                      serviceController.isLoadingPhone.value
                          ? 'getting_phone_number'.tr
                          : 'contact_workshop_owner'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )),
          if (!isCurrentUserOwner && !isServiceOwner)
            const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (authController.isGuest && !isCurrentUserOwner) {
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
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: Text('view_details'.tr),
            ),
          ),
        ],
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

  Future<void> _contactWorkshopOwner(String serviceId) async {
    try {
      if (authController.isGuest) {
        _showGuestDialog();
        return;
      }

      final phoneNumber =
          await serviceController.getWorkshopOwnerPhone(serviceId);

      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final cleanPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
        final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhoneNumber);

        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        } else {
          _showErrorDialog('cannot_open_phone_app'.tr);
        }
      } else {
        _showErrorDialog('phone_number_not_available'.tr);
      }
    } catch (e) {
      _showErrorDialog('error_getting_phone_number'.tr);
    }
  }

  void _showErrorDialog(String message) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 24),
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
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('ok'.tr),
          ),
        ],
      ),
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
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
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
                child: const Icon(Icons.location_on,
                    color: AppColors.primary, size: 20),
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
                  arguments: {'serviceType': selectedServiceType},
                );
              },
              icon: const Icon(Icons.map, size: 20),
              label: Text('open_map_search'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
          const Icon(Icons.search_off, size: 80, color: AppColors.grey400),
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
              onPressed: () {
                Get.toNamed(
                  AppRoutes.addService,
                  arguments: selectedServiceType,
                );
              },
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('login'.tr),
          ),
        ],
      ),
    );
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
            child: CircularProgressIndicator(color: AppColors.primary),
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
          onRefresh: () async => await _loadAndFilterServices(),
          color: AppColors.primary,
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: filteredServices.length +
                (!isOwner ? 1 : 0) +
                (serviceController.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              final bannerOffset = !isOwner ? 1 : 0;

              if (!isOwner && index == 0) {
                return _buildSearchBanner();
              }

              if (index == filteredServices.length + bannerOffset) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              final service = filteredServices[index - bannerOffset];
              return _buildServicePostCard(service);
            },
          ),
        );
      }),
      floatingActionButton: isOwner
          ? FloatingActionButton(
              onPressed: () {
                Get.toNamed(
                  AppRoutes.addService,
                  arguments: selectedServiceType,
                );
              },
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              tooltip: 'add_service'.tr,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
