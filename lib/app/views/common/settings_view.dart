// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/auth_controller.dart';
// import '../../utils/helpers.dart';
// import '../../config/app_colors.dart';
//
// class SettingsView extends StatefulWidget {
//   const SettingsView({super.key});
//
//   @override
//   _SettingsViewState createState() => _SettingsViewState();
// }
//
// class _SettingsViewState extends State<SettingsView> {
//   final AuthController authController = Get.find<AuthController>();
//
//   bool _notificationsEnabled = true;
//   bool _locationEnabled = true;
//   bool _darkModeEnabled = false;
//   String _selectedLanguage = 'English';
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//   }
//
//   Future<void> _loadSettings() async {
//     // Load settings from storage
//     // This is a placeholder - you would implement actual settings storage
//     setState(() {
//       _notificationsEnabled = true;
//       _locationEnabled = true;
//       _darkModeEnabled = false;
//       _selectedLanguage = 'English';
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text('settings'.tr),
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.white,
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           // Account Section
//           _buildSectionHeader('account'.tr),
//           _buildSettingsTile(
//             icon: Icons.person,
//             title: 'edit_profile'.tr,
//             subtitle: 'update_password'.tr,
//             onTap: () => Get.toNamed('/edit-profile'),
//           ),
//           _buildSettingsTile(
//             icon: Icons.lock,
//             title: 'change_password'.tr,
//             subtitle: 'update_password'.tr,
//             onTap: () => _showChangePasswordDialog(),
//           ),
//
//           const SizedBox(height: 24),
//
//           // Preferences Section
//           _buildSectionHeader('preferences'.tr),
//           _buildSwitchTile(
//             icon: Icons.notifications,
//             title: 'push_notifications'.tr,
//             subtitle: 'receive_notifications'.tr,
//             value: _notificationsEnabled,
//             onChanged: (value) {
//               setState(() {
//                 _notificationsEnabled = value;
//               });
//               _saveSettings();
//             },
//           ),
//           _buildSwitchTile(
//             icon: Icons.location_on,
//             title: 'location_services'.tr,
//             subtitle: 'allow_location'.tr,
//             value: _locationEnabled,
//             onChanged: (value) {
//               setState(() {
//                 _locationEnabled = value;
//               });
//               _saveSettings();
//             },
//           ),
//           _buildSwitchTile(
//             icon: Icons.dark_mode,
//             title: 'dark_mode'.tr,
//             subtitle: 'use_dark_theme'.tr,
//             value: _darkModeEnabled,
//             onChanged: (value) {
//               setState(() {
//                 _darkModeEnabled = value;
//               });
//               _saveSettings();
//               // You would implement theme switching here
//             },
//           ),
//
//           const SizedBox(height: 24),
//
//           // App Section
//           _buildSectionHeader('app'.tr),
//           _buildSettingsTile(
//             icon: Icons.language,
//             title: 'language'.tr,
//             subtitle: _selectedLanguage,
//             onTap: () => _showLanguageDialog(),
//           ),
//           _buildSettingsTile(
//             icon: Icons.info,
//             title: 'about'.tr,
//             subtitle: 'app_version_info'.tr,
//             onTap: () => _showAboutDialog(),
//           ),
//           _buildSettingsTile(
//             icon: Icons.help,
//             title: 'help_support'.tr,
//             subtitle: 'get_help_support'.tr,
//             onTap: () => _showHelpDialog(),
//           ),
//           _buildSettingsTile(
//             icon: Icons.privacy_tip,
//             title: 'privacy_policy'.tr,
//             subtitle: 'read_privacy_policy'.tr,
//             onTap: () => _showPrivacyPolicy(),
//           ),
//           _buildSettingsTile(
//             icon: Icons.description,
//             title: 'terms_of_service'.tr,
//             subtitle: 'read_terms'.tr,
//             onTap: () => _showTermsOfService(),
//           ),
//
//           const SizedBox(height: 24),
//
//           // Data Section
//           _buildSectionHeader('data'.tr),
//           _buildSettingsTile(
//             icon: Icons.download,
//             title: 'download_data'.tr,
//             subtitle: 'download_copy_data'.tr,
//             onTap: () => _downloadData(),
//           ),
//           _buildSettingsTile(
//             icon: Icons.clear,
//             title: 'clear_cache'.tr,
//             subtitle: 'clear_temp_files'.tr,
//             onTap: () => _clearCache(),
//           ),
//
//           const SizedBox(height: 32),
//
//           // Sign Out Button
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => _showSignOutDialog(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.error,
//                 foregroundColor: AppColors.white,
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               child: Text('sign_out'.tr),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: const TextStyle(
//           fontSize: 18,
//           fontWeight: FontWeight.bold,
//           color: AppColors.primary,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSettingsTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required VoidCallback onTap,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       color: AppColors.cardBackground,
//       child: ListTile(
//         leading: Icon(icon, color: AppColors.textSecondary),
//         title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
//         subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey400),
//         onTap: onTap,
//       ),
//     );
//   }
//
//   Widget _buildSwitchTile({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required bool value,
//     required ValueChanged<bool> onChanged,
//   }) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 8),
//       color: AppColors.cardBackground,
//       child: SwitchListTile(
//         secondary: Icon(icon, color: AppColors.textSecondary),
//         title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
//         subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary)),
//         value: value,
//         onChanged: onChanged,
//         activeColor: AppColors.primary,
//       ),
//     );
//   }
//
//   Future<void> _saveSettings() async {
//     // Save settings to storage
//     Map<String, dynamic> settings = {
//       'notifications': _notificationsEnabled,
//       'location': _locationEnabled,
//       'darkMode': _darkModeEnabled,
//       'language': _selectedLanguage,
//     };
//
//     // You would save this to SharedPreferences or secure storage
//     Helpers.showSuccessSnackbar('settings_saved'.tr);
//   }
//
//   void _showChangePasswordDialog() {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: AppColors.white,
//         title: Text('change_password'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//         content: Text('password_change_implemented'.tr, style: const TextStyle(color: AppColors.textSecondary)),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('cancel'.tr),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               // Implement password change
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.white,
//             ),
//             child: Text('change'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showLanguageDialog() {
//     final languages = [
//       {'code': 'en', 'name': 'english'.tr},
//       {'code': 'ar', 'name': 'arabic'.tr},
//       {'code': 'de', 'name': 'german'.tr},
//       {'code': 'fr', 'name': 'french'.tr},
//       {'code': 'es', 'name': 'spanish'.tr},
//     ];
//
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: AppColors.white,
//         title: Text('select_language'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: languages.map((language) {
//             return RadioListTile<String>(
//               title: Text(language['name']!, style: const TextStyle(color: AppColors.textPrimary)),
//               value: language['name']!,
//               groupValue: _selectedLanguage,
//               onChanged: (value) {
//                 setState(() {
//                   _selectedLanguage = value!;
//                 });
//                 // Change app language
//                 String languageCode = languages.firstWhere((lang) => lang['name'] == value)['code']!;
//                 Get.updateLocale(Locale(languageCode));
//                 _saveSettings();
//                 Get.back();
//               },
//               activeColor: AppColors.primary,
//             );
//           }).toList(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('cancel'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showAboutDialog() {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: AppColors.white,
//         title: Text('about_autoservice'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('version'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//             const SizedBox(height: 8),
//             Text('car_service_partner'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//             const SizedBox(height: 8),
//             Text('find_book_services'.tr, style: const TextStyle(color: AppColors.textSecondary)),
//             const SizedBox(height: 16),
//             Text('copyright'.tr, style: const TextStyle(color: AppColors.textSecondary)),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.white,
//             ),
//             child: Text('ok'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showHelpDialog() {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: AppColors.white,
//         title: Text('help_support'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('need_help_contact'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 const Icon(Icons.email, color: AppColors.primary),
//                 const SizedBox(width: 8),
//                 Text('support_email'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//               ],
//             ),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 const Icon(Icons.phone, color: AppColors.primary),
//                 const SizedBox(width: 8),
//                 Text('support_phone'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//               ],
//             ),
//           ],
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.white,
//             ),
//             child: Text('ok'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPrivacyPolicy() {
//     Helpers.showInfoSnackbar('privacy_displayed_here'.tr);
//   }
//
//   void _showTermsOfService() {
//     Helpers.showInfoSnackbar('terms_displayed_here'.tr);
//   }
//
//   void _downloadData() {
//     Helpers.showInfoSnackbar('data_download_implemented'.tr);
//   }
//
//   void _clearCache() {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: AppColors.white,
//         title: Text('clear_cache'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//         content: Text('are_you_sure_clear_cache'.tr, style: const TextStyle(color: AppColors.textSecondary)),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('cancel'.tr),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               // Implement cache clearing
//               Helpers.showSuccessSnackbar('cache_cleared'.tr);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: AppColors.white,
//             ),
//             child: Text('clear'.tr),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showSignOutDialog() {
//     Get.dialog(
//       AlertDialog(
//         backgroundColor: AppColors.white,
//         title: Text('sign_out'.tr, style: const TextStyle(color: AppColors.textPrimary)),
//         content: Text('are_you_sure_sign_out'.tr, style: const TextStyle(color: AppColors.textSecondary)),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(),
//             child: Text('cancel'.tr),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Get.back();
//               authController.logout();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.error,
//               foregroundColor: AppColors.white,
//             ),
//             child: Text('sign_out'.tr),
//           ),
//         ],
//       ),
//     );
//   }
// }