import 'package:get/get.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_model.dart';
import '../utils/error_handler.dart';

class UserController extends GetxController {
  final UserRepository _userRepository;

  UserController(this._userRepository);

  var isLoading = false.obs;
  var user = Rx<UserModel?>(null);
  var users = <UserModel>[].obs;

  Future<bool> updateProfile(String userId, Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;

      final updatedUser = await _userRepository.updateUser(userId, userData);
      user.value = updatedUser;

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
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