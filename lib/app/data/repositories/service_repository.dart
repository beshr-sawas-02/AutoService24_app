// ignore_for_file: avoid_print

import '../providers/api_provider.dart';
import '../models/service_model.dart';
import '../models/saved_service_model.dart';
import '../../utils/storage_service.dart';
import 'dart:io';

class ServiceRepository {
  final ApiProvider _apiProvider;

  ServiceRepository(this._apiProvider);

  // ============== Helper Methods ==============

  /// معالجة الـ Response سواء كان Map أو List
  List<dynamic> _extractServiceList(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      final possibleKeys = ['data', 'services', 'items', 'results'];

      for (String key in possibleKeys) {
        if (responseData.containsKey(key) && responseData[key] is List) {
          return responseData[key] as List<dynamic>;
        }
      }

      throw Exception('Could not find services list in response');
    } else if (responseData is List) {
      return responseData;
    }

    throw Exception(
      'Expected list or paginated response but got ${responseData.runtimeType}',
    );
  }

  /// تحويل قائمة JSON إلى قائمة ServiceModel مع معالجة الأخطاء
  List<ServiceModel> _parseServices(List<dynamic> serviceList) {
    List<ServiceModel> services = [];

    for (int i = 0; i < serviceList.length; i++) {
      try {
        final service = ServiceModel.fromJson(serviceList[i]);
        services.add(service);
      } catch (e) {
        print('❌ Error parsing service at index $i: $e');
        continue;
      }
    }

    return services;
  }

  // ============== Get All Services ==============

  /// الحصول على جميع الخدمات مع الـ Pagination
  Future<List<ServiceModel>> getAllServices({
    String? serviceType,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      // التحقق من صحة المعاملات
      if (skip < 0) skip = 0;
      if (limit < 1) limit = 10;
      if (limit > 100) limit = 100;

      print(
          '📡 API Request: skip=$skip, limit=$limit, serviceType=$serviceType');

      final response = await _apiProvider.getServices(
        serviceType: serviceType,
        skip: skip,
        limit: limit,
      );

      print('📥 API Response: ${response.data.runtimeType}');
      print('📦 Response Data: ${response.data}');

      final serviceList = _extractServiceList(response.data);
      print('✅ Extracted ${serviceList.length} services');

      final services = _parseServices(serviceList);
      print('✅ Parsed ${services.length} ServiceModel objects');

      return services;
    } catch (e) {
      print('❌ getAllServices Error: $e');
      throw Exception('Failed to get services: ${e.toString()}');
    }
  }

  /// الحصول على خدمة واحدة بـ ID
  Future<ServiceModel> getServiceById(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Service ID cannot be empty');
      }

      final response = await _apiProvider.getService(id);

      if (response.data == null) {
        throw Exception('Service not found');
      }

      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get service: ${e.toString()}');
    }
  }

  // ============== Search Services ==============

  /// البحث عن الخدمات مع الـ Pagination
  Future<List<ServiceModel>> searchServices(
    String query, {
    String? serviceType,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      // التحقق من صحة البحث
      if (query.trim().isEmpty) {
        throw Exception('Search query cannot be empty');
      }

      if (skip < 0) skip = 0;
      if (limit < 1) limit = 10;
      if (limit > 100) limit = 100;

      final response = await _apiProvider.searchServices(
        query.trim(),
        serviceType: serviceType,
        skip: skip,
        limit: limit,
      );

      final serviceList = _extractServiceList(response.data);
      return _parseServices(serviceList);
    } catch (e) {
      throw Exception('Failed to search services: ${e.toString()}');
    }
  }

  /// الحصول على أنواع الخدمات
  Future<List<String>> getServiceTypes() async {
    try {
      final response = await _apiProvider.getServiceTypes();

      if (response.data is! List) {
        throw Exception('Expected list of service types');
      }

      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get service types: ${e.toString()}');
    }
  }

  // ============== Create Service ==============

  /// إنشاء خدمة جديدة بدون صور
  Future<ServiceModel> createService(
    Map<String, dynamic> serviceData,
  ) async {
    try {
      if (serviceData.isEmpty) {
        throw Exception('Service data cannot be empty');
      }

      final response = await _apiProvider.createService(serviceData);

      if (response.data == null) {
        throw Exception('Failed to create service');
      }

      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create service: ${e.toString()}');
    }
  }

  /// إنشاء خدمة جديدة مع صور
  Future<ServiceModel> createServiceWithImages(
    Map<String, dynamic> serviceData,
    List<File>? imageFiles,
  ) async {
    try {
      if (serviceData.isEmpty) {
        throw Exception('Service data cannot be empty');
      }

      if (imageFiles != null && imageFiles.isNotEmpty) {
        // التحقق من وجود الملفات
        for (var file in imageFiles) {
          if (!await file.exists()) {
            throw Exception('Image file does not exist: ${file.path}');
          }
        }
      }

      final response = await _apiProvider.createServiceWithImages(
        serviceData,
        imageFiles,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Service creation failed with status ${response.statusCode}');
      }

      if (response.data == null) {
        throw Exception('Failed to create service');
      }

      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create service: ${e.toString()}');
    }
  }

  // ============== Upload Images ==============

  /// رفع صور للخدمة الموجودة
  Future<Map<String, dynamic>> uploadServiceImages(
    String serviceId,
    List<File> imageFiles,
  ) async {
    try {
      if (serviceId.isEmpty) {
        throw Exception('Service ID cannot be empty');
      }

      if (imageFiles.isEmpty) {
        throw Exception('No image files provided');
      }

      // التحقق من وجود الملفات
      for (var file in imageFiles) {
        if (!await file.exists()) {
          throw Exception('Image file does not exist: ${file.path}');
        }
      }

      final response = await _apiProvider.uploadServiceImages(
        serviceId,
        imageFiles,
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Upload failed with status ${response.statusCode}');
      }

      if (response.data is! Map<String, dynamic>) {
        throw Exception('Unexpected response format');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to upload images: ${e.toString()}');
    }
  }

  // ============== Update Service ==============

  /// تحديث الخدمة
  Future<ServiceModel> updateService(
    String id,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      if (id.isEmpty) {
        throw Exception('Service ID cannot be empty');
      }

      if (serviceData.isEmpty) {
        throw Exception('Service data cannot be empty');
      }

      final response = await _apiProvider.updateService(id, serviceData);

      if (response.data == null) {
        throw Exception('Failed to update service');
      }

      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  // ============== Delete Service ==============

  /// حذف الخدمة
  Future<void> deleteService(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Service ID cannot be empty');
      }

      await _apiProvider.deleteService(id);
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }

  // ============== Saved Services ==============

  /// حفظ الخدمة
  Future<SavedServiceModel> saveService(
    Map<String, dynamic> data,
  ) async {
    try {
      if (data.isEmpty) {
        throw Exception('Save data cannot be empty');
      }

      if (!data.containsKey('user_id') || !data.containsKey('service_id')) {
        throw Exception('user_id and service_id are required');
      }

      final response = await _apiProvider.saveService(data);

      if (response.data == null) {
        throw Exception('Failed to save service');
      }

      return SavedServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save service: ${e.toString()}');
    }
  }

  /// الحصول على الخدمات المحفوظة
  Future<List<SavedServiceModel>> getSavedServices() async {
    try {
      final currentUserId = await StorageService.getUserId();

      if (currentUserId == null || currentUserId.isEmpty) {
        return [];
      }

      final response = await _apiProvider.getSavedServices();

      if (response.data == null || response.data == []) {
        return [];
      }

      final serviceList = _extractServiceList(response.data);

      // فلترة الخدمات المحفوظة للمستخدم الحالي فقط
      final userSavedServices = serviceList.where((json) {
        try {
          String? userId;

          if (json['user_id'] is Map<String, dynamic>) {
            final userObject = json['user_id'] as Map<String, dynamic>;
            userId = userObject['_id']?.toString();
          } else if (json['user_id'] is String) {
            userId = json['user_id'] as String;
          } else {
            userId = json['userId']?.toString() ??
                json['user']?.toString() ??
                json['owner_id']?.toString();
          }

          return userId == currentUserId;
        } catch (e) {
          return false;
        }
      }).toList();

      return userSavedServices
          .map((json) => SavedServiceModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get saved services: ${e.toString()}');
    }
  }

  /// حذف الخدمة المحفوظة
  Future<void> unsaveService(String id) async {
    try {
      if (id.isEmpty) {
        throw Exception('Saved service ID cannot be empty');
      }

      await _apiProvider.unsaveService(id);
    } catch (e) {
      throw Exception('Failed to unsave service: ${e.toString()}');
    }
  }

  // ============== Helper Queries ==============

  /// ✅ الحصول على خدمات الورشة حسب المعرّف
  Future<List<ServiceModel>> getServicesByWorkshopId(
    String workshopId,
  ) async {
    try {
      if (workshopId.isEmpty) {
        throw Exception('Workshop ID cannot be empty');
      }

      print('🔵 getServicesByWorkshopId: Workshop ID = $workshopId');

      // جلب جميع الخدمات وتصفيتها حسب الورشة
      print('🟡 Fetching all services to filter by workshop...');
      final allServices = await getAllServices(limit: 100);

      print('📊 Total services fetched: ${allServices.length}');

      final filteredServices = allServices.where((service) {
        final matches = service.workshopId == workshopId;
        print('   Service: ${service.id}');
        print('      - workshopId: ${service.workshopId}');
        print('      - looking for: $workshopId');
        print('      - matches: $matches');
        return matches;
      }).toList();

      print(
          '✅ Filtered to ${filteredServices.length} services for workshop $workshopId');
      return filteredServices;
    } catch (e) {
      print('❌ getServicesByWorkshopId Error: $e');
      throw Exception('Failed to get workshop services: ${e.toString()}');
    }
  }

  /// الحصول على رقم هاتف صاحب الورشة
  Future<String?> getWorkshopOwnerPhone(String serviceId) async {
    try {
      if (serviceId.isEmpty) {
        throw Exception('Service ID cannot be empty');
      }

      final response = await _apiProvider.getWorkshopOwnerPhone(serviceId);

      if (response.data == null) {
        return null;
      }

      if (response.data is Map<String, dynamic>) {
        final phone = response.data['phone'];

        if (phone != null && phone is String && phone.isNotEmpty) {
          return phone;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get owner phone: ${e.toString()}');
    }
  }

  // ============== Debug ==============

  /// Debug: الحصول على البيانات الخام للخدمات المحفوظة
  Future<Map<String, dynamic>> debugGetSavedServicesRaw() async {
    try {
      final currentUserId = await StorageService.getUserId();
      final response = await _apiProvider.getSavedServices();

      return {
        'currentUserId': currentUserId,
        'rawResponse': response.data,
        'responseType': response.data.runtimeType.toString(),
        'statusCode': response.statusCode,
        'timestamp': DateTime.now().toString(),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'currentUserId': await StorageService.getUserId(),
        'timestamp': DateTime.now().toString(),
      };
    }
  }
}
