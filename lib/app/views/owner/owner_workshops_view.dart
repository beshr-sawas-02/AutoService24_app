import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/service_controller.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';
import '../../utils/error_handler.dart';

class OwnerWorkshopsView extends StatefulWidget {
  const OwnerWorkshopsView({super.key});

  @override
  _OwnerWorkshopsViewState createState() => _OwnerWorkshopsViewState();
}

class _OwnerWorkshopsViewState extends State<OwnerWorkshopsView>
    with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final ServiceController serviceController = Get.find<ServiceController>();

  AnimationController? _animationController;
  final Map<String, int> _servicesCountCache = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadOwnerWorkshops();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadOwnerWorkshops() async {
    final userId = authController.currentUser.value?.id;
    if (userId != null && userId.isNotEmpty) {
      await workshopController.loadOwnerWorkshops(userId);
      _animationController?.forward();
      await _preloadServicesCount();
    }
  }

// عدّل _preloadServicesCount في OwnerWorkshopsView

  Future<void> _preloadServicesCount() async {
    for (var workshop in workshopController.ownerWorkshops) {
      if (!_servicesCountCache.containsKey(workshop.id)) {
        try {
          // استخدم الـ method الجديد
          final services =
              await serviceController.getServicesForWorkshop(workshop.id);

          final count = services
              .where((service) => service.workshopId == workshop.id)
              .length;

          _servicesCountCache[workshop.id] = count;

          print('✅ Workshop ${workshop.name}: $count services');
        } catch (e) {
          print('❌ Error loading services count: $e');
          _servicesCountCache[workshop.id] = 0;
        }
      }
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Obx(() {
        if (workshopController.isLoading.value) {
          return _buildLoadingState();
        }

        if (workshopController.ownerWorkshops.isEmpty) {
          return _buildEmptyState();
        }

        return _buildWorkshopsList();
      }),
      floatingActionButton: _buildFAB(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      shadowColor: AppColors.shadowLight,
      title: Text(
        'my_workshops'.tr,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: AppColors.textPrimary, size: 20),
        onPressed: () => Navigator.of(context).pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'loading_workshops'.tr,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: _loadOwnerWorkshops,
      color: AppColors.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.store_rounded,
                    size: 70,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'no_workshops_yet'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'create_first_workshop'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 18,
                    color: AppColors.primary.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'pull_to_refresh'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildCreateButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed(AppRoutes.addWorkshop),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_circle_outline,
                  color: AppColors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                'create_workshop'.tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopsList() {
    return RefreshIndicator(
      onRefresh: _loadOwnerWorkshops,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        itemCount: workshopController.ownerWorkshops.length,
        itemBuilder: (context, index) {
          final workshop = workshopController.ownerWorkshops[index];
          return TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 300 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, double value, child) {
              return Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildWorkshopCard(workshop),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWorkshopCard(workshop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showWorkshopDetails(workshop),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildWorkshopIcon(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workshop.name,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'tap_to_view_details'.tr,  // ✅ مع translation
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildMenuButton(workshop),
                  ],
                ),
                if (workshop.description != null &&
                    workshop.description!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    workshop.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                if (workshop.workingHours != null &&
                    workshop.workingHours!.isNotEmpty)
                  _buildInfoRow(
                    Icons.access_time_rounded,
                    workshop.workingHours!,
                    AppColors.primary,
                  ),
                const SizedBox(height: 12),
                _buildServicesCounter(workshop.id),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.store_rounded,
        color: AppColors.white,
        size: 30,
      ),
    );
  }

  Widget _buildMenuButton(workshop) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey100.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: PopupMenuButton<String>(
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        offset: const Offset(-10, 10),
        onSelected: (value) {
          if (value == 'edit') {
            _editWorkshop(workshop);
          } else if (value == 'delete') {
            _showDeleteConfirmation(workshop);
          }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'edit',
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'edit_workshop_info'.tr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const PopupMenuDivider(),
          PopupMenuItem(
            value: 'delete',
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'delete_workshop'.tr,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesCounter(String workshopId) {
    final count = _servicesCountCache[workshopId] ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.08),
            AppColors.primary.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.build_circle_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'services_count'.tr,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return Obx(() {
      if (workshopController.ownerWorkshops.isEmpty) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton.extended(
        onPressed: () => Get.toNamed(AppRoutes.addWorkshop),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          'add_workshop'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      );
    });
  }

  void _showWorkshopDetails(workshop) {
    Get.toNamed(
      AppRoutes.workshopDetails,
      arguments: workshop,
    );
  }

  void _editWorkshop(workshop) {
    final nameController = TextEditingController(text: workshop.name);
    final descriptionController =
        TextEditingController(text: workshop.description);
    final workingHoursController =
        TextEditingController(text: workshop.workingHours);

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.1),
                AppColors.primary.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'edit_workshop_info'.tr,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'workshop_name'.tr,
                controller: nameController,
                hint: 'enter_workshop_name'.tr,
                icon: Icons.store_rounded,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'description'.tr,
                controller: descriptionController,
                hint: 'enter_workshop_description'.tr,
                icon: Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'working_hours'.tr,
                controller: workingHoursController,
                hint: 'enter_working_hours'.tr,
                icon: Icons.access_time_rounded,
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _saveWorkshopChanges(
                      workshop,
                      nameController,
                      descriptionController,
                      workingHoursController,
                    ),
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
                      'save_changes'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: AppColors.grey100.withValues(alpha: 0.3),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveWorkshopChanges(
    workshop,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController workingHoursController,
  ) async {
    final name = nameController.text.trim();
    final description = descriptionController.text.trim();
    final workingHours = workingHoursController.text.trim();

    if (name.isEmpty) {
      ErrorHandler.showInfo('workshop_name_required'.tr);
      return;
    }

    if (description.isEmpty) {
      ErrorHandler.showInfo('workshop_description_required'.tr);
      return;
    }

    if (workingHours.isEmpty) {
      ErrorHandler.showInfo('working_hours_required'.tr);
      return;
    }

    Get.back();

    final success = await workshopController.updateWorkshop(
      workshop.id,
      {
        'name': name,
        'description': description,
        'working_hours': workingHours,
      },
    );

    if (success) {
      _servicesCountCache.clear();
      await _loadOwnerWorkshops();
    }
  }

  void _showDeleteConfirmation(workshop) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.08),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'delete_workshop'.tr,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'confirm_delete_workshop'.tr,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.store_rounded,
                          color: AppColors.error,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            workshop.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'workshop_services_will_be_deleted'.tr.replaceAll(
                          '{count}',
                          '${_servicesCountCache[workshop.id] ?? 0}'),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: AppColors.warning,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'action_cannot_be_undone'.tr,
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      _performDelete(workshop);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.delete_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'delete'.tr,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performDelete(workshop) async {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Material(
          color: Colors.black54,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(40),
              margin: const EdgeInsets.symmetric(horizontal: 40),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'deleting_workshop'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'processing_request'.tr,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await serviceController.loadServicesByWorkshopId(workshop.id);
      final workshopServices = serviceController.ownerServices
          .where((service) => service.workshopId == workshop.id)
          .toList();

      for (var service in workshopServices) {
        await serviceController.deleteService(service.id);
      }

      final success = await workshopController.deleteWorkshop(workshop.id);

      Get.until((route) => !Get.isDialogOpen!);

      if (success) {
        _servicesCountCache.clear();
        await _loadOwnerWorkshops();
      }
    } catch (e) {
      Get.until((route) => !Get.isDialogOpen!);
      ErrorHandler.handleAndShowError(e);
    }
  }
}
