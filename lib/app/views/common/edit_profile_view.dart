import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../data/providers/api_provider.dart';
import '../../utils/image_service.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../utils/storage_service.dart';

class EditProfileView extends StatefulWidget {
  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final AuthController authController = Get.find<AuthController>();
  final UserController userController = Get.find<UserController>();

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  File? _selectedImage;
  String? _currentImageUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserData();
  }

  void _loadCurrentUserData() {
    final user = authController.currentUser.value;
    if (user != null) {
      _usernameController.text = user.username ?? '';
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone ?? '';
      _currentImageUrl = user.profileImage;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.orange,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),

              // Profile Image Section
              _buildProfileImageSection(),

              SizedBox(height: 32),

              // User Info Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 20),

                      // Username Field
                      CustomTextField(
                        controller: _usernameController,
                        labelText: 'Username',
                        prefixIcon: Icons.person,
                        validator: Validators.validateUsername,
                      ),
                      SizedBox(height: 16),

                      // Email Field
                      CustomTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      SizedBox(height: 16),

                      // Phone Field
                      CustomTextField(
                        controller: _phoneController,
                        labelText: 'Phone',
                        prefixIcon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        validator: Validators.validatePhone,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Account Type Info
              Card(
                elevation: 2,
                color: Colors.orange.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        authController.isOwner ? Icons.business : Icons.person,
                        color: Colors.orange,
                      ),
                      SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Account Type',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            authController.isOwner ? 'Workshop Owner' : 'User',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Save Button
              Obx(() => CustomButton(
                text: 'Save Changes',
                onPressed: (authController.isLoading.value || _isLoading) ? null : _saveProfile,
                isLoading: authController.isLoading.value || _isLoading,
                width: double.infinity,
              )),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
                border: Border.all(color: Colors.orange, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: _buildProfileImage(),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          'Tap camera icon to change photo',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        if (_selectedImage != null) ...[
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'New photo selected',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      String imageUrl = _currentImageUrl!.startsWith('http')
          ? _currentImageUrl!
          : '${ApiProvider.baseUrl}${_currentImageUrl}';

      return Image.network(
        imageUrl,
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.person,
            size: 60,
            color: Colors.grey[400],
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: Colors.orange,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    } else {
      return Icon(
        Icons.person,
        size: 60,
        color: Colors.grey[400],
      );
    }
  }

  Future<void> _pickImage() async {
    try {
      print("_pickImage: Starting image selection...");

      final image = await ImageService.showImageSourceDialog();
      if (image != null) {
        print("_pickImage: Image selected: ${image.path}");
        print("_pickImage: File size: ${(image.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB");

        setState(() {
          _selectedImage = image;
        });

        Helpers.showSuccessSnackbar('Image selected successfully');
      } else {
        print("_pickImage: No image selected");
      }
    } catch (e) {
      print("_pickImage error: $e");
      Helpers.showErrorSnackbar('Failed to select image');
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = authController.currentUser.value;
    if (user == null) {
      Helpers.showErrorSnackbar('User not found');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> updateData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      final success = await authController.updateProfileWithImage(
          user.id,
          updateData,
          _selectedImage
      );

      if (success) {
        // تحديث UI محلياً مباشرة
        setState(() {
          _currentImageUrl = authController.currentUser.value?.profileImage;
          _selectedImage = null; // مسح الصورة المؤقتة
        });

        Helpers.showSuccessSnackbar('Profile updated successfully');
        Get.back();
      }
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to update profile: ${e.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}