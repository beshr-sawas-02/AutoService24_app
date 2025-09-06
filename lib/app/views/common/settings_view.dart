import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/helpers.dart';
import '../../config/app_colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final AuthController authController = Get.find<AuthController>();

  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load settings from storage
    // This is a placeholder - you would implement actual settings storage
    setState(() {
      _notificationsEnabled = true;
      _locationEnabled = true;
      _darkModeEnabled = false;
      _selectedLanguage = 'English';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Section
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            icon: Icons.person,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            onTap: () => Get.toNamed('/edit-profile'),
          ),
          _buildSettingsTile(
            icon: Icons.lock,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () => _showChangePasswordDialog(),
          ),

          const SizedBox(height: 24),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive notifications about new messages and updates',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            icon: Icons.location_on,
            title: 'Location Services',
            subtitle: 'Allow app to access your location',
            value: _locationEnabled,
            onChanged: (value) {
              setState(() {
                _locationEnabled = value;
              });
              _saveSettings();
            },
          ),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              _saveSettings();
              // You would implement theme switching here
            },
          ),

          const SizedBox(height: 24),

          // App Section
          _buildSectionHeader('App'),
          _buildSettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: _selectedLanguage,
            onTap: () => _showLanguageDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'About',
            subtitle: 'App version and information',
            onTap: () => _showAboutDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help and contact support',
            onTap: () => _showHelpDialog(),
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () => _showPrivacyPolicy(),
          ),
          _buildSettingsTile(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Read our terms of service',
            onTap: () => _showTermsOfService(),
          ),

          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader('Data'),
          _buildSettingsTile(
            icon: Icons.download,
            title: 'Download Data',
            subtitle: 'Download a copy of your data',
            onTap: () => _downloadData(),
          ),
          _buildSettingsTile(
            icon: Icons.clear,
            title: 'Clear Cache',
            subtitle: 'Clear app cache and temporary files',
            onTap: () => _clearCache(),
          ),

          const SizedBox(height: 32),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSignOutDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Sign Out'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      child: ListTile(
        leading: Icon(icon, color: AppColors.textSecondary),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey400),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      child: SwitchListTile(
        secondary: Icon(icon, color: AppColors.textSecondary),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Future<void> _saveSettings() async {
    // Save settings to storage
    Map<String, dynamic> settings = {
      'notifications': _notificationsEnabled,
      'location': _locationEnabled,
      'darkMode': _darkModeEnabled,
      'language': _selectedLanguage,
    };

    // You would save this to SharedPreferences or secure storage
    Helpers.showSuccessSnackbar('Settings saved');
  }

  void _showChangePasswordDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Change Password', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Password change functionality would be implemented here.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement password change
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Arabic', 'French', 'Spanish'];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Select Language', style: TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((language) {
            return RadioListTile<String>(
              title: Text(language, style: const TextStyle(color: AppColors.textPrimary)),
              value: language,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                _saveSettings();
                Get.back();
              },
              activeColor: AppColors.primary,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('About AutoService24', style: TextStyle(color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0', style: TextStyle(color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Your Car Service Partner', style: TextStyle(color: AppColors.textPrimary)),
            SizedBox(height: 8),
            Text('Find and book automotive services near you.', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 16),
            Text('© 2024 AutoService24. All rights reserved.', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Help & Support', style: TextStyle(color: AppColors.textPrimary)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact us:', style: TextStyle(color: AppColors.textPrimary)),
            SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.email, color: AppColors.primary),
                SizedBox(width: 8),
                Text('support@autoservice24.com', style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: AppColors.primary),
                SizedBox(width: 8),
                Text('+1 (555) 123-4567', style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    Helpers.showInfoSnackbar('Privacy Policy would be displayed here');
  }

  void _showTermsOfService() {
    Helpers.showInfoSnackbar('Terms of Service would be displayed here');
  }

  void _downloadData() {
    Helpers.showInfoSnackbar('Data download functionality would be implemented here');
  }

  void _clearCache() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Clear Cache', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to clear the app cache? This will remove temporary files and may slow down the app initially.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Implement cache clearing
              Helpers.showSuccessSnackbar('Cache cleared successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        title: const Text('Sign Out', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              authController.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}