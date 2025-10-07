import 'package:get/get.dart';
import 'dart:io';
import '../data/repositories/user_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../utils/error_handler.dart';

class UserController extends GetxController {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  UserController(this._userRepository, this._authRepository);

  var isLoading = false.obs;
  var user = Rx<UserModel?>(null);
  var users = <UserModel>[].obs;

  Future<bool> updateProfileWithImage(String userId, Map<String, dynamic> data, File? imageFile) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.updateProfileWithImage(userId, data, imageFile);

      if (response.containsKey('user')) {
        user.value = UserModel.fromJson(response['user']);
        return true;
      } else if (response.containsKey('status') && response['status'] == true) {
        return true;
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(String userId, Map<String, dynamic> userData) async {
    return await updateProfileWithImage(userId, userData, null);
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      isLoading.value = true;

      final fetchedUser = await _userRepository.getUserById(userId);
      user.value = fetchedUser;

      return fetchedUser;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllUsers() async {
    try {
      isLoading.value = true;

      final userList = await _userRepository.getAllUsers();
      users.value = userList;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      isLoading.value = true;

      await _userRepository.deleteUser(userId);
      users.removeWhere((u) => u.id == userId);

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}