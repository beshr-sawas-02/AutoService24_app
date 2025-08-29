import '../providers/api_provider.dart';
import '../models/service_model.dart';
import '../models/saved_service_model.dart';
import '../../utils/storage_service.dart';
import 'dart:io';

class ServiceRepository {
  final ApiProvider _apiProvider;

  ServiceRepository(this._apiProvider);

  Future<List<ServiceModel>> getAllServices({String? serviceType}) async {
    try {
      final response = await _apiProvider.getServices(serviceType: serviceType);
      // Check if response.data is a List
      if (response.data is! List) {
        throw Exception('Expected list of services but got ${response.data.runtimeType}');
      }

      final List<dynamic> serviceList = response.data;
      // Process each service with error handling
      List<ServiceModel> services = [];
      for (int i = 0; i < serviceList.length; i++) {
        try {
          final service = ServiceModel.fromJson(serviceList[i]);
          services.add(service);
        } catch (e) {
          // Continue processing other services instead of failing completely
          continue;
        }
      }

      return services;

    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    try {

      final response = await _apiProvider.getService(id);

      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get service: ${e.toString()}');
    }
  }

  Future<List<ServiceModel>> searchServices(String query, {String? serviceType}) async {
    try {

      final response = await _apiProvider.searchServices(query, serviceType: serviceType);

      if (response.data is! List) {
        throw Exception('Expected list of services but got ${response.data.runtimeType}');
      }

      final List<dynamic> serviceList = response.data;

      List<ServiceModel> services = [];
      for (int i = 0; i < serviceList.length; i++) {
        try {
          services.add(ServiceModel.fromJson(serviceList[i]));
        } catch (e) {
          continue;
        }
      }

      return services;
    } catch (e) {
      throw Exception('Failed to search services: ${e.toString()}');
    }
  }

  Future<List<String>> getServiceTypes() async {
    try {
      final response = await _apiProvider.getServiceTypes();
      return List<String>.from(response.data);
    } catch (e) {
      throw Exception('Failed to get service types: ${e.toString()}');
    }
  }

  Future<ServiceModel> createService(Map<String, dynamic> serviceData) async {
    try {
      final response = await _apiProvider.createService(serviceData);
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create service: ${e.toString()}');
    }
  }

  Future<ServiceModel> createServiceWithImages(Map<String, dynamic> serviceData, List<File>? imageFiles) async {
    try {
      print("ServiceRepository: createServiceWithImages called");

      final response = await _apiProvider.createServiceWithImages(serviceData, imageFiles);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ServiceModel.fromJson(response.data);
      } else {
        throw Exception('Service creation failed with status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> uploadServiceImages(String serviceId, List<File> imageFiles) async {
    try {
      final response = await _apiProvider.uploadServiceImages(serviceId, imageFiles);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Image upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<ServiceModel> updateService(String id, Map<String, dynamic> serviceData) async {
    try {
      final response = await _apiProvider.updateService(id, serviceData);
      return ServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update service: ${e.toString()}');
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _apiProvider.deleteService(id);
    } catch (e) {
      throw Exception('Failed to delete service: ${e.toString()}');
    }
  }

  // Saved services
  Future<SavedServiceModel> saveService(Map<String, dynamic> data) async {
    try {
      final response = await _apiProvider.saveService(data);
      return SavedServiceModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to save service: ${e.toString()}');
    }
  }

  Future<List<SavedServiceModel>> getSavedServices() async {
    try {
      // الحصول على معرف المستخدم الحالي
      final currentUserId = await StorageService.getUserId();
      if (currentUserId == null) {
        return [];
      }
      final response = await _apiProvider.getSavedServices();

      // تحقق من نوع الـ response
      if (response.data is! List) {
        // إذا كان Response empty أو null
        if (response.data == null || response.data == []) {
          return [];
        }

        // إذا كان Response Map يحتوي على List داخلي
        if (response.data is Map<String, dynamic>) {
          final Map<String, dynamic> responseMap = response.data;

          // ابحث عن keys مثل 'data', 'savedServices', 'services', etc.
          final possibleKeys = ['data', 'savedServices', 'services', 'items', 'results'];

          for (String key in possibleKeys) {
            if (responseMap.containsKey(key) && responseMap[key] is List) {
              final List<dynamic> savedList = responseMap[key];

              // فلترة النتائج حسب المستخدم الحالي
              final userSavedServices = savedList.where((json) {
                final userId = json['user_id']?.toString() ?? json['userId']?.toString();
                return userId == currentUserId;
              }).toList();

              return userSavedServices.map((json) => SavedServiceModel.fromJson(json)).toList();
            }
          }

          throw Exception('Could not find saved services list in response Map');
        }

        throw Exception('Expected list of saved services but got ${response.data.runtimeType}');
      }

      final List<dynamic> savedList = response.data;

      // فلترة النتائج حسب المستخدم الحالي
      final userSavedServices = savedList.where((json) {
        try {
          // استخراج معرف المستخدم من الحقول المختلفة
          String? userId;

          // إذا كان user_id عبارة عن Object
          if (json['user_id'] is Map<String, dynamic>) {
            final userObject = json['user_id'] as Map<String, dynamic>;
            userId = userObject['_id']?.toString();
          }
          // إذا كان user_id عبارة عن String
          else if (json['user_id'] is String) {
            userId = json['user_id'] as String;
          }
          // تجربة حقول أخرى
          else {
            userId = json['userId']?.toString() ??
                json['user']?.toString() ??
                json['owner_id']?.toString();
          }

          return userId == currentUserId;
        } catch (e) {
          return false;
        }
      }).toList();


      return userSavedServices.map((json) {
        return SavedServiceModel.fromJson(json);
      }).toList();

    } catch (e) {
      throw Exception('Failed to get saved services: ${e.toString()}');
    }
  }

  Future<void> unsaveService(String id) async {
    try {
      await _apiProvider.unsaveService(id);
    } catch (e) {
      throw Exception('Failed to unsave service: ${e.toString()}');
    }
  }

  Future<List<ServiceModel>> getServicesByWorkshopId(String workshopId) async {
    try {
      final allServices = await getAllServices();
      return allServices.where((service) => service.workshopId == workshopId).toList();
    } catch (e) {
      throw Exception('Failed to get workshop services: ${e.toString()}');
    }
  }

  // دالة debug لطباعة الاستجابة الخام من API
  Future<Map<String, dynamic>> debugGetSavedServicesRaw() async {
    try {
      final currentUserId = await StorageService.getUserId();
      final response = await _apiProvider.getSavedServices();

      return {
        'currentUserId': currentUserId,
        'rawResponse': response.data,
        'responseType': response.data.runtimeType.toString(),
        'statusCode': response.statusCode,
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'currentUserId': await StorageService.getUserId(),
      };
    }
  }
}