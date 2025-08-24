import '../providers/api_provider.dart';
import '../models/workshop_model.dart';

class WorkshopRepository {
  final ApiProvider _apiProvider;

  WorkshopRepository(this._apiProvider);

  Future<List<WorkshopModel>> getAllWorkshops() async {
    try {
      final response = await _apiProvider.getWorkshops();
      final List<dynamic> workshopList = response.data;
      return workshopList.map((json) => WorkshopModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get workshops: ${e.toString()}');
    }
  }

  Future<WorkshopModel> getWorkshopById(String id) async {
    try {
      final response = await _apiProvider.getWorkshop(id);
      return WorkshopModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get workshop: ${e.toString()}');
    }
  }

  Future<WorkshopModel> createWorkshop(Map<String, dynamic> workshopData) async {
    try {
      final response = await _apiProvider.createWorkshop(workshopData);
      return WorkshopModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create workshop: ${e.toString()}');
    }
  }

  Future<WorkshopModel> updateWorkshop(String id, Map<String, dynamic> workshopData) async {
    try {
      final response = await _apiProvider.updateWorkshop(id, workshopData);
      return WorkshopModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update workshop: ${e.toString()}');
    }
  }

  Future<void> deleteWorkshop(String id) async {
    try {
      await _apiProvider.deleteWorkshop(id);
    } catch (e) {
      throw Exception('Failed to delete workshop: ${e.toString()}');
    }
  }

  Future<List<WorkshopModel>> getWorkshopsByUserId(String userId) async {
    try {
      final allWorkshops = await getAllWorkshops();
      return allWorkshops.where((workshop) => workshop.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to get user workshops: ${e.toString()}');
    }
  }

  Future<List<WorkshopModel>> searchWorkshops(String query) async {
    try {
      final allWorkshops = await getAllWorkshops();
      return allWorkshops.where((workshop) =>
      workshop.name.toLowerCase().contains(query.toLowerCase()) ||
          workshop.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    } catch (e) {
      throw Exception('Failed to search workshops: ${e.toString()}');
    }
  }
}