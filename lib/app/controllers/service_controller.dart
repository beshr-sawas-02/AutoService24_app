import 'package:get/get.dart';
import 'dart:io';
import '../data/repositories/service_repository.dart';
import '../data/models/service_model.dart';
import '../data/models/saved_service_model.dart';
import '../utils/error_handler.dart';
import '../utils/storage_service.dart';

class ServiceController extends GetxController {
  final ServiceRepository _serviceRepository;

  ServiceController(this._serviceRepository);

  var isLoading = false.obs;
  var isLoadingPhone = false.obs;
  var services = <ServiceModel>[].obs;
  var ownerServices = <ServiceModel>[].obs;
  var savedServices = <SavedServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var selectedType = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration.zero, () {
      loadServices();
      loadSavedServices();
    });
  }

  // Helper method to sort services by creation date (newest first)
  void _sortServicesByDate(List<ServiceModel> serviceList) {
    serviceList.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(2000);
      final dateB = b.createdAt ?? DateTime(2000);
      return dateB.compareTo(dateA); // Descending order (newest first)
    });
  }

  Future<void> loadServices({String? serviceType}) async {
    try {
      isLoading.value = true;
      final serviceList =
          await _serviceRepository.getAllServices(serviceType: serviceType);

      // Sort services by creation date
      _sortServicesByDate(serviceList);

      services.value = serviceList;
      _applyFilters();
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      services.clear();
      filteredServices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<ServiceModel?> getServiceById(String serviceId) async {
    try {
      final response = await _serviceRepository.getServiceById(serviceId);
      return response;
    } catch (e) {
      if (e.toString().contains('404') ||
          e.toString().contains('not found') ||
          e.toString().contains('Not Found')) {
        return null;
      }

      ErrorHandler.handleAndShowError(e, silent: true);
      return null;
    }
  }

  Future<void> loadOwnerServices() async {
    try {
      isLoading.value = true;

      final serviceList = await _serviceRepository.getAllServices();

      // Sort services by creation date
      _sortServicesByDate(serviceList);

      ownerServices.value = serviceList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      ownerServices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSavedServices() async {
    try {
      final currentUserId = await StorageService.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        return;
      }
      final savedList = await _serviceRepository.getSavedServices();
      savedServices.value = savedList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
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

      // Sort search results by creation date
      _sortServicesByDate(searchResults);

      services.value = searchResults;
      _applyFilters();
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      services.clear();
      filteredServices.clear();
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

  bool isServiceSaved(String serviceId) {
    return savedServices.any((saved) => saved.serviceId == serviceId);
  }

  String? getSavedServiceId(String serviceId) {
    final saved =
        savedServices.firstWhereOrNull((s) => s.serviceId == serviceId);
    return saved?.id;
  }

  Future<bool> saveService(String serviceId, String userId) async {
    try {
      if (isServiceSaved(serviceId)) {
        ErrorHandler.showInfo('service_already_saved'.tr);
        return true;
      }

      final savedService = await _serviceRepository.saveService({
        'user_id': userId,
        'service_id': serviceId,
      });

      savedServices.add(savedService);
      ErrorHandler.showSuccess('service_saved_successfully'.tr);
      return true;
    } catch (e) {
      if (e.toString().contains('already saved') ||
          e.toString().contains('already exists') ||
          e.toString().contains('duplicate')) {
        ErrorHandler.showInfo('service_already_in_list'.tr);

        loadSavedServices();
        return true;
      }

      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> unSaveService(String savedServiceId) async {
    try {
      await _serviceRepository.unsaveService(savedServiceId);

      savedServices.removeWhere((service) => service.id == savedServiceId);
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> toggleSaveService(String serviceId, String userId) async {
    if (isServiceSaved(serviceId)) {
      final savedServiceId = getSavedServiceId(serviceId);
      if (savedServiceId != null) {
        return await unSaveService(savedServiceId);
      }
      return false;
    } else {
      return await saveService(serviceId, userId);
    }
  }

  void clearAllData() {
    services.clear();
    ownerServices.clear();
    savedServices.clear();
    filteredServices.clear();
    selectedType.value = null;
  }

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;

      final newService = await _serviceRepository.createService(serviceData);

      // Add new service at the beginning (top)
      ownerServices.insert(0, newService);
      services.insert(0, newService);

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createServiceWithImages(
      Map<String, dynamic> serviceData, List<File>? imageFiles) async {
    try {
      isLoading.value = true;

      final newService = await _serviceRepository.createServiceWithImages(
          serviceData, imageFiles);

      // Add new service at the beginning (top)
      ownerServices.insert(0, newService);
      services.insert(0, newService);

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadServiceImages(
      String serviceId, List<File> imageFiles) async {
    try {
      isLoading.value = true;

      final response =
          await _serviceRepository.uploadServiceImages(serviceId, imageFiles);

      final index = ownerServices.indexWhere((s) => s.id == serviceId);
      if (index != -1 && response.containsKey('service')) {
        ownerServices[index] = ServiceModel.fromJson(response['service']);
      }

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateService(
      String id, Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;

      final updatedService =
          await _serviceRepository.updateService(id, serviceData);
      final index = ownerServices.indexWhere((s) => s.id == id);
      if (index != -1) {
        ownerServices[index] = updatedService;
      }

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
      isLoading.value = true;

      await _serviceRepository.deleteService(id);

      ownerServices.removeWhere((service) => service.id == id);
      services.removeWhere((service) => service.id == id);

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> debugSavedServices() async {
    try {
      await StorageService.debugPrintStoredData();

      final debugData = await _serviceRepository.debugGetSavedServicesRaw();

      if (debugData['rawResponse'] is List) {
        final List<dynamic> rawList = debugData['rawResponse'];

        for (int i = 0; i < rawList.length; i++) {
          final item = rawList[i];

          final possibleUserFields = [
            'user_id',
            'userId',
            'user',
            'owner_id',
            'ownerId',
          ];

          for (String field in possibleUserFields) {
            if (item.containsKey(field)) {}
          }
        }
      }
    } catch (e) {
      // Debug errors are silent - only logged in console
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<void> loadServicesByWorkshopId(String workshopId) async {
    try {
      isLoading.value = true;

      final serviceList =
          await _serviceRepository.getServicesByWorkshopId(workshopId);

      // Sort services by creation date
      _sortServicesByDate(serviceList);

      ownerServices.value = serviceList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      ownerServices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  Future<String?> getWorkshopOwnerPhone(String serviceId) async {
    try {
      isLoadingPhone.value = true;

      final phoneNumber =
          await _serviceRepository.getWorkshopOwnerPhone(serviceId);
      return phoneNumber;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return null;
    } finally {
      isLoadingPhone.value = false;
    }
  }
}
