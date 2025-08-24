import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'helpers.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

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
        if (await _validateImage(file)) {
          return file;
        }
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
        if (await _validateImage(file)) {
          return file;
        }
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
      for (XFile image in images) {
        final file = File(image.path);
        if (await _validateImage(file)) {
          validFiles.add(file);
        }
      }

      return validFiles;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to pick images: ${e.toString()}');
      return [];
    }
  }

  // Show image source selection dialog
  static Future<File?> showImageSourceDialog() async {
    File? selectedImage;

    await Get.dialog(
      AlertDialog(
        title: Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo_library, color: Colors.blue),
              title: Text('Gallery'),
              onTap: () async {
                Get.back();
                selectedImage = await pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.green),
              title: Text('Camera'),
              onTap: () async {
                Get.back();
                selectedImage = await pickImageFromCamera();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );

    return selectedImage;
  }

  // Validate image file
  static Future<bool> _validateImage(File file) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        Helpers.showErrorSnackbar('Image file not found');
        return false;
      }

      // Check file size (max 5MB)
      final fileSize = await file.length();
      const maxSizeInBytes = 5 * 1024 * 1024; // 5MB

      if (fileSize > maxSizeInBytes) {
        Helpers.showErrorSnackbar('Image size must be less than 5MB');
        return false;
      }

      // Check file extension
      final fileName = file.path.toLowerCase();
      final allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif'];

      bool hasValidExtension = allowedExtensions.any(
              (ext) => fileName.endsWith(ext)
      );

      if (!hasValidExtension) {
        Helpers.showErrorSnackbar('Please select a valid image file (JPG, PNG, GIF)');
        return false;
      }

      return true;
    } catch (e) {
      Helpers.showErrorSnackbar('Image validation failed: ${e.toString()}');
      return false;
    }
  }

  // Convert file to base64 string
  static Future<String?> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to process image: ${e.toString()}');
      return null;
    }
  }

  // Save image to device storage
  static Future<String?> saveImageToDevice(File file, String fileName) async {
    try {
      // This would typically use path_provider to get app directory
      // For now, return the current path
      return file.path;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to save image: ${e.toString()}');
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
      Helpers.showErrorSnackbar('Failed to delete image: ${e.toString()}');
      return false;
    }
  }

  // Compress image
  static Future<File?> compressImage(File file, {int quality = 80}) async {
    try {
      // This is a simplified version
      // In a real app, you might use packages like flutter_image_compress
      return file;
    } catch (e) {
      Helpers.showErrorSnackbar('Failed to compress image: ${e.toString()}');
      return null;
    }
  }
}

