import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class ForgotPasswordView extends StatefulWidget {
  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final AuthController authController = Get.find<AuthController>();
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reset Password'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),

              // Progress Indicator
              _buildProgressIndicator(),

              SizedBox(height: 40),

              // Header
              _buildHeader(),

              SizedBox(height: 40),

              // Form Fields based on current step
              _buildFormFields(),

              SizedBox(height: 32),

              // Action Button
              Obx(() => CustomButton(
                text: _getButtonText(),
                onPressed: authController.isLoading.value ? null : _handleAction,
                isLoading: authController.isLoading.value,
              )),

              SizedBox(height: 20),

              // Back to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Remember your password? '),
                  GestureDetector(
                    onTap: () => Get.offNamed(AppRoutes.login),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.orange,
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
              color: _currentStep >= 0 ? Colors.orange : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: _currentStep >= 1 ? Colors.orange : Colors.grey[300],
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
        title = 'Forgot Password?';
        subtitle = 'Enter your email address to reset your password';
        icon = Icons.email_outlined;
        break;
      case 1:
        title = 'Set New Password';
        subtitle = 'Create a new password for your account';
        icon = Icons.lock_outline;
        break;
      default:
        title = 'Reset Complete';
        subtitle = 'Your password has been successfully reset';
        icon = Icons.check_circle_outline;
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(
            icon,
            size: 40,
            color: Colors.orange,
          ),
        ),
        SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
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
          labelText: 'Email Address',
          hintText: 'Enter your registered email',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'We\'ll verify your email and allow you to set a new password.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
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

  Widget _buildPasswordStep() {
    return Column(
      children: [
        CustomTextField(
          controller: _newPasswordController,
          labelText: 'New Password',
          hintText: 'Enter your new password',
          prefixIcon: Icons.lock,
          obscureText: true,
          validator: Validators.validatePassword,
        ),
        SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirm New Password',
          hintText: 'Confirm your new password',
          prefixIcon: Icons.lock_outline,
          obscureText: true,
          validator: (value) => Validators.validateConfirmPassword(
            value,
            _newPasswordController.text,
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.security, color: Colors.green),
                  SizedBox(width: 8),
                  Text(
                    'Password Requirements:',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              _buildPasswordRequirement('At least 6 characters'),
              _buildPasswordRequirement('Contains letters and numbers'),
              _buildPasswordRequirement('No spaces allowed'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirement(String requirement) {
    return Padding(
      padding: EdgeInsets.only(left: 32, top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Colors.green.shade600,
          ),
          SizedBox(width: 8),
          Text(
            requirement,
            style: TextStyle(
              color: Colors.green.shade700,
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
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              SizedBox(height: 16),
              Text(
                'Password Reset Successful!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Your password has been successfully updated. You can now login with your new password.',
                style: TextStyle(
                  color: Colors.green.shade600,
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
        return 'Verify Email';
      case 1:
        return 'Reset Password';
      default:
        return 'Go to Login';
    }
  }

  Future<void> _handleAction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    switch (_currentStep) {
      case 0:
        await _verifyEmail();
        break;
      case 1:
        await _resetPassword();
        break;
      default:
        _goToLogin();
    }
  }

  Future<void> _verifyEmail() async {
    // In a real app, you would verify the email with the backend
    // For now, we'll simulate this step
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _currentStep = 1;
    });
  }

  Future<void> _resetPassword() async {
    final success = await authController.forgotPassword(
      _emailController.text.trim(),
      _newPasswordController.text,
    );

    if (success) {
      setState(() {
        _currentStep = 2;
      });
    }
  }

  void _goToLogin() {
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}