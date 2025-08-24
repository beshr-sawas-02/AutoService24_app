import 'package:get/get.dart';
import '../data/repositories/workshop_repository.dart';
import '../data/models/workshop_model.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';

class WorkshopController extends GetxController {
  final WorkshopRepository _workshopRepository;

  WorkshopController(this._workshopRepository);

  var isLoading = false.obs;
  var workshops = <WorkshopModel>[].obs;
  var ownerWorkshops = <WorkshopModel>[].obs;

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

  Future<void> loadOwnerWorkshops() async {
    try {
      isLoading.value = true;

      // This would need the owner's user ID
      final workshopList = await _workshopRepository.getAllWorkshops();
      ownerWorkshops.value = workshopList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createWorkshop(Map<String, dynamic> workshopData) async {
    try {
      isLoading.value = true;

      final newWorkshop = await _workshopRepository.createWorkshop(workshopData);
      ownerWorkshops.add(newWorkshop);
      workshops.add(newWorkshop);

      Helpers.showSuccessSnackbar('Workshop created successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
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

      Helpers.showSuccessSnackbar('Workshop updated successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteWorkshop(String id) async {
    try {
      await _workshopRepository.deleteWorkshop(id);

      ownerWorkshops.removeWhere((workshop) => workshop.id == id);
      workshops.removeWhere((workshop) => workshop.id == id);
      Helpers.showSuccessSnackbar('Workshop deleted successfully');
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    }
  }

  WorkshopModel? getWorkshopById(String id) {
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
}