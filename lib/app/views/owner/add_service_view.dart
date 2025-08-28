import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import '../../controllers/service_controller.dart';
import '../../controllers/workshop_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../data/models/service_model.dart';
import '../../utils/image_service.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class AddServiceView extends StatefulWidget {
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
        title: Text('Add Service'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create New Service',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),

              _buildWorkshopDropdown(),
              SizedBox(height: 16),

              CustomTextField(
                controller: _titleController,
                labelText: 'Service Title',
                prefixIcon: Icons.build,
                validator: Validators.validateServiceTitle,
              ),
              SizedBox(height: 16),

              _buildServiceTypeDropdown(),
              SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: Validators.validateDescription,
              ),
              SizedBox(height: 16),

              CustomTextField(
                controller: _priceController,
                labelText: 'Price (\$)',
                prefixIcon: Icons.attach_money,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: Validators.validatePrice,
              ),
              SizedBox(height: 24),

              _buildImagesSection(),
              SizedBox(height: 32),

              Obx(() => CustomButton(
                text: 'Create Service',
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
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You need to create a workshop first before adding services.',
                  style: TextStyle(color: Colors.orange.shade700),
                ),
              ),
            ],
          ),
        );
      }

      return DropdownButtonFormField<String>(
        value: _selectedWorkshopId,
        decoration: InputDecoration(
          labelText: 'Select Workshop',
          prefixIcon: Icon(Icons.business),
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
            return 'Please select a workshop';
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
        labelText: 'Service Type',
        prefixIcon: Icon(Icons.category),
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
          'Service Images',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
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
                SizedBox(height: 8),
                Text(
                  'Add Images',
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
          SizedBox(height: 16),
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 100,
                  margin: EdgeInsets.only(right: 8),
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
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
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
        'Error',
        'Please select a workshop',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
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
        'Success',
        'Service created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      );

      // إعادة تعيين الحقول
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
        'Error',
        'Failed to create service',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
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
