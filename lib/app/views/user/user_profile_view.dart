import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/helpers.dart';

class UserProfileView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        // إذا المستخدم غير مسجل دخول أو ضيف
        if (!authController.isLoggedIn.value || authController.currentUser.value == null) {
          return _buildGuestProfile();
        }

        return _buildUserProfile();
      }),
    );
  }

  Widget _buildGuestProfile() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 80, 20, 40),
      decoration: BoxDecoration(
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
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
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 24),

                Text(
                  'Guest User',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),

                SizedBox(height: 8),

                Text(
                  'You\'re browsing as a guest',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),

                SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.login),
                    icon: Icon(Icons.login),
                    label: Text('Login to Your Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),

                SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: OutlinedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.register),
                    icon: Icon(Icons.person_add),
                    label: Text('Create New Account'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    final user = authController.currentUser.value!;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Profile Header
          _buildProfileHeader(user),

          // Content with padding
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // Contact Information Card
                _buildContactInformationCard(user),

                SizedBox(height: 20),

                // Profile Options
                _buildProfileOptions(),

                SizedBox(height: 20),

                // Settings Options
                _buildSettingsOptions(),

                SizedBox(height: 24),

                // Logout Button
                _buildLogoutButton(),

                SizedBox(height: 12),

                // Delete Account Button
                _buildDeleteAccountButton(),

                SizedBox(height: 20),
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
      padding: EdgeInsets.fromLTRB(20, 60, 20, 40),
      decoration: BoxDecoration(
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
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
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

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
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: user.profileImage != null && user.profileImage!.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(58),
                    child: Image.network(
                      user.profileImage!,
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Text(
                          user.username.substring(0, 1).toUpperCase(),
                          style: TextStyle(
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
                    style: TextStyle(
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
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.orange,
                      size: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // User name
          Text(
            user.username,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: 8),

          // User type
          Text(
            user.isOwner ? 'Workshop Owner' : 'Regular User',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInformationCard(user) {
    final email = user.email ?? 'Not provided';
    final phone = user.phone ?? 'Not provided';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),

          // Email
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.email_outlined, color: Colors.grey[600], size: 20),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 20),

          // Phone
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phone_outlined, color: Colors.grey[600], size: 20),
              ),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phone',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    phone,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: phone != 'Not provided' ? Colors.black87 : Colors.grey[500],
                    ),
                  ),
                ],
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
      title: 'Profile',
      children: [
        _buildProfileOption(
          icon: Icons.edit_outlined,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => Get.toNamed(AppRoutes.editProfile),
          iconColor: Colors.orange,
        ),
        if (user.isOwner) ...[
          _buildProfileOption(
            icon: Icons.business_outlined,
            title: 'My Workshop',
            subtitle: 'Manage your workshop',
            onTap: () {
              Get.snackbar('Info', 'Workshop management coming soon');
            },
            iconColor: Colors.blue,
          ),
          _buildProfileOption(
            icon: Icons.build_outlined,
            title: 'My Services',
            subtitle: 'Manage your services',
            onTap: () {
              Get.snackbar('Info', 'Service management coming soon');
            },
            iconColor: Colors.green,
          ),
        ],
      ],
    );
  }

  Widget _buildSettingsOptions() {
    return _buildSectionCard(
      title: 'Settings',
      children: [
        _buildProfileOption(
          icon: Icons.settings_outlined,
          title: 'Settings',
          subtitle: 'App preferences and notifications',
          onTap: () => Get.toNamed(AppRoutes.settings),
          iconColor: Colors.blue,
        ),
        _buildProfileOption(
          icon: Icons.help_outline,
          title: 'Help & Support',
          subtitle: 'Get help and contact support',
          onTap: () => _showHelpDialog(),
          iconColor: Colors.green,
        ),
        _buildProfileOption(
          icon: Icons.info_outline,
          title: 'About',
          subtitle: 'App version and information',
          onTap: () => _showAboutDialog(),
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 12),
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
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.grey[600])!.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.grey[600],
                size: 20,
              ),
            ),
            SizedBox(width: 16),
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
                  SizedBox(height: 2),
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
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: Icon(Icons.logout),
        label: Text('Sign Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton() {
    return Container(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showDeleteAccountDialog,
        icon: Icon(Icons.delete_forever),
        label: Text('Delete Account'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red[700],
          side: BorderSide(color: Colors.red[700]!),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.red),
            ),
            SizedBox(width: 12),
            Text('Sign Out'),
          ],
        ),
        content: Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            child: Text('Sign Out'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning, color: Colors.red),
            ),
            SizedBox(width: 12),
            Text('Delete Account'),
          ],
        ),
        content: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This will permanently delete your account and all data. This action cannot be undone.',
                  style: TextStyle(
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
            child: Text('Cancel'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[600],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              final success = await authController.deleteAccount();
              if (!success) {
                Get.snackbar('Error', 'Failed to delete account. Please try again.');
              }
            },
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
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

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.help_outline, color: Colors.orange),
            ),
            SizedBox(width: 12),
            Text('Help & Support'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:'),
            SizedBox(height: 16),
            _buildContactRow(Icons.email, 'support@carservicehub.com', Colors.orange),
            SizedBox(height: 12),
            _buildContactRow(Icons.phone, '+1 (555) 123-4567', Colors.orange),
            SizedBox(height: 12),
            _buildContactRow(Icons.schedule, 'Mon-Fri: 9 AM - 6 PM', Colors.orange),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
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

  Widget _buildContactRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.info_outline, color: Colors.blue),
            ),
            SizedBox(width: 12),
            Text('About CarServiceHub'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Your Car Service Partner',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Find and book automotive services near you.',
            ),
            SizedBox(height: 16),
            Text(
              '© 2024 CarServiceHub. All rights reserved.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            child: Text('OK'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
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