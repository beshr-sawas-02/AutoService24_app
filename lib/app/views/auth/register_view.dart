import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/privacy_policy_controller.dart';
import '../../routes/app_routes.dart';
import '../privacy_policy_screen.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final AuthController authController = Get.find<AuthController>();
  final PrivacyPolicyController privacyController = Get.put(PrivacyPolicyController());
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedUserType = 'user';
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptPrivacy = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isTablet = screenWidth > 600;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'create_account'.tr,
          style: TextStyle(
            color: Colors.black87,
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: isTablet ? 500 : double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'create_account'.tr,
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isTablet ? 6 : 8),
                    Text(
                      'join_community'.tr,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 32),

                    // User Type Selection
                    Text(
                      'i_am_a'.tr,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: isTablet ? 12 : 16),

                    // User Type Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildUserTypeCard(
                            type: 'user',
                            icon: Icons.person,
                            title: 'regular_user'.tr,
                            subtitle: 'looking_for_services'.tr,
                            isSelected: _selectedUserType == 'user',
                            isTablet: isTablet,
                          ),
                        ),
                        SizedBox(width: isTablet ? 12 : 16),
                        Expanded(
                          child: _buildUserTypeCard(
                            type: 'owner',
                            icon: Icons.build,
                            title: 'workshop_owner'.tr,
                            subtitle: 'providing_services'.tr,
                            isSelected: _selectedUserType == 'owner',
                            isTablet: isTablet,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 24 : 32),

                    // Form Fields
                    _buildTextField(
                      controller: _usernameController,
                      icon: Icons.person,
                      label: 'username'.tr,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_username'.tr;
                        }
                        if (value.length < 3) {
                          return 'username_min_3_chars'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isTablet ? 12 : 16),

                    _buildTextField(
                      controller: _emailController,
                      icon: Icons.email_outlined,
                      label: 'email'.tr,
                      keyboardType: TextInputType.emailAddress,
                      isTablet: isTablet,
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
                    SizedBox(height: isTablet ? 12 : 16),

                    _buildTextField(
                      controller: _phoneController,
                      icon: Icons.phone_outlined,
                      label: 'phone_number'.tr,
                      keyboardType: TextInputType.phone,
                      isTablet: isTablet,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_phone'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isTablet ? 12 : 16),

                    _buildTextField(
                      controller: _passwordController,
                      icon: Icons.lock_outlined,
                      label: 'password'.tr,
                      obscureText: !_isPasswordVisible,
                      isTablet: isTablet,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                          size: isTablet ? 20 : 22,
                        ),
                        onPressed: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_enter_password'.tr;
                        }
                        if (value.length < 6) {
                          return 'password_min_6_chars'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isTablet ? 12 : 16),

                    _buildTextField(
                      controller: _confirmPasswordController,
                      icon: Icons.lock_outlined,
                      label: 'confirm_password'.tr,
                      obscureText: !_isConfirmPasswordVisible,
                      isTablet: isTablet,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isConfirmPasswordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: Colors.grey[600],
                          size: isTablet ? 20 : 22,
                        ),
                        onPressed: () {
                          setState(() =>
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please_confirm_password'.tr;
                        }
                        if (value != _passwordController.text) {
                          return 'passwords_do_not_match'.tr;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: isTablet ? 20 : 24),

                    // Privacy Policy Checkbox
                    _buildPrivacyPolicyCheckbox(isTablet),
                    SizedBox(height: isTablet ? 20 : 24),

                    // Create Account Button
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: isTablet ? 52 : 56,
                      child: ElevatedButton(
                        onPressed: authController.isLoading.value ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8A50),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
                          ),
                          elevation: 0,
                          shadowColor: Colors.transparent,
                        ),
                        child: authController.isLoading.value
                            ? SizedBox(
                          width: isTablet ? 20 : 24,
                          height: isTablet ? 20 : 24,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          'create_account'.tr,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )),
                    SizedBox(height: isTablet ? 20 : 24),

                    // Divider with "or continue with"
                    Row(
                      children: [
                        Expanded(
                            child: Divider(color: Colors.grey[300], thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 20),
                          child: Text(
                            'or_continue_with'.tr,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: isTablet ? 12 : 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                            child: Divider(color: Colors.grey[300], thickness: 1)),
                      ],
                    ),
                    SizedBox(height: isTablet ? 20 : 24),

                    _buildSocialLoginSection(isTablet),
                    SizedBox(height: isTablet ? 24 : 32),

                    // Already have account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'already_have_account'.tr,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 13 : 15,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.offNamed(AppRoutes.login),
                          child: Text(
                            'sign_in'.tr,
                            style: TextStyle(
                              color: const Color(0xFFFF8A50),
                              fontSize: isTablet ? 13 : 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 20 : 24),

                    // Continue as Guest
                    Center(
                      child: TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.userHome),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 20 : 24,
                              vertical: isTablet ? 10 : 12),
                        ),
                        child: Text(
                          'continue_as_guest'.tr,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: isTablet ? 12 : 14,
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrivacyPolicyCheckbox(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 16),
        border: Border.all(
          color: _acceptPrivacy ? const Color(0xFFFF8A50) : Colors.grey[300]!,
          width: _acceptPrivacy ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox
              GestureDetector(
                onTap: () {
                  setState(() {
                    _acceptPrivacy = !_acceptPrivacy;
                  });
                },
                child: Container(
                  width: isTablet ? 20 : 24,
                  height: isTablet ? 20 : 24,
                  decoration: BoxDecoration(
                    color: _acceptPrivacy
                        ? const Color(0xFFFF8A50)
                        : Colors.transparent,
                    border: Border.all(
                      color: _acceptPrivacy
                          ? const Color(0xFFFF8A50)
                          : Colors.grey[400]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: _acceptPrivacy
                      ? Icon(
                    Icons.check,
                    color: Colors.white,
                    size: isTablet ? 14 : 16,
                  )
                      : null,
                ),
              ),
              SizedBox(width: isTablet ? 8 : 12),
              // Privacy Policy Text
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: 'agree_to'.tr,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: isTablet ? 13 : 15,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'privacy_policy'.tr,
                        style: TextStyle(
                          color: const Color(0xFFFF8A50),
                          fontSize: isTablet ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFFF8A50),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPrivacyPolicy(),
                      ),
                      TextSpan(
                        text: ' ${'and'.tr} ',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: isTablet ? 13 : 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'terms_of_service'.tr,
                        style: TextStyle(
                          color: const Color(0xFFFF8A50),
                          fontSize: isTablet ? 13 : 15,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                          decorationColor: const Color(0xFFFF8A50),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showPrivacyPolicy(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_acceptPrivacy) ...[
            SizedBox(height: isTablet ? 12 : 16),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 8 : 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: isTablet ? 16 : 18,
                  ),
                  SizedBox(width: isTablet ? 6 : 8),
                  Expanded(
                    child: Text(
                      'privacy_policy_accepted_short'.tr,
                      style: TextStyle(
                        color: Colors.green[800],
                        fontSize: isTablet ? 12 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUserTypeCard({
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = type),
      child: Container(
        padding: EdgeInsets.all(isTablet ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFF8A50)
                : Colors.grey[300]!,
            width: 2,
          ),
          color: isSelected
              ? const Color(0xFFFF8A50).withValues(alpha: 0.1)
              : Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 10 : 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF8A50)
                    : Colors.grey[400],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: isTablet ? 20 : 24,
              ),
            ),
            SizedBox(height: isTablet ? 8 : 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 13 : 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? const Color(0xFFFF8A50)
                    : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 2 : 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 10 : 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection(bool isTablet) {
    return Obx(() => Column(
      children: [
        // Google Login
        _buildSocialButton(
          label: 'continue_with_google'.tr,
          backgroundColor: Colors.grey[100]!,
          borderColor: Colors.grey[400]!,
          textColor: Colors.grey[800]!,
          icon: Icons.account_circle_outlined,
          iconColor: Colors.red[600],
          onTap: authController.isLoading.value
              ? null
              : () => _socialLogin('google'),
          isGoogle: true,
          isTablet: isTablet,
        ),
        SizedBox(height: isTablet ? 12 : 16),

        // Facebook Login
        _buildSocialButton(
          label: 'continue_with_facebook'.tr,
          backgroundColor: const Color(0xFF1877F2),
          borderColor: const Color(0xFF1877F2),
          textColor: Colors.white,
          icon: Icons.facebook_rounded,
          iconColor: Colors.white,
          onTap: authController.isLoading.value
              ? null
              : () => _socialLogin('facebook'),
          isTablet: isTablet,
        ),

        // Apple Login
        SizedBox(height: isTablet ? 12 : 16),
        _buildSocialButton(
          label: 'continue_with_apple'.tr,
          backgroundColor: Colors.black,
          borderColor: Colors.black,
          textColor: Colors.white,
          icon: Icons.apple_rounded,
          iconColor: Colors.white,
          onTap: authController.isLoading.value
              ? null
              : () => _socialLogin('apple'),
          isTablet: isTablet,
        ),
      ],
    ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String label,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    required bool isTablet,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        fontSize: isTablet ? 14 : 16,
        fontWeight: FontWeight.w500,
        color: Colors.grey[800],
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: isTablet ? 14 : 16,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[600],
          size: isTablet ? 20 : 22,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          borderSide: const BorderSide(color: Color(0xFFFF8A50), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 14 : 16,
          vertical: isTablet ? 16 : 18,
        ),
        errorStyle: TextStyle(
          color: Colors.red[600],
          fontSize: isTablet ? 11 : 13,
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
    required bool isTablet,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: isTablet ? 48 : 56,
        decoration: BoxDecoration(
          color: onTap != null ? backgroundColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(isTablet ? 14 : 16),
          border: Border.all(
            color: onTap != null ? borderColor : Colors.grey[300]!,
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
                width: isTablet ? 28 : 34,
                height: isTablet ? 28 : 34,
              )
            else
              Icon(
                icon,
                color: onTap != null ? (iconColor ?? textColor) : Colors.grey[500],
                size: isTablet ? 20 : 24,
              ),
            SizedBox(width: isTablet ? 8 : 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: onTap != null ? textColor : Colors.grey[500],
                  fontSize: isTablet ? 13 : 15,
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

  void _showPrivacyPolicy() {
    Get.to(
          () => PrivacyPolicyView(
        showAcceptButton: true,
        isFromRegistration: true,
        onAccepted: () {
          setState(() {
            _acceptPrivacy = true;
          });
        },
      ),
      transition: Transition.cupertino,
      duration: const Duration(milliseconds: 300),
    );
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      if (!_acceptPrivacy) {
        Get.snackbar(
          'error'.tr,
          'privacy_terms_agreement'.tr,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
          icon: Icon(Icons.warning, color: Colors.red),
          duration: Duration(seconds: 4),
        );
        return;
      }

      final userData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'user_type': _selectedUserType,
        'acceptsPrivacyPolicy': true,
      };

      final success = await authController.register(userData);

      if (success) {
        // Mark privacy policy as accepted locally
        await privacyController.acceptPrivacyPolicy();
      }
    }
  }

  void _socialLogin(String provider) async {
    if (!_acceptPrivacy) {
      Get.snackbar(
        'error'.tr,
        'privacy_terms_agreement'.tr,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
        icon: Icon(Icons.warning, color: Colors.red),
        duration: Duration(seconds: 4),
      );
      return;
    }

    bool success = false;

    switch (provider) {
      case 'google':
        success = await authController.signInWithGoogle(userType: _selectedUserType);
        break;
      case 'facebook':
        success = await authController.signInWithFacebook(userType: _selectedUserType);
        break;
      case 'apple':
        success = await authController.signInWithApple(userType: _selectedUserType);
        break;
    }

    if (success) {
      // Mark privacy policy as accepted locally for social login
      await privacyController.acceptPrivacyPolicy();
    }
  }}