import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/service_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../data/models/service_model.dart';
import '../../utils/helpers.dart';
import '../../config/app_colors.dart';

class SavedServicesView extends StatefulWidget {
  const SavedServicesView({super.key});

  @override
  _SavedServicesViewState createState() => _SavedServicesViewState();
}

class _SavedServicesViewState extends State<SavedServicesView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final AuthController authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _loadServicesIfNeeded();
  }

  Future<void> _loadServicesIfNeeded() async {
    if (authController.isLoggedIn.value && !authController.isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        serviceController.loadSavedServices();
      });
    }
  }

  Widget _buildImageWidget(String imagePath) {
    imagePath = imagePath.trim();

    if (imagePath.isEmpty) {
      return _buildErrorContainer('Empty image path');
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: AppColors.grey400);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 1,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }
    else if (imagePath.startsWith('/') || imagePath.contains('/data/')) {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: AppColors.grey400);
        },
      );
    }
    else {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.image_not_supported, color: AppColors.grey400);
        },
      );
    }
  }

  Widget _buildErrorContainer(String message) {
    return const Icon(Icons.image_not_supported, color: AppColors.grey400);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (authController.isGuest || !authController.isLoggedIn.value) {
          return _buildGuestContent();
        }
        return _buildUserContent();
      }),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      title: const Text(
        'Saved Services',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textSecondary),
        onPressed: () => Get.back(),
      ),
      actions: [
        Obx(() {
          if (authController.isGuest || !authController.isLoggedIn.value) {
            return const SizedBox.shrink();
          }
          return IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            onPressed: () => serviceController.loadSavedServices(),
            tooltip: 'Refresh',
          );
        }),
      ],
    );
  }

  Widget _buildGuestContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildGuestCard(),
        ],
      ),
    );
  }

  Widget _buildGuestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGuestIcon(),
          const SizedBox(height: 24),
          _buildGuestTitle(),
          const SizedBox(height: 12),
          _buildGuestDescription(),
          const SizedBox(height: 32),
          _buildFeaturesList(),
          const SizedBox(height: 32),
          _buildAuthButtons(),
          const SizedBox(height: 20),
          _buildBrowseButton(),
        ],
      ),
    );
  }

  Widget _buildGuestIcon() {
    return Container(
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.favorite,
        size: 36,
        color: AppColors.white,
      ),
    );
  }

  Widget _buildGuestTitle() {
    return const Text(
      'Save Your Favorite Services',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildGuestDescription() {
    return const Text(
      'Create an account to save services you love and access them anytime, anywhere.',
      style: TextStyle(
        fontSize: 16,
        color: AppColors.textSecondary,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.bookmark, 'text': 'Save unlimited services'},
      {'icon': Icons.sync, 'text': 'Sync across all devices'},
      {'icon': Icons.history, 'text': 'Track your service history'},
      {'icon': Icons.chat, 'text': 'Direct chat with providers'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryWithOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryWithOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'With your account:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...features.map((feature) => _buildFeatureRow(
            feature['icon'] as IconData,
            feature['text'] as String,
          )),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryWithOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.login),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Sign In'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Get.toNamed(AppRoutes.register),
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBrowseButton() {
    return TextButton.icon(
      onPressed: () => Get.back(),
      icon: const Icon(Icons.explore, color: AppColors.textSecondary, size: 18),
      label: const Text(
        'Browse Services Instead',
        style: TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUserContent() {
    return Obx(() {
      if (serviceController.isLoading.value) {
        return _buildLoadingState();
      }

      if (serviceController.savedServices.isEmpty) {
        return _buildEmptyState();
      }

      return _buildServicesList();
    });
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your saved services...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.grey100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bookmark_border,
              size: 48,
              color: AppColors.grey400,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Saved Services Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start exploring services and save the ones you like for quick access later.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.search),
            label: const Text('Explore Services'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesList() {
    return RefreshIndicator(
      onRefresh: () => serviceController.loadSavedServices(),
      color: AppColors.primary,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: serviceController.savedServices.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final savedService = serviceController.savedServices[index];
          return _buildSavedServiceItem(savedService);
        },
      ),
    );
  }

  Widget _buildSavedServiceItem(savedService) {
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
        return _buildSavedServiceCard(service, savedService);
      },
    );
  }

  Widget _buildSavedServiceCard(ServiceModel service, savedService) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.shadowLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: AppColors.cardBackground,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.serviceDetails, arguments: service),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildServiceHeader(service, savedService),
              const SizedBox(height: 12),
              _buildServiceDescription(service),
              if (service.images.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildServiceImages(service),
              ],
              const SizedBox(height: 12),
              _buildServiceFooter(service, savedService),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader(ServiceModel service, savedService) {
    return Row(
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
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryWithOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  service.serviceTypeName,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => _showUnsaveConfirmation(savedService),
          icon: const Icon(Icons.bookmark, color: AppColors.primary),
          tooltip: 'Remove from saved',
        ),
      ],
    );
  }

  Widget _buildServiceDescription(ServiceModel service) {
    return Text(
      service.description,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildServiceImages(ServiceModel service) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: service.images.length > 3 ? 3 : service.images.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: AppColors.grey200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImageWidget(service.images[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildServiceFooter(ServiceModel service, savedService) {
    return Row(
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
        Text(
          'Saved ${_formatSavedDate(savedService.savedAt)}',
          style: const TextStyle(
            color: AppColors.textHint,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorCard(savedService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.cardBackground,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline, color: AppColors.error),
        ),
        title: const Text('Service Unavailable', style: TextStyle(color: AppColors.textPrimary)),
        subtitle: const Text('This service may have been removed or is temporarily unavailable.', style: TextStyle(color: AppColors.textSecondary)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () => _unsaveService(savedService),
          tooltip: 'Remove from saved',
        ),
      ),
    );
  }

  Future<ServiceModel?> _getServiceFromSaved(String serviceId) async {
    try {
      final existingService = serviceController.services
          .firstWhereOrNull((service) => service.id == serviceId);

      if (existingService != null) {
        return existingService;
      }

      return await serviceController.getServiceById(serviceId);
    } catch (e) {
      return null;
    }
  }

  void _showUnsaveConfirmation(savedService) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.bookmark_remove, color: AppColors.primary),
            SizedBox(width: 12),
            Text('Remove Service', style: TextStyle(color: AppColors.textPrimary)),
          ],
        ),
        content: const Text(
            'Are you sure you want to remove this service from your saved list?',
            style: TextStyle(color: AppColors.textSecondary)
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _performUnsave(savedService);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _performUnsave(savedService) async {
    try {
      final success = await serviceController.unsaveService(savedService.id);

      if (!success) {
        Get.snackbar(
          'Error',
          'Failed to remove service. Please try again.',
          backgroundColor: AppColors.error.withValues(alpha: 0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred. Please try again.',
        backgroundColor: AppColors.error.withValues(alpha: 0.1),
        colorText: AppColors.error,
      );
    }
  }


  Future<void> _unsaveService(savedService) async {
    final success = await serviceController.unsaveService(savedService.id);
    if (success) {

    }
  }

  String _formatSavedDate(DateTime savedDate) {
    final now = DateTime.now();
    final difference = now.difference(savedDate);

    if (difference.inDays > 7) {
      return Helpers.formatDate(savedDate);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'recently';
    }
  }
}