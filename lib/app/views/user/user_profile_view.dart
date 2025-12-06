import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/privacy_policy_controller.dart';
import '../../routes/app_routes.dart';
import '../privacy_policy_screen.dart';

class UserProfileView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();
  final PrivacyPolicyController privacyController =
      Get.put(PrivacyPolicyController());

  UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: RefreshIndicator(
        onRefresh: () async {
          await authController.refreshUserData();
        },
        child: Obx(() {
          if (!authController.isLoggedIn.value ||
              authController.currentUser.value == null) {
            return _buildGuestProfile();
          }
          return _buildUserProfile();
        }),
      ),
    );
  }

  Widget _buildGuestProfile() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: Get.height,
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 80, 20, 40),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Back button
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 58,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'guest_user'.tr,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'browsing_as_guest'.tr,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      icon: const Icon(Icons.login),
                      label: Text('login_to_account'.tr),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton.icon(
                      onPressed: () => Get.toNamed(AppRoutes.register),
                      icon: const Icon(Icons.person_add),
                      label: Text('create_new_account'.tr),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Privacy Policy link for guests
                  TextButton.icon(
                    onPressed: () => _showPrivacyPolicy(),
                    icon: const Icon(Icons.privacy_tip_outlined,
                        color: Colors.white),
                    label: Text(
                      'privacy_policy'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    final user = authController.currentUser.value!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          _buildProfileHeader(user),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildContactInformationCard(user),
                const SizedBox(height: 20),
                _buildProfileOptions(),
                const SizedBox(height: 20),
                _buildPrivacySection(),
                const SizedBox(height: 24),
                _buildLogoutButton(),
                const SizedBox(height: 12),
                _buildDeleteAccountButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Top row with back button and edit button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              // Edit button
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.editProfile),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Profile Avatar with camera icon
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 58,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  child: user.fullProfileImage != null &&
                          user.fullProfileImage!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(58),
                          child: Image.network(
                            user.fullProfileImage!,
                            width: 116,
                            height: 116,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Text(
                                user.username.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        )
                      : Text(
                          user.username.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              // Camera icon at bottom right of avatar
              Positioned(
                bottom: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () {
                    // Handle profile picture change
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // User name
          Text(
            user.username,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 8),

          // User type
          Text(
            user.isOwner ? 'workshop_owner'.tr : 'regular_user'.tr,
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformationCard(user) {
    final email = user.email ?? 'not_provided'.tr;
    final phone = user.phone ?? 'not_provided'.tr;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'contact_information'.tr,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),

          // Email - مع Expanded
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.email_outlined,
                    color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'email'.tr,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Phone - مع Expanded
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone_outlined,
                    color: Colors.grey[600], size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'phone'.tr,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: phone != 'not_provided'.tr
                            ? Colors.black87
                            : Colors.grey[500],
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
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

  Widget _buildProfileOptions() {
    final user = authController.currentUser.value!;

    return _buildSectionCard(
      title: 'profile'.tr,
      children: [
        _buildProfileOption(
          icon: Icons.edit_outlined,
          title: 'edit_profile'.tr,
          subtitle: 'update_personal_information'.tr,
          onTap: () => Get.toNamed(AppRoutes.editProfile),
          iconColor: Colors.orange,
        ),
        if (user.isOwner) ...[
          _buildProfileOption(
            icon: Icons.business_outlined,
            title: 'my_workshop'.tr,
            subtitle: 'manage_workshop'.tr,
            onTap: () {
            },
            iconColor: Colors.blue,
          ),
          _buildProfileOption(
            icon: Icons.build_outlined,
            title: 'my_services'.tr,
            subtitle: 'manage_services'.tr,
            onTap: () {
            },
            iconColor: Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildPrivacySection() {
    return _buildSectionCard(
      title: 'privacy_security'.tr,
      children: [
        _buildProfileOption(
          icon: Icons.privacy_tip_outlined,
          title: 'privacy_policy'.tr,
          subtitle: 'view_privacy_policy'.tr,
          onTap: () => _showPrivacyPolicy(),
          iconColor: Colors.indigo,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[600])!.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.black87,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout),
        label: Text('sign_out'.tr),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showDeleteAccountDialog,
        icon: const Icon(Icons.delete_forever),
        label: Text('delete_account'.tr),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[700]!),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    Get.to(
      () => PrivacyPolicyView(
        showAcceptButton: false,
        isFromRegistration: false,
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text('sign_out'.tr),
          ],
        ),
        content: Text('are_you_sure_sign_out_account'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('sign_out'.tr),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Text('delete_account'.tr),
          ],
        ),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'permanently_delete_account'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await authController.deleteAccount();
              if (!success) {
                Get.snackbar('error'.tr, 'failed_delete_account'.tr);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
