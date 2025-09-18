import 'package:get/get.dart';
import 'dart:math';
import '../data/repositories/workshop_repository.dart';
import '../data/models/workshop_model.dart';
import '../data/models/service_model.dart';
import '../controllers/service_controller.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';

class WorkshopController extends GetxController {
  final WorkshopRepository _workshopRepository;
  final ServiceController serviceController = Get.find<ServiceController>();

  WorkshopController(this._workshopRepository);

  var isLoading = false.obs;
  var workshops = <WorkshopModel>[].obs;
  var ownerWorkshops = <WorkshopModel>[].obs;
  var nearbyWorkshops = <WorkshopModel>[].obs;

  // كاش للبحث السريع
  Map<String, List<WorkshopModel>> _searchCache = {};

  @override
  void onInit() {
    super.onInit();
    loadWorkshops();
  }

  Future<void> loadWorkshops() async {
    try {
      isLoading.value = true;
      final workshopList = await _workshopRepository.getAllWorkshops();
      workshops.value = workshopList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOwnerWorkshops(String userId) async {
    try {
      isLoading.value = true;
      final workshopList = await _workshopRepository.getWorkshopsByUserId(userId);
      ownerWorkshops.value = workshopList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<WorkshopModel?> getWorkshopById(String workshopId) async {
    try {
      final workshop = await _workshopRepository.getWorkshopById(workshopId);
      return workshop;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return null;
    }
  }

  Future<bool> createWorkshop(Map<String, dynamic> workshopData) async {
    try {
      isLoading.value = true;
      final newWorkshop = await _workshopRepository.createWorkshop(workshopData);
      ownerWorkshops.add(newWorkshop);
      workshops.add(newWorkshop);
      clearSearchCache(); // مسح الكاش
      Helpers.showSuccessSnackbar('Workshop created successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateWorkshop(String id, Map<String, dynamic> workshopData) async {
    try {
      isLoading.value = true;
      final updatedWorkshop = await _workshopRepository.updateWorkshop(id, workshopData);

      final index = ownerWorkshops.indexWhere((w) => w.id == id);
      if (index != -1) {
        ownerWorkshops[index] = updatedWorkshop;
      }

      final allIndex = workshops.indexWhere((w) => w.id == id);
      if (allIndex != -1) {
        workshops[allIndex] = updatedWorkshop;
      }

      clearSearchCache(); // مسح الكاش
      Helpers.showSuccessSnackbar('Workshop updated successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteWorkshop(String id) async {
    try {
      isLoading.value = true;
      await _workshopRepository.deleteWorkshop(id);
      ownerWorkshops.removeWhere((workshop) => workshop.id == id);
      workshops.removeWhere((workshop) => workshop.id == id);
      clearSearchCache(); // مسح الكاش
      Helpers.showSuccessSnackbar('Workshop deleted successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  WorkshopModel? findWorkshopById(String id) {
    try {
      return workshops.firstWhere((workshop) => workshop.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> searchWorkshops(String query) async {
    try {
      isLoading.value = true;
      final searchResults = await _workshopRepository.searchWorkshops(query);
      workshops.value = searchResults;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // البحث المحلي الجديد (من الفرونت إند فقط)
  Future<List<WorkshopModel>> searchNearbyWorkshopsLocally({
    required String serviceType,
    required double longitude,
    required double latitude,
    required double radiusKm,
  }) async {
    // مفتاح الكاش
    String cacheKey = '$serviceType-$longitude-$latitude-$radiusKm';

    // تحقق من الكاش
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    // تأكد من تحميل البيانات
    if (workshops.isEmpty) {
      await loadWorkshops();
    }

    if (serviceController.services.isEmpty) {
      await serviceController.loadServices();
    }

    List<WorkshopModel> nearbyWorkshops = [];

    for (var workshop in workshops) {
      // تأكد من صحة الإحداثيات
      if (workshop.latitude == 0.0 || workshop.longitude == 0.0) {
        continue;
      }

      // حساب المسافة
      double distance = _calculateDistance(
          latitude,
          longitude,
          workshop.latitude,
          workshop.longitude
      );

      // إذا كانت ضمن النطاق
      if (distance <= radiusKm) {
        // تحقق من وجود الخدمة المطلوبة
        bool hasService = serviceController.services.any((service) {
          // تحقق من نوع الخدمة
          String serviceTypeString = service.serviceType.toString();
          String expectedType = 'ServiceType.$serviceType';

          return service.workshopId == workshop.id &&
              serviceTypeString == expectedType;
        });

        if (hasService) {
          // إضافة المسافة للورشة
          var workshopWithDistance = workshop.copyWith(
              distanceFromUser: distance
          );
          nearbyWorkshops.add(workshopWithDistance);
        }
      }
    }

    // ترتيب حسب المسافة
    nearbyWorkshops.sort((a, b) =>
        (a.distanceFromUser ?? 0).compareTo(b.distanceFromUser ?? 0)
    );

    // حفظ في الكاش
    _searchCache[cacheKey] = nearbyWorkshops;

    return nearbyWorkshops;
  }

  // البحث المحلي البسيط (بدون نوع خدمة)
  List<WorkshopModel> getNearbyWorkshops({
    double? userLat,
    double? userLng,
    double radiusKm = 10.0,
  }) {
    if (userLat == null || userLng == null) {
      return workshops.toList();
    }

    List<WorkshopModel> nearbyWorkshops = [];

    for (var workshop in workshops) {
      if (workshop.latitude == 0.0 || workshop.longitude == 0.0) {
        continue;
      }

      double distance = _calculateDistance(
          userLat, userLng,
          workshop.latitude, workshop.longitude
      );

      if (distance <= radiusKm) {
        var workshopWithDistance = workshop.copyWith(
            distanceFromUser: distance
        );
        nearbyWorkshops.add(workshopWithDistance);
      }
    }

    nearbyWorkshops.sort((a, b) =>
        (a.distanceFromUser ?? 0).compareTo(b.distanceFromUser ?? 0)
    );

    return nearbyWorkshops;
  }

  // البحث باستخدام الباك إند (الكود القديم - احتفظ به للمستقبل)
  Future<void> loadNearbyWorkshopsByServiceType({
    required String serviceType,
    required double longitude,
    required double latitude,
    int radiusMeters = 5000,
  }) async {
    try {
      isLoading.value = true;
      final nearbyList = await _workshopRepository.getNearbyWorkshopsByServiceType(
        serviceType: serviceType,
        longitude: longitude,
        latitude: latitude,
        radius: radiusMeters,
      );
      nearbyWorkshops.value = nearbyList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  // مسح الكاش
  void clearSearchCache() {
    _searchCache.clear();
  }

  // حساب المسافة بين نقطتين (Haversine Formula)
  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // كيلومتر

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) * cos(_degreesToRadians(lat2)) *
            pow(sin(dLng / 2), 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
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