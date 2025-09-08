import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../config/app_colors.dart';
import '../../controllers/service_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/service_model.dart';
import '../../utils/image_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddServiceView extends StatefulWidget {
  const AddServiceView({super.key});

  @override
  _AddServiceViewState createState() => _AddServiceViewState();
}

class _AddServiceViewState extends State<AddServiceView> {
  final ServiceController serviceController = Get.find<ServiceController>();
  final WorkshopController workshopController = Get.find<WorkshopController>();
  final AuthController authController = Get.find<AuthController>();

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  ServiceType _selectedServiceType = ServiceType.CHANGE_OIL;
  String? _selectedWorkshopId;
  List<File> _selectedImages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('add_service'.tr),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'create_new_service'.tr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              _buildWorkshopDropdown(),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                labelText: 'service_title'.tr,
                prefixIcon: Icons.build,
                validator: (value) {
                  final result = Validators.validateServiceTitle(value);
                  if (result != null) {
                    return 'please_enter_service_title'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildServiceTypeDropdown(),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'description'.tr,
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  final result = Validators.validateDescription(value);
                  if (result != null) {
                    return 'please_enter_description'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                labelText: 'price_usd'.tr,
                prefixIcon: Icons.euro,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final result = Validators.validatePrice(value);
                  if (result != null) {
                    return 'please_enter_valid_price'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              _buildImagesSection(),
              const SizedBox(height: 32),

              Obx(() => CustomButton(
                text: 'create_service'.tr,
                onPressed: serviceController.isLoading.value ? null : _createService,
                isLoading: serviceController.isLoading.value,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkshopDropdown() {
    return Obx(() {
      final workshops = workshopController.ownerWorkshops;

      if (workshops.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'create_workshop_first'.tr,
                  style: const TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }

      return DropdownButtonFormField<String>(
        value: _selectedWorkshopId,
        decoration: InputDecoration(
          labelText: 'select_workshop'.tr,
          prefixIcon: const Icon(Icons.business),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: workshops.map((workshop) {
          return DropdownMenuItem(
            value: workshop.id,
            child: Text(workshop.name),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedWorkshopId = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'please_select_workshop'.tr;
          }
          return null;
        },
      );
    });
  }

  Widget _buildServiceTypeDropdown() {
    return DropdownButtonFormField<ServiceType>(
      value: _selectedServiceType,
      decoration: InputDecoration(
        labelText: 'service_type'.tr,
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      items: ServiceType.values.map((type) {
        return DropdownMenuItem(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedServiceType = value;
          });
        }
      },
    );
  }

  Widget _buildImagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'service_images'.tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: _addImage,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate,
                  size: 40,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  'add_images'.tr,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addImage() async {
    final images = await ImageService.pickMultipleImages(maxImages: 5);
    setState(() {
      _selectedImages.addAll(images);
      if (_selectedImages.length > 5) {
        _selectedImages = _selectedImages.take(5).toList();
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _createService() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedWorkshopId == null) {
      Get.snackbar(
        'error'.tr,
        'please_select_workshop'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      return;
    }

    List<String> imageUrls = _selectedImages.map((e) => e.path).toList();

    final serviceData = {
      'workshop_id': _selectedWorkshopId,
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'price': double.parse(_priceController.text),
      'service_type': _selectedServiceType.displayName,
      'images': imageUrls,
    };

    final success = await serviceController.createService(serviceData);

    if (success) {
      Get.snackbar(
        'success'.tr,
        'service_created_successfully'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );

      _formKey.currentState!.reset();
      _titleController.clear();
      _descriptionController.clear();
      _priceController.clear();
      setState(() {
        _selectedServiceType = ServiceType.CHANGE_OIL;
        _selectedWorkshopId = null;
        _selectedImages.clear();
      });

    } else {
      Get.snackbar(
        'error'.tr,
        'failed_create_service'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}