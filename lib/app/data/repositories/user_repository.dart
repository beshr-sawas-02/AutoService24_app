import '../providers/api_provider.dart';
import '../models/user_model.dart';
import 'dart:io';

class UserRepository {
  final ApiProvider _apiProvider;

  UserRepository(this._apiProvider);

  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await _apiProvider.getUsers();
      final List<dynamic> userList = response.data;
      return userList.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  Future<UserModel> getUserById(String id) async {
    try {
      final response = await _apiProvider.getUser(id);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    try {
      final response = await _apiProvider.updateUser(id, userData);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _apiProvider.deleteUser(id);
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  Future<UserModel> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiProvider.register(userData);
      return UserModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }
}