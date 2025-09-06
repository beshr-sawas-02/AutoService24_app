// utils/image_service.dart
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'helpers.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // التحقق الموحد من الصورة
  static Future<String?> validateImageFile(File file) async {
    try {
      // التحقق من وجود الملف
      if (!await file.exists()) {
        return 'Image file not found';
      }

      // التحقق من الامتداد
      final fileName = file.path.toLowerCase();
      final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];

      bool hasValidExtension = allowedExtensions.any(
              (ext) => fileName.endsWith(ext)
      );

      if (!hasValidExtension) {
        return 'Please select a valid image file (JPG, PNG, GIF, WebP)';
      }

      // التحقق من حجم الملف
      final fileSize = await file.length();
      const maxSizeInBytes = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxSizeInBytes) {
        final sizeMB = (fileSize / (1024 * 1024)).toStringAsFixed(1);
        return 'Image size is ${sizeMB}MB. Maximum allowed is 5MB';
      }

      return null; // الصورة صحيحة
    } catch (e) {
      return 'Image validation failed: ${e.toString()}';
    }
  }

  // Pick single image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        final validationError = await validateImageFile(file);

        if (validationError != null) {
          Helpers.showErrorSnackbar(validationError);
          return null;
        }

        return file;
      }
      return null;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to pick image: ${e.toString()}');
      return null;
    }
  }

  // Pick single image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (image != null) {
        final file = File(image.path);
        final validationError = await validateImageFile(file);

        if (validationError != null) {
          Helpers.showErrorSnackbar(validationError);
          return null;
        }

        return file;
      }
      return null;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to take photo: ${e.toString()}');
      return null;
    }
  }

  // Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages({int maxImages = 5}) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 80,
      );

      if (images.length > maxImages) {
        Helpers.showWarningSnackbar('You can only select up to $maxImages images');
        return [];
      }

      List<File> validFiles = [];
      List<String> errors = [];

      for (int i = 0; i < images.length; i++) {
        final file = File(images[i].path);
        final validationError = await validateImageFile(file);

        if (validationError == null) {
          validFiles.add(file);
        } else {
          errors.add('Image ${i + 1}: $validationError');
        }
      }

      // إظهار أخطاء التحقق إن وجدت
      if (errors.isNotEmpty) {
        Helpers.showErrorSnackbar('Some images were skipped:\n${errors.join('\n')}');
      }

      return validFiles;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to pick images: ${e.toString()}');
      return [];
    }
  }

  // Show image source selection dialog - نسخة محسنة
  static Future<File?> showImageSourceDialog() async {
    try {
      final result = await Get.dialog<ImageSource>(
        AlertDialog(
          title: const Text(
            'Select Image Source',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSourceOption(
                icon: Icons.photo_library,
                title: 'Gallery',
                subtitle: 'Choose from existing photos',
                source: ImageSource.gallery,
              ),
              const SizedBox(height: 8),
              _buildSourceOption(
                icon: Icons.camera_alt,
                title: 'Camera',
                subtitle: 'Take a new photo',
                source: ImageSource.camera,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        barrierDismissible: true,
      );

      if (result != null) {

        final XFile? pickedFile = await _picker.pickImage(
          source: result,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 80,
        );

        if (pickedFile != null) {
          final file = File(pickedFile.path);
          final validationError = await validateImageFile(file);

          if (validationError != null) {
            Helpers.showErrorSnackbar(validationError);
            return null;
          }

          return file;
        } else {
        }
      } else {
      }
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to pick image: ${e.toString()}');
    }

    return null;
  }

  // مساعد لبناء خيارات مصدر الصورة
  static Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required ImageSource source,
  }) {
    return InkWell(
      onTap: () => Get.back(result: source),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.orange, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
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

  // Convert file to base64 string
  static Future<String?> fileToBase64(File file) async {
    try {
      final validationError = await validateImageFile(file);
      if (validationError != null) {
        Helpers.showErrorSnackbar(validationError);
        return null;
      }

      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to process image: ${e.toString()}');
      return null;
    }
  }

  // Delete image file
  static Future<bool> deleteImageFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // دوال مساعدة:

  // التحقق من صحة امتداد الصورة
  static bool isValidImageExtension(String filePath) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = filePath.split('.').last.toLowerCase();
    return validExtensions.contains(extension);
  }

  // حجم الملف بالـ MB
  static Future<double> getFileSizeInMB(File file) async {
    final bytes = await file.length();
    return bytes / (1024 * 1024);
  }

  // التحقق من حجم الملف
  static Future<bool> isValidFileSize(File file, {double maxSizeMB = 5.0}) async {
    final sizeMB = await getFileSizeInMB(file);
    return sizeMB <= maxSizeMB;
  }

  // معلومات الصورة
  static Future<Map<String, dynamic>> getImageInfo(File file) async {
    try {
      final size = await file.length();
      final sizeMB = size / (1024 * 1024);
      final extension = file.path.split('.').last.toLowerCase();

      return {
        'path': file.path,
        'size_bytes': size,
        'size_mb': double.parse(sizeMB.toStringAsFixed(2)),
        'extension': extension,
        'is_valid_extension': isValidImageExtension(file.path),
        'is_valid_size': sizeMB <= 5.0,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}