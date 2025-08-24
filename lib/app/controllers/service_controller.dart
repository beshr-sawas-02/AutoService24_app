import 'package:get/get.dart';
import '../data/repositories/service_repository.dart';
import '../data/models/service_model.dart';
import '../data/models/saved_service_model.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';

class ServiceController extends GetxController {
  final ServiceRepository _serviceRepository;

  ServiceController(this._serviceRepository);

  var isLoading = false.obs;
  var services = <ServiceModel>[].obs;
  var ownerServices = <ServiceModel>[].obs;
  var savedServices = <SavedServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var selectedType = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadServices();
  }

  Future<void> loadServices({String? serviceType}) async {
    try {
      isLoading.value = true;

      final serviceList = await _serviceRepository.getAllServices(serviceType: serviceType);
      services.value = serviceList;
      _applyFilters();
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final response = await _serviceRepository.getServiceById(serviceId);
      return response;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return null;
    }
  }

  Future<void> loadOwnerServices() async {
    try {
      isLoading.value = true;

      final serviceList = await _serviceRepository.getAllServices();
      ownerServices.value = serviceList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSavedServices() async {
    try {
      isLoading.value = true;

      final savedList = await _serviceRepository.getSavedServices();
      savedServices.value = savedList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchServices(String query) async {
    if (query.isEmpty) {
      loadServices();
      return;
    }

    try {
      isLoading.value = true;

      final searchResults = await _serviceRepository.searchServices(
        query,
        serviceType: selectedType.value,
      );
      services.value = searchResults;
      _applyFilters();
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void filterByType(String? type) {
    selectedType.value = type;
    loadServices(serviceType: type);
  }

  void _applyFilters() {
    filteredServices.value = services.toList();
  }

  Future<bool> saveService(String serviceId, String userId) async {
    try {
      await _serviceRepository.saveService({
        'user_id': userId,
        'service_id': serviceId,
      });

      Helpers.showSuccessSnackbar('Service saved successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> unsaveService(String savedServiceId) async {
    try {
      await _serviceRepository.unsaveService(savedServiceId);

      savedServices.removeWhere((service) => service.id == savedServiceId);
      Helpers.showSuccessSnackbar('Service removed from saved');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;

      final newService = await _serviceRepository.createService(serviceData);
      ownerServices.add(newService);

      Helpers.showSuccessSnackbar('Service created successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateService(String id, Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;

      final updatedService = await _serviceRepository.updateService(id, serviceData);
      final index = ownerServices.indexWhere((s) => s.id == id);
      if (index != -1) {
        ownerServices[index] = updatedService;
      }

      Helpers.showSuccessSnackbar('Service updated successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteService(String id) async {
    try {
      await _serviceRepository.deleteService(id);

      ownerServices.removeWhere((service) => service.id == id);
      Helpers.showSuccessSnackbar('Service deleted successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }
}