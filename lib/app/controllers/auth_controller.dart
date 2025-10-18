import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../utils/storage_service.dart';
import '../utils/error_handler.dart';
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
    scopes: ['email', 'profile'],
    clientId:
        '1073993043012-ku9rjlel3sqqc58o95qpu4ucgr6iq578.apps.googleusercontent.com',
  );

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
      ErrorHandler.handleAndShowError(e, silent: true);
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
      ErrorHandler.handleAndShowError(e, silent: true);
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
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  void _updateWebSocketUserSilently(String? userId) {
    try {
      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();
        chatController.updateWebSocketUser(userId);
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<void> _updateWebSocketUser(String? userId) async {
    try {
      if (Get.isRegistered<ChatController>()) {
        final chatController = Get.find<ChatController>();
        await chatController.updateWebSocketUser(userId);
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authRepository.login(email, password);

      if (response.containsKey('user') && response.containsKey('token')) {
        final user = response['user'];

        if (user['verified'] == false) {
          ErrorHandler.showInfo('verify_account_first'.tr);
          return false;
        }

        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(user);

        currentUser.value = UserModel.fromJson(user);
        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        final hasAcceptedPrivacy =
            await StorageService.hasAcceptedPrivacyPolicy();
        if (!hasAcceptedPrivacy) {
          await StorageService.setAcceptedPrivacyPolicy(true);
          await StorageService.setAcceptedPrivacyVersion("1.0");
        }

        await _clearServiceData();
        await _updateWebSocketUser(currentUser.value?.id);
        Get.offAllNamed(
          currentUser.value?.userType == 'owner'
              ? AppRoutes.ownerHome
              : AppRoutes.userHome,
        );

        await _reloadUserSpecificData();
        return true;
      } else {
        ErrorHandler.showInfo('login_failed_check_credentials'.tr);
        return false;
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
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

        ErrorHandler.showSuccess('profile_updated_successfully'.tr);
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

        ErrorHandler.showSuccess('profile_updated_successfully'.tr);
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

        return true;
      }

      return false;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
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
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<bool> signInWithGoogle({String userType = 'user'}) async {
    try {
      isLoading.value = true;

      final account = await _googleSignIn.signIn();

      if (account == null) {
        ErrorHandler.showInfo('google_signin_cancelled'.tr);
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
      ErrorHandler.handleAndShowError(e);
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


        final userData = await FacebookAuth.instance.getUserData(
          fields: "name,email,picture.width(200)",
        );


        final loginSuccess = await _handleSocialLoginResponse(
          'facebook',
          accessToken,
          userType: userType,
        );

        return loginSuccess;
      } else if (result.status == LoginStatus.cancelled) {
        return false;
      } else {
        ErrorHandler.showInfo(
          result.message ?? 'facebook_signin_failed'.tr,
        );
        return false;
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
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
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Future<bool> signInWithApple({String userType = 'user'}) async {
  //   try {
  //     isLoading.value = true;
  //
  //     // Request Apple ID credentials
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //       webAuthenticationOptions: WebAuthenticationOptions(
  //         clientId: 'com.example.autoservice24', // Replace with your actual Service ID
  //         redirectUri: Uri.parse('https://www.autoservicely.com/auth/social-login'),
  //       ),
  //     );
  //
  //     // Validate required credentials
  //     final authorizationCode = credential.authorizationCode;
  //     final identityToken = credential.identityToken;
  //
  //     if (authorizationCode == null || identityToken == null) {
  //       throw Exception('Failed to get Apple credentials');
  //     }
  //
  //     // Send credentials to backend
  //     final response = await http.post(
  //       Uri.parse('https://www.autoservicely.com/auth/social-login'),
  //       body: jsonEncode({
  //         'provider': 'apple',
  //         'authorizationCode': authorizationCode,
  //         'idToken': identityToken,
  //         'email': credential.email,
  //         'givenName': credential.givenName,
  //         'familyName': credential.familyName,
  //         'userType': userType,
  //       }),
  //       headers: {'Content-Type': 'application/json'},
  //     );
  //
  //     // Handle backend response
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       // Process successful login (save token, navigate, etc.)
  //       // Example: await _saveUserSession(data);
  //       return true;
  //     } else {
  //       throw Exception('Server error: ${response.statusCode}');
  //     }
  //
  //   } catch (e) {
  //     ErrorHandler.handleAndShowError(e);
  //     return false;
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }

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

        await StorageService.setAcceptedPrivacyPolicy(true);
        await StorageService.setAcceptedPrivacyVersion("1.0");

        await _clearServiceData();
        await _updateWebSocketUser(currentUser.value?.id);

        ErrorHandler.showSuccess(
            '${_capitalizeProvider(provider)} ${'login_successful'.tr}');

        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        await _reloadUserSpecificData();
        return true;
      } else {
        ErrorHandler.showInfo('invalid_server_response'.tr);
        return false;
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
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

        if (userData['acceptsPrivacyPolicy'] == true) {
          await StorageService.setAcceptedPrivacyPolicy(true);
          await StorageService.setAcceptedPrivacyVersion("1.0");
        }

        await _clearServiceData();
        await _updateWebSocketUser(currentUser.value?.id);

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

          if (userData['acceptsPrivacyPolicy'] == true) {
            await StorageService.setAcceptedPrivacyPolicy(true);
            await StorageService.setAcceptedPrivacyVersion("1.0");
          }

          ErrorHandler.showSuccess(
            response['message'] ?? 'account_created_verify_email'.tr,
          );

          String userEmail =
              response['user']['email'] ?? userData['email'] ?? '';
          Get.offAllNamed(
            AppRoutes.emailVerification,
            arguments: userEmail,
          );

          return true;
        } else {
          ErrorHandler.showInfo(
            response['message'] ?? 'registration_failed'.tr,
          );
          return false;
        }
      } else if (response.containsKey('message') &&
          response.containsKey('email_verification_required') &&
          response['email_verification_required'] == true) {
        if (userData['acceptsPrivacyPolicy'] == true) {
          await StorageService.setAcceptedPrivacyPolicy(true);
          await StorageService.setAcceptedPrivacyVersion("1.0");
        }

        ErrorHandler.showSuccess(
          response['message'] ?? 'account_created_verify_email'.tr,
        );

        String userEmail = userData['email'] ?? '';
        Get.offAllNamed(
          AppRoutes.emailVerification,
          arguments: userEmail,
        );

        return true;
      } else {
        ErrorHandler.showInfo('invalid_server_response'.tr);
        return false;
      }
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
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

      final hasAcceptedPrivacy =
          await StorageService.hasAcceptedPrivacyPolicy();
      final privacyVersion = await StorageService.getAcceptedPrivacyVersion();

      await StorageService.clearAll();

      if (hasAcceptedPrivacy) {
        await StorageService.setAcceptedPrivacyPolicy(true);
        if (privacyVersion != null) {
          await StorageService.setAcceptedPrivacyVersion(privacyVersion);
        }
      }

      isLoggedIn.value = false;
      currentUser.value = null;
      isUserDataLoaded.value = true;

      Get.offAllNamed(AppRoutes.userHome);
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
    }
  }

  Future<void> _signOutFromSocialProviders() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      ErrorHandler.handleAndShowError(e, silent: true);
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

        ErrorHandler.showSuccess('account_deleted_successfully'.tr);
        return true;
      }

      ErrorHandler.showInfo('unable_to_delete_account'.tr);
      return false;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> forgotPassword(String email, String newPassword) async {
    try {
      isLoading.value = true;

      await _authRepository.forgotPassword(email, newPassword);
      ErrorHandler.showSuccess('password_updated_successfully'.tr);
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> sendForgotPasswordCode(String email) async {
    try {
      isLoading.value = true;

      await _authRepository.sendForgotPasswordCode(email);
      ErrorHandler.showSuccess('verification_code_sent_successfully'.tr);
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyResetCode(String email, String code) async {
    try {
      isLoading.value = true;

      await _authRepository.verifyResetCode(email, code);
      ErrorHandler.showSuccess('code_verified_successfully'.tr);
      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
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

      return true;
    } catch (e) {
      ErrorHandler.handleAndShowError(e);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
