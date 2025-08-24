import '../providers/api_provider.dart';
import '../models/service_model.dart';
import '../models/saved_service_model.dart';

class ServiceRepository {
  final ApiProvider _apiProvider;

  ServiceRepository(this._apiProvider);

  Future<List<ServiceModel>> getAllServices({String? serviceType}) async {
    try {
      final response = await _apiProvider.getServices(serviceType: serviceType);
      final List<dynamic> serviceList = response.data;
      return serviceList.map((json) => ServiceModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get services: ${e.toString()}');
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
      final List<dynamic> serviceList = response.data;
      return serviceList.map((json) => ServiceModel.fromJson(json)).toList();
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
      final response = await _apiProvider.getSavedServices();
      final List<dynamic> savedList = response.data;
      return savedList.map((json) => SavedServiceModel.fromJson(json)).toList();
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
}