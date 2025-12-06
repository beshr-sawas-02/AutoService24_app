import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/language_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../config/app_colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  String _selectedUserType = 'user';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'login'.tr,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          _buildLanguageSwitcher(),
          const SizedBox(width: 5),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'welcome_back'.tr,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'sign_in_account'.tr,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Email Field
              _buildTextField(
                controller: _emailController,
                icon: Icons.email_outlined,
                label: 'email'.tr,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_email'.tr;
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'please_enter_valid_email'.tr;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              _buildTextField(
                controller: _passwordController,
                icon: Icons.lock_outlined,
                label: 'password'.tr,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.textSecondary,
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'please_enter_password'.tr;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Forgot Password Link
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.toNamed(AppRoutes.forgotPassword),
                  child: Text(
                    'forgot_password'.tr,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Login Button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authController.isLoading.value ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: authController.isLoading.value
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    'login'.tr,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              )),

              const SizedBox(height: 32),

              // Divider
              Row(
                children: [
                  const Expanded(
                      child: Divider(color: AppColors.border, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'or_continue_with'.tr,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Expanded(
                      child: Divider(color: AppColors.border, thickness: 1)),
                ],
              ),

              const SizedBox(height: 32),

              // Social Login Section
              _buildSocialLoginSection(),

              const SizedBox(height: 32),

              // User Type Selection
              _buildUserTypeSelection(),

              const SizedBox(height: 40),

              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'dont_have_account'.tr,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.register),
                    child: Text(
                      'sign_up'.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Continue as Guest
              Center(
                child: TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.userHome),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    'continue_as_guest'.tr,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSwitcher() {
    final LanguageController languageController =
    Get.find<LanguageController>();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: AppColors.textSecondary),
      onSelected: (String languageCode) {
        languageController.changeLocale(languageCode);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              const Text('🇺🇸'),
              const SizedBox(width: 8),
              Text('english'.tr),
              if (languageController.locale.value.languageCode == 'en')
                const Spacer()
              else
                const SizedBox.shrink(),
              if (languageController.locale.value.languageCode == 'en')
                const Icon(Icons.check, color: AppColors.primary)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'de',
          child: Row(
            children: [
              const Text('🇩🇪'),
              const SizedBox(width: 8),
              Text('german'.tr),
              if (languageController.locale.value.languageCode == 'de')
                const Spacer()
              else
                const SizedBox.shrink(),
              if (languageController.locale.value.languageCode == 'de')
                const Icon(Icons.check, color: AppColors.primary)
              else
                const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginSection() {
    return Obx(() => Column(
      children: [
        // Google Login
        _buildSocialButton(
          label: 'continue_with_google'.tr,
          backgroundColor: AppColors.grey100,
          borderColor: AppColors.grey400,
          textColor: AppColors.grey800,
          icon: Icons.account_circle_outlined,
          iconColor: AppColors.error,
          onTap: authController.isLoading.value
              ? null
              : () => _socialLogin('google'),
          isGoogle: true,
        ),
        const SizedBox(height: 16),

        // // Facebook Login
        // _buildSocialButton(
        //   label: 'continue_with_facebook'.tr,
        //   backgroundColor: AppColors.info,
        //   borderColor: AppColors.info,
        //   textColor: AppColors.white,
        //   icon: Icons.facebook_rounded,
        //   iconColor: AppColors.white,
        //   onTap: authController.isLoading.value
        //       ? null
        //       : () => _socialLogin('facebook'),
        // ),

        // // Apple Login
        // const SizedBox(height: 16),
        // _buildSocialButton(
        //   label: 'continue_with_apple'.tr,
        //   backgroundColor: AppColors.textPrimary,
        //   borderColor: AppColors.textPrimary,
        //   textColor: AppColors.white,
        //   icon: Icons.apple_rounded,
        //   iconColor: AppColors.white,
        //   onTap: authController.isLoading.value
        //       ? null
        //       : () => _socialLogin('apple'),
        // ),
      ],
    ));
  }

  Widget _buildUserTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'login_as'.tr,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child:
              _buildUserTypeButton('regular_user'.tr, Icons.person, 'user'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildUserTypeButton(
                  'workshop_owner'.tr, Icons.build, 'owner'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUserTypeButton(String label, IconData icon, String type) {
    bool selected = _selectedUserType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: 2,
          ),
          color: selected ? AppColors.primaryWithOpacity(0.1) : AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.borderFocus, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        errorStyle: const TextStyle(
          color: AppColors.error,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required IconData icon,
    Color? iconColor,
    required VoidCallback? onTap,
    bool isGoogle = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: onTap != null ? backgroundColor : AppColors.grey200,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: onTap != null ? borderColor : AppColors.border,
            width: 1.5,
          ),
          boxShadow: [
            if (onTap != null)
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              Image.asset(
                'assets/icons/google_icon.png',
                width: 34,
                height: 34,
              )
            else
              Icon(
                icon,
                color: onTap != null
                    ? (iconColor ?? textColor)
                    : AppColors.textHint,
                size: 24,
              ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: onTap != null ? textColor : AppColors.textHint,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      await authController.login(
          _emailController.text.trim(), _passwordController.text);
    }
  }

  void _socialLogin(String provider) async {
    switch (provider) {
      case 'google':
        await authController.signInWithGoogle(userType: _selectedUserType);
        break;
    // // Facebook Login
    // case 'facebook':
    //   await authController.signInWithFacebook(userType: _selectedUserType);
    //   break;
    // // Apple Login
    // case 'apple':
    //   await authController.signInWithApple(userType: _selectedUserType);
    //   break;
    }
  }
}