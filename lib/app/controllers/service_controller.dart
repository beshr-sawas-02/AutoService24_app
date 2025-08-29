import 'package:get/get.dart';
import 'dart:io';
import '../data/repositories/service_repository.dart';
import '../data/models/service_model.dart';
import '../data/models/saved_service_model.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';
import '../utils/storage_service.dart';

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
    loadSavedServices();
  }

  Future<void> loadServices({String? serviceType}) async {
    try {
      isLoading.value = true;
      final serviceList =
          await _serviceRepository.getAllServices(serviceType: serviceType);
      services.value = serviceList;
      _applyFilters();
    } catch (e) {
      // عرض رسالة خطأ مبسطة للمستخدم
      Helpers.showErrorSnackbar('Unable to load services. Please try again.');
      // مسح الخدمات الحالية عند حدوث خطأ
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
      print("ServiceController: Loading saved services...");

      // التحقق من وجود مستخدم مسجل - لكن لا نمحو البيانات فوراً
      final currentUserId = await StorageService.getUserId();
      if (currentUserId == null || currentUserId.isEmpty) {
        return;
      }
      final savedList = await _serviceRepository.getSavedServices();
      savedServices.value = savedList;
      // طباعة تفاصيل الخدمات المحفوظة للتأكد
      for (int i = 0; i < savedList.length; i++) {
        final saved = savedList[i];
      }
    } catch (e) {
      // لا نمحو savedServices في حالة الخطأ أيضاً
      // savedServices.clear();
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

  // تحقق من كون الخدمة محفوظة أم لا
  bool isServiceSaved(String serviceId) {
    return savedServices.any((saved) => saved.serviceId == serviceId);
  }

  // الحصول على معرف الخدمة المحفوظة
  String? getSavedServiceId(String serviceId) {
    final saved =
        savedServices.firstWhereOrNull((s) => s.serviceId == serviceId);
    return saved?.id;
  }

  Future<bool> saveService(String serviceId, String userId) async {
    try {
      // التحقق من أن الخدمة ليست محفوظة بالفعل محلياً
      if (isServiceSaved(serviceId)) {
        Helpers.showInfoSnackbar('Service is already saved');
        return true;
      }

      final savedService = await _serviceRepository.saveService({
        'user_id': userId,
        'service_id': serviceId,
      });

      // إضافة الخدمة المحفوظة للقائمة المحلية
      savedServices.add(savedService);
      Helpers.showSuccessSnackbar('Service saved successfully');
      return true;
    } catch (e) {
      // فحص إذا كانت المشكلة أن الخدمة محفوظة بالفعل
      if (e.toString().contains('already saved') ||
          e.toString().contains('already exists') ||
          e.toString().contains('duplicate')) {
        Helpers.showInfoSnackbar('Service is already in your saved list');
        // إعادة تحميل البيانات للتأكد من التزامن
        loadSavedServices();
        return true;
      }

      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  Future<bool> unsaveService(String savedServiceId) async {
    try {
      await _serviceRepository.unsaveService(savedServiceId);

      // إزالة الخدمة من القائمة المحلية
      savedServices.removeWhere((service) => service.id == savedServiceId);
      Helpers.showSuccessSnackbar('Service removed from saved');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  // دالة للتبديل بين حفظ وإلغاء الحفظ
  Future<bool> toggleSaveService(String serviceId, String userId) async {
    if (isServiceSaved(serviceId)) {
      // الخدمة محفوظة، قم بإلغاء الحفظ
      final savedServiceId = getSavedServiceId(serviceId);
      if (savedServiceId != null) {
        return await unsaveService(savedServiceId);
      }
      return false;
    } else {
      // الخدمة غير محفوظة، قم بحفظها
      return await saveService(serviceId, userId);
    }
  }

  // دالة لتنظيف جميع البيانات (للاستخدام من AuthController)
  void clearAllData() {
    services.clear();
    ownerServices.clear();
    savedServices.clear();
    filteredServices.clear();
    selectedType.value = null;
  }

  // إنشاء خدمة عادية بدون صور
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

  // إنشاء خدمة مع صور - دالة جديدة
  Future<bool> createServiceWithImages(
      Map<String, dynamic> serviceData, List<File>? imageFiles) async {
    try {
      isLoading.value = true;

      final newService = await _serviceRepository.createServiceWithImages(
          serviceData, imageFiles);
      ownerServices.add(newService);

      Helpers.showSuccessSnackbar('Service created successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // رفع صور إضافية لخدمة موجودة - دالة جديدة
  Future<bool> uploadServiceImages(
      String serviceId, List<File> imageFiles) async {
    try {
      isLoading.value = true;

      final response =
          await _serviceRepository.uploadServiceImages(serviceId, imageFiles);

      // تحديث الخدمة في القائمة المحلية
      final index = ownerServices.indexWhere((s) => s.id == serviceId);
      if (index != -1 && response.containsKey('service')) {
        ownerServices[index] = ServiceModel.fromJson(response['service']);
      }

      Helpers.showSuccessSnackbar('Images uploaded successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
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
      isLoading.value = true;

      await _serviceRepository.deleteService(id);

      ownerServices.removeWhere((service) => service.id == id);
      Helpers.showSuccessSnackbar('Service deleted successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // دالة debug محسنة
  Future<void> debugSavedServices() async {
    try {
      print("=== DEBUG SAVED SERVICES ===");

      // طباعة معلومات المستخدم الحالي
      await StorageService.debugPrintStoredData();

      // الحصول على البيانات الخام من API
      final debugData = await _serviceRepository.debugGetSavedServicesRaw();

      print("Debug Data: $debugData");
      print("Current User ID: ${debugData['currentUserId']}");
      print("Raw API Response: ${debugData['rawResponse']}");
      print("Response Type: ${debugData['responseType']}");

      if (debugData['rawResponse'] is List) {
        final List<dynamic> rawList = debugData['rawResponse'];
        print("Total items from API: ${rawList.length}");

        for (int i = 0; i < rawList.length; i++) {
          final item = rawList[i];
          print("Raw item $i: $item");

          // فحص جميع الحقول المحتملة للمستخدم
          final possibleUserFields = [
            'user_id',
            'userId',
            'user',
            'owner_id',
            'ownerId',
          ];

          print("User fields in item $i:");
          for (String field in possibleUserFields) {
            if (item.containsKey(field)) {
              print("  $field: ${item[field]} (${item[field].runtimeType})");
            }
          }
          print("---");
        }
      }

      // طباعة البيانات الحالية في Controller
      print("Current savedServices in controller: ${savedServices.length}");
      for (int i = 0; i < savedServices.length; i++) {
        final saved = savedServices[i];
        print("Controller service $i: ID=${saved.id}, UserID=${saved.userId}");
      }

      print("=== END DEBUG ===");
    } catch (e) {
      print("Debug error: $e");
    }
  }

  String _extractErrorMessage(String error) {
    if (error.contains('Exception:')) {
      return error.split('Exception: ').last;
    } else if (error.contains('Network error')) {
      return 'Network error - Check your internet connection';
    } else if (error.contains('Server error')) {
      return 'Server error - Please try again later';
    } else {
      return 'An error occurred - Please try again';
    }
  }
}
