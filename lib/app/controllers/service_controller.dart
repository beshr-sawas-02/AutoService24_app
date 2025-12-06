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

  // Loading states
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isLoadingPhone = false.obs;

  // Services lists
  var services = <ServiceModel>[].obs;
  var ownerServices = <ServiceModel>[].obs;
  var savedServices = <SavedServiceModel>[].obs;
  var filteredServices = <ServiceModel>[].obs;
  var selectedType = Rx<String?>(null);

  // Pagination variables
  var currentSkip = 0.obs;
  static const int pageSize = 10;
  var hasMoreServices = true.obs;
  var hasMoreOwnerServices = true.obs;

  // Search pagination
  var searchSkip = 0.obs;
  var hasMoreSearchResults = true.obs;
  var lastSearchQuery = ''.obs;

  // ✅ تتبع النوع الحالي
  var currentServiceType = Rx<String?>(null);

  // ✅ متغير جديد لتخزين آخر workshopId تم تحميل خدماته
  var lastLoadedWorkshopId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    Future.delayed(Duration.zero, () {
      loadSavedServices();
    });
  }

  // ============== Helper Methods ==============

  void _sortServicesByDate(List<ServiceModel> serviceList) {
    serviceList.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(2000);
      final dateB = b.createdAt ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });
  }

  bool _isValidServiceList(List<ServiceModel> services) {
    return services.isNotEmpty;
  }

  void _updateHasMore(
    List<ServiceModel> newServices,
    bool isOwner,
  ) {
    if (newServices.length < pageSize) {
      if (isOwner) {
        hasMoreOwnerServices.value = false;
      } else {
        hasMoreServices.value = false;
      }
    }
  }

  // ============== Load Services ==============

  Future<void> loadServices({String? serviceType}) async {
    try {
      isLoading.value = true;
      currentSkip.value = 0;
      currentServiceType.value = serviceType;
      hasMoreServices.value = true;
      lastSearchQuery.value = '';

      print('🔵 loadServices: جاري التحميل - serviceType: $serviceType');

      final serviceList = await _serviceRepository.getAllServices(
        serviceType: serviceType,
        skip: 0,
        limit: pageSize,
      );

      print('🟢 loadServices: تم التحميل - عدد الخدمات: ${serviceList.length}');

      _sortServicesByDate(serviceList);
      _updateHasMore(serviceList, false);

      services.value = serviceList;
      print('🟠 services.value: ${services.value.length} خدمة');

      _applyFilters();

      print('🟡 filteredServices.value: ${filteredServices.value.length} خدمة');
    } catch (e) {
      print('🔴 loadServices Error: $e');
      ErrorHandler.handleAndShowError(e);
      services.clear();
      filteredServices.clear();
      hasMoreServices.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreServices({String? serviceType}) async {
    // ✅ Check أقوى للتأكد من عدم التكرار
    if (isLoadingMore.value) {
      print('⚠️ loadMore already in progress');
      return;
    }

    if (!hasMoreServices.value) {
      print('⚠️ No more services available');
      return;
    }

    // ✅ تأكد أن serviceType ما تغيّر أثناء التحميل
    if (currentServiceType.value != serviceType) {
      print('⚠️ Service type changed, skipping load');
      return;
    }

    try {
      isLoadingMore.value = true;
      currentSkip.value += pageSize;

      print('🔵 loadMoreServices: جاري التحميل من skip: ${currentSkip.value}');

      final moreServices = await _serviceRepository.getAllServices(
        serviceType: serviceType,
        skip: currentSkip.value,
        limit: pageSize,
      );

      print(
          '🟢 loadMoreServices: تم التحميل - عدد الخدمات: ${moreServices.length}');

      _sortServicesByDate(moreServices);
      _updateHasMore(moreServices, false);

      services.addAll(moreServices);
      print('🟠 services.value بعد الإضافة: ${services.value.length} خدمة');

      _applyFilters();
    } catch (e) {
      print('🔴 loadMoreServices Error: $e');
      ErrorHandler.handleAndShowError(e, silent: true);
      currentSkip.value -= pageSize; // ⬅️ مهم: إرجاع الـ skip للقيمة السابقة
    } finally {
      isLoadingMore.value = false;
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
      return null;
    }
  }

  // ============== Load Owner Services ==============

  Future<void> loadOwnerServices({String? serviceType}) async {
    try {
      isLoading.value = true;
      currentSkip.value = 0;
      currentServiceType.value = serviceType;
      hasMoreOwnerServices.value = true;

      print('🔵 loadOwnerServices: جاري التحميل - serviceType: $serviceType');

      final serviceList = await _serviceRepository.getAllServices(
        serviceType: serviceType,
        skip: 0,
        limit: pageSize,
      );

      print(
          '🟢 loadOwnerServices: تم التحميل - عدد الخدمات: ${serviceList.length}');

      _sortServicesByDate(serviceList);
      _updateHasMore(serviceList, true);

      ownerServices.value = serviceList;
      print('🟠 ownerServices.value: ${ownerServices.value.length} خدمة');
    } catch (e) {
      print('🔴 loadOwnerServices Error: $e');
      ErrorHandler.handleAndShowError(e);
      ownerServices.clear();
      hasMoreOwnerServices.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreOwnerServices({String? serviceType}) async {
    if (isLoadingMore.value || !hasMoreOwnerServices.value) {
      print(
          '⚠️ Cannot load more - isLoading: ${isLoadingMore.value}, hasMore: ${hasMoreOwnerServices.value}');
      return;
    }

    // ✅ تحقق من النوع
    if (currentServiceType.value != serviceType) {
      print('⚠️ Service type changed, skipping load');
      return;
    }

    try {
      isLoadingMore.value = true;
      currentSkip.value += pageSize;

      print(
          '🔵 loadMoreOwnerServices: جاري التحميل من skip: ${currentSkip.value}');

      final moreServices = await _serviceRepository.getAllServices(
        serviceType: serviceType,
        skip: currentSkip.value,
        limit: pageSize,
      );

      print(
          '🟢 loadMoreOwnerServices: تم التحميل - عدد الخدمات: ${moreServices.length}');

      _sortServicesByDate(moreServices);
      _updateHasMore(moreServices, true);

      ownerServices.addAll(moreServices);
      print('🟠 ownerServices بعد الإضافة: ${ownerServices.value.length} خدمة');
    } catch (e) {
      print('🔴 loadMoreOwnerServices Error: $e');
      ErrorHandler.handleAndShowError(e, silent: true);
      currentSkip.value -= pageSize;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ============== Saved Services ==============

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

  // ============== Search ==============

  Future<void> searchServices(String query) async {
    if (query.isEmpty) {
      loadServices();
      return;
    }

    try {
      isLoading.value = true;
      searchSkip.value = 0;
      currentSkip.value = 0;
      hasMoreSearchResults.value = true;
      lastSearchQuery.value = query;

      print('🔵 searchServices: جاري البحث - query: $query');

      final searchResults = await _serviceRepository.searchServices(
        query,
        serviceType: selectedType.value,
        skip: 0,
        limit: pageSize,
      );

      _sortServicesByDate(searchResults);

      if (searchResults.length < pageSize) {
        hasMoreSearchResults.value = false;
      }

      services.value = searchResults;
      _applyFilters();

      print('🟢 searchServices: تم البحث - عدد النتائج: ${services.length}');
    } catch (e) {
      print('🔴 searchServices Error: $e');
      ErrorHandler.handleAndShowError(e);
      services.clear();
      filteredServices.clear();
      hasMoreSearchResults.value = false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreSearchResults() async {
    if (isLoadingMore.value || !hasMoreSearchResults.value) {
      return;
    }

    if (lastSearchQuery.value.isEmpty) return;

    try {
      isLoadingMore.value = true;
      searchSkip.value += pageSize;

      print(
          '🔵 loadMoreSearchResults: جاري التحميل من skip: ${searchSkip.value}');

      final moreResults = await _serviceRepository.searchServices(
        lastSearchQuery.value,
        serviceType: selectedType.value,
        skip: searchSkip.value,
        limit: pageSize,
      );

      _sortServicesByDate(moreResults);

      if (moreResults.length < pageSize) {
        hasMoreSearchResults.value = false;
      }

      services.addAll(moreResults);
      _applyFilters();

      print(
          '🟢 loadMoreSearchResults: تم التحميل - عدد النتائج: ${moreResults.length}');
    } catch (e) {
      print('🔴 loadMoreSearchResults Error: $e');
      ErrorHandler.handleAndShowError(e, silent: true);
      searchSkip.value -= pageSize;
    } finally {
      isLoadingMore.value = false;
    }
  }

  // ============== Filter ==============

  void filterByType(String? type) {
    selectedType.value = type;
    loadServices(serviceType: type);
  }

  void _applyFilters() {
    filteredServices.value = services.toList();
  }

  // ============== Save/Unsave Services ==============

  bool isServiceSaved(String serviceId) {
    return savedServices.any((saved) => saved.serviceId == serviceId);
  }

  String? getSavedServiceId(String serviceId) {
    final saved = savedServices.firstWhereOrNull(
      (s) => s.serviceId == serviceId,
    );
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

  // ============== CRUD Operations ==============

  Future<bool> createService(Map<String, dynamic> serviceData) async {
    try {
      isLoading.value = true;

      final newService = await _serviceRepository.createService(serviceData);

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
    Map<String, dynamic> serviceData,
    List<File>? imageFiles,
  ) async {
    try {
      isLoading.value = true;

      final newService = await _serviceRepository.createServiceWithImages(
        serviceData,
        imageFiles,
      );

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
    String serviceId,
    List<File> imageFiles,
  ) async {
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
    String id,
    Map<String, dynamic> serviceData,
  ) async {
    try {
      isLoading.value = true;

      final updatedService =
          await _serviceRepository.updateService(id, serviceData);

      final index = ownerServices.indexWhere((s) => s.id == id);
      if (index != -1) {
        ownerServices[index] = updatedService;
      }

      final serviceIndex = services.indexWhere((s) => s.id == id);
      if (serviceIndex != -1) {
        services[serviceIndex] = updatedService;
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

  // ============== Workshop Operations ==============

  // ✅ عدّل هذا الـ method - حمّل مباشرة في ownerServices
  Future<void> loadServicesByWorkshopId(String workshopId) async {
    try {
      isLoading.value = true;

      print(
          '🔵 loadServicesByWorkshopId: جاري التحميل - workshopId: $workshopId');

      final serviceList =
          await _serviceRepository.getServicesByWorkshopId(workshopId);

      print(
          '🟢 loadServicesByWorkshopId: تم التحميل - عدد: ${serviceList.length}');

      _sortServicesByDate(serviceList);

      // احفظ مباشرة في ownerServices
      ownerServices.value = serviceList;
      lastLoadedWorkshopId.value = workshopId;

      print('🟠 ownerServices.value: ${ownerServices.value.length} خدمة');
    } catch (e) {
      print('🔴 loadServicesByWorkshopId Error: $e');
      ErrorHandler.handleAndShowError(e, silent: true);
      ownerServices.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // ✅ Method جديد - ارجع ownerServices مباشرة بعد التحميل
  Future<List<ServiceModel>> getServicesForWorkshop(String workshopId) async {
    try {
      print('🔵 getServicesForWorkshop: جاري التحميل من API');

      final serviceList =
          await _serviceRepository.getServicesByWorkshopId(workshopId);

      print(
          '🟢 getServicesForWorkshop: تم التحميل - عدد: ${serviceList.length}');

      _sortServicesByDate(serviceList);

      // ارجع البيانات مباشرة
      return serviceList;
    } catch (e) {
      print('❌ getServicesForWorkshop Error: $e');
      ErrorHandler.handleAndShowError(e, silent: true);
      return [];
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

  // ============== Debug ==============

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
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  // ============== Cleanup ==============

  void clearAllData() {
    services.clear();
    ownerServices.clear();
    savedServices.clear();
    filteredServices.clear();
    selectedType.value = null;
    currentServiceType.value = null;
    currentSkip.value = 0;
    searchSkip.value = 0;
    lastSearchQuery.value = '';
    hasMoreServices.value = true;
    hasMoreOwnerServices.value = true;
    hasMoreSearchResults.value = true;
    lastLoadedWorkshopId.value = null;
  }

  @override
  void onClose() {
    clearAllData();
    super.onClose();
  }
}
