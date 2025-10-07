import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../config/app_colors.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reset_password'.tr),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Progress Indicator
              _buildProgressIndicator(),

              const SizedBox(height: 40),

              // Header
              _buildHeader(),

              const SizedBox(height: 40),

              // Form Fields based on current step
              _buildFormFields(),

              const SizedBox(height: 32),

              // Action Button
              Obx(() => CustomButton(
                text: _getButtonText(),
                onPressed: authController.isLoading.value ? null : _handleAction,
                isLoading: authController.isLoading.value,
              )),

              const SizedBox(height: 20),

              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('remember_password'.tr),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Get.offNamed(AppRoutes.login),
                    child: Text(
                      'login'.tr,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 0 ? AppColors.primary : AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 1 ? AppColors.primary : AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 2 ? AppColors.primary : AppColors.grey300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    String title;
    String subtitle;
    IconData icon;

    switch (_currentStep) {
      case 0:
        title = 'forgot_password'.tr;
        subtitle = 'enter_email_reset'.tr;
        icon = Icons.email_outlined;
        break;
      case 1:
        title = 'enter_verification_code'.tr;
        subtitle = 'code_sent_to_email'.tr;
        icon = Icons.verified_user_outlined;
        break;
      case 2:
        title = 'set_new_password'.tr;
        subtitle = 'create_new_password'.tr;
        icon = Icons.lock_outline;
        break;
      default:
        title = 'reset_complete'.tr;
        subtitle = 'password_reset_success'.tr;
        icon = Icons.check_circle_outline;
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryWithOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            icon,
            size: 40,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    switch (_currentStep) {
      case 0:
        return _buildEmailStep();
      case 1:
        return _buildCodeVerificationStep();
      case 2:
        return _buildPasswordStep();
      default:
        return _buildSuccessStep();
    }
  }

  Widget _buildEmailStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _emailController,
          labelText: 'email_address'.tr,
          hintText: 'enter_registered_email'.tr,
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.info),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'verify_email_info'.tr,
                  style: const TextStyle(
                    color: AppColors.info,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeVerificationStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3),),
          ),
          child: Column(
            children: [
              const Icon(Icons.email, color: AppColors.success, size: 40),
              const SizedBox(height: 12),
              Text(
                'verification_code_sent'.tr,
                style: const TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _emailController.text,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        CustomTextField(
          controller: _codeController,
          labelText: 'verification_code'.tr,
          hintText: 'enter_6_digit_code'.tr,
          prefixIcon: Icons.verified_user,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'verification_code_required'.tr;
            }
            if (value.length != 6) {
              return 'code_must_be_6_digits'.tr;
            }
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              return 'code_must_be_numbers_only'.tr;
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'didnt_receive_code'.tr,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => _resendCode(),
              child: Text(
                'resend_code'.tr,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _newPasswordController,
          labelText: 'new_password'.tr,
          hintText: 'enter_new_password'.tr,
          prefixIcon: Icons.lock,
          obscureText: true,
          validator: Validators.validatePassword,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'confirm_new_password'.tr,
          hintText: 'confirm_new_password_hint'.tr,
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _newPasswordController.text,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.security, color: AppColors.success),
                  const SizedBox(width: 8),
                  Text(
                    'password_requirements'.tr,
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildPasswordRequirement('at_least_6_characters'.tr),
              _buildPasswordRequirement('contains_letters_numbers'.tr),
              _buildPasswordRequirement('no_spaces_allowed'.tr),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String requirement) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 8),
          Text(
            requirement,
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                'password_reset_successful'.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'password_updated_success'.tr,
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 0:
        return 'send_verification_code'.tr;
      case 1:
        return 'verify_code'.tr;
      case 2:
        return 'reset_password'.tr;
      default:
        return 'go_to_login'.tr;
    }
  }

  Future<void> _handleAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    switch (_currentStep) {
      case 0:
        await _sendVerificationCode();
        break;
      case 1:
        await _verifyCode();
        break;
      case 2:
        await _resetPassword();
        break;
      default:
        _goToLogin();
    }
  }

  Future<void> _sendVerificationCode() async {
    final success = await authController.sendForgotPasswordCode(
      _emailController.text.trim(),
    );

    if (success) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  Future<void> _verifyCode() async {
    final success = await authController.verifyResetCode(
      _emailController.text.trim(),
      _codeController.text.trim(),
    );

    if (success) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  Future<void> _resetPassword() async {
    final success = await authController.forgotPassword(
      _emailController.text.trim(),
      _newPasswordController.text,
    );

    if (success) {
      setState(() {
        _currentStep = 3;
      });
    }
  }

  Future<void> _resendCode() async {
    await authController.sendForgotPasswordCode(
      _emailController.text.trim(),
    );
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}