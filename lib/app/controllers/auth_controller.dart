import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../utils/storage_service.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';
import '../routes/app_routes.dart';
import 'service_controller.dart';
import 'chat_controller.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();
  var isUserDataLoaded = false.obs;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'profile'
      ],

      clientId:
          '1073993043012-but35ubclk4kel50nri6ih64i3965i1i.apps.googleusercontent.com');

  @override
  void onInit() {
    super.onInit();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final token = await StorageService.getToken();

      if (token != null && token.isNotEmpty) {
        await _loadUserData();

        if (currentUser.value != null) {
          isLoggedIn.value = true;


          _updateWebSocketUserSilently(currentUser.value?.id);
        } else {
          isLoggedIn.value = false;
        }
      } else {
        isLoggedIn.value = false;
        currentUser.value = null;
      }
    } catch (e) {
      isLoggedIn.value = false;
      currentUser.value = null;
    } finally {
      isUserDataLoaded.value = true;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final userData = await StorageService.getUserData();

      if (userData != null && userData.isNotEmpty) {
        final hasId = userData.containsKey('_id') || userData.containsKey('id');

        if (hasId &&
            userData.containsKey('username') &&
            userData.containsKey('email')) {
          currentUser.value = UserModel.fromJson(userData);
          currentUser.refresh();
        }
      }
    } catch (e) {
      ErrorHandler.logError(e, null);
    }
  }

  Future<void> _clearServiceData() async {
    try {
      if (Get.isRegistered<ServiceController>()) {
        final serviceController = Get.find<ServiceController>();
        serviceController.savedServices.clear();
        serviceController.services.clear();
        serviceController.ownerServices.clear();
        serviceController.filteredServices.clear();
      }
    } catch (e) {
    }
  }


  void _updateWebSocketUserSilently(String? userId) {
    try {
      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();
        chatController.updateWebSocketUser(userId);
      }
    } catch (e) {
    }
  }


  Future<void> _updateWebSocketUser(String? userId) async {
    try {
      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();
        await chatController.updateWebSocketUser(userId);
      }
    } catch (e) {

    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authRepository.login(email, password);

      if (response.containsKey('token') && response.containsKey('user')) {
        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(response['user']);

        currentUser.value = UserModel.fromJson(response['user']);

        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        await _clearServiceData();


        await _updateWebSocketUser(currentUser.value?.id);

        Helpers.showSuccessSnackbar('Login successful');

        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        await _reloadUserSpecificData();

        return true;
      } else {
        Helpers.showErrorSnackbar('Invalid server response');
        return false;
      }
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> updateProfileWithImage(
      String userId, Map<String, dynamic> data, File? imageFile) async {
    try {
      isLoading.value = true;


      final response =
          await _authRepository.updateProfileWithImage(userId, data, imageFile);

      if (response.containsKey('user')) {
        final updatedUserData = response['user'];


        currentUser.value = UserModel.fromJson(updatedUserData);


        await StorageService.saveUserData(updatedUserData);


        currentUser.refresh();

        Helpers.showSuccessSnackbar('Profile updated successfully');
        return true;
      } else if (response.containsKey('status') && response['status'] == true) {


        final updatedUser = currentUser.value!.copyWith(
          username: data['username'],
          email: data['email'],
          phone: data['phone'],
          profileImage:
              response['profileImage'] ?? currentUser.value!.profileImage,
        );

        currentUser.value = updatedUser;
        await StorageService.saveUserData(updatedUser.toJson());
        currentUser.refresh();

        Helpers.showSuccessSnackbar('Profile updated successfully');
        return true;
      } else {
        throw Exception('Invalid response from server');
      }
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  Future<bool> updateProfileImage(File imageFile) async {
    try {
      if (currentUser.value == null) return false;

      isLoading.value = true;

      final response = await _authRepository.updateProfileWithImage(
        currentUser.value!.id,
        {},
        imageFile,
      );

      if (response.containsKey('user') ||
          response.containsKey('profileImage')) {
        String newImageUrl = '';

        if (response.containsKey('user')) {
          newImageUrl = response['user']['profileImage'] ?? '';
        } else {
          newImageUrl = response['profileImage'] ?? '';
        }



        final updatedUser = currentUser.value!.copyWith(
          profileImage: newImageUrl,
        );

        currentUser.value = updatedUser;
        await StorageService.saveUserData(updatedUser.toJson());

        currentUser.refresh();

        Helpers.showSuccessSnackbar('Profile image updated successfully');
        return true;
      }

      return false;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }


  void debugProfileImage() {
  }

  Future<void> _reloadUserSpecificData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      if (Get.isRegistered<ServiceController>()) {
        final serviceController = Get.find<ServiceController>();

        await serviceController.loadServices();
        await serviceController.loadSavedServices();
      }
    } catch (e) {
    }
  }

  Future<bool> signInWithGoogle({String userType = 'user'}) async {
    try {
      isLoading.value = true;


      final account = await _googleSignIn.signIn();

      if (account == null) {
        Helpers.showErrorSnackbar('Google sign in cancelled');
        return false;
      }


      final authentication = await account.authentication;


      final idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }


      return await _handleSocialLoginResponse('google', idToken,
          userType: userType);
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar('Google sign in failed: $errorMessage');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithFacebook({String userType = 'user'}) async {
    try {
      isLoading.value = true;

      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;
        return await _handleSocialLoginResponse('facebook', accessToken,
            userType: userType);
      } else {
        Helpers.showErrorSnackbar(result.message ?? 'Facebook sign in failed');
        return false;
      }
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar('Facebook sign in failed: $errorMessage');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> signInWithApple({String userType = 'user'}) async {
    try {
      isLoading.value = true;

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName
        ],
      );

      final identityToken = credential.identityToken;
      if (identityToken == null) {
        throw Exception('Failed to get Apple identity token');
      }

      return await _handleSocialLoginResponse('apple', identityToken,
          userType: userType);
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar('Apple sign in failed: $errorMessage');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _handleSocialLoginResponse(String provider, String token,
      {String userType = 'user'}) async {
    try {
      final response = await _authRepository.socialLogin(provider, token,
          userType: userType);

      if (response.containsKey('token') && response.containsKey('user')) {
        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(response['user']);

        currentUser.value = UserModel.fromJson(response['user']);

        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        await _clearServiceData();

        await _updateWebSocketUser(currentUser.value?.id);

        Helpers.showSuccessSnackbar(
            '${_capitalizeProvider(provider)} login successful');

        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        await _reloadUserSpecificData();

        return true;
      } else {
        Helpers.showErrorSnackbar('Invalid server response');
        return false;
      }
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    }
  }

  String _capitalizeProvider(String provider) {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'facebook':
        return 'Facebook';
      case 'apple':
        return 'Apple';
      default:
        return provider;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;

      final response = await _authRepository.register(userData);

      if (response.containsKey('token') && response.containsKey('user')) {
        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(response['user']);

        currentUser.value = UserModel.fromJson(response['user']);

        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        await _clearServiceData();

        await _updateWebSocketUser(currentUser.value?.id);

        Helpers.showSuccessSnackbar('Account created successfully');

        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        await _reloadUserSpecificData();

        return true;
      } else if (response.containsKey('status') &&
          response.containsKey('user')) {
        if (response['status'] == true) {
          await StorageService.saveUserData(response['user']);
          Helpers.showSuccessSnackbar(
              response['message'] ?? 'Account created successfully');
          Get.offAllNamed(AppRoutes.login);
          return true;
        } else {
          Helpers.showErrorSnackbar(
              response['message'] ?? 'Registration failed');
          return false;
        }
      } else {
        Helpers.showErrorSnackbar('Invalid server response');
        return false;
      }
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _updateWebSocketUser(null);

      await _signOutFromSocialProviders();

      await _clearServiceData();

      await StorageService.clearAll();
      isLoggedIn.value = false;
      currentUser.value = null;
      isUserDataLoaded.value = true;

      Helpers.showSuccessSnackbar('Logged out successfully');
      Get.offAllNamed(AppRoutes.userHome);
    } catch (e) {
      ErrorHandler.logError(e, null);
    }
  }

  Future<void> _signOutFromSocialProviders() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {

    }
  }

  bool get isGuest => !isLoggedIn.value;

  bool get isOwner => currentUser.value?.userType == 'owner';

  bool get isUser => currentUser.value?.userType == 'user';

  String get displayName => currentUser.value?.username ?? 'Guest';

  String get userEmail => currentUser.value?.email ?? '';


  Future<void> refreshUserData() async {
    isUserDataLoaded.value = false;


    await _loadUserData();

    if (currentUser.value != null) {
      currentUser.refresh();
    } else {
    }

    isUserDataLoaded.value = true;
  }

  bool get hasCompleteProfile {
    final user = currentUser.value;
    if (user == null) return false;

    return user.username.isNotEmpty &&
        user.email.isNotEmpty &&
        (user.phone?.isNotEmpty ?? false);
  }

  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;

      if (currentUser.value?.id != null) {
        await _authRepository.deleteAccount(currentUser.value!.id);


        await _updateWebSocketUser(null);

        await logout();
        Helpers.showSuccessSnackbar('Account deleted successfully');
        return true;
      }

      Helpers.showErrorSnackbar('Unable to delete account');
      return false;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> forgotPassword(String email, String newPassword) async {
    try {
      isLoading.value = true;

      await _authRepository.forgotPassword(email, newPassword);
      Helpers.showSuccessSnackbar('Password updated successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    try {
      if (currentUser.value == null) return false;

      isLoading.value = true;

      await StorageService.saveUserData(userData);
      currentUser.value = UserModel.fromJson(userData);

      Helpers.showSuccessSnackbar('Profile updated successfully');
      return true;
    } catch (e) {
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  String _extractErrorMessage(String error) {
    if (error.contains('Exception:')) {
      return error.split('Exception: ').last;
    } else if (error.contains('Invalid email or password')) {
      return 'Invalid email or password';
    } else if (error.contains('Email already exists')) {
      return 'This email is already registered';
    } else if (error.contains('Network error')) {
      return 'Network error - Check your internet connection';
    } else if (error.contains('Server error')) {
      return 'Server error - Please try again later';
    } else {
      return 'An error occurred - Please try again';
    }
  }
}
