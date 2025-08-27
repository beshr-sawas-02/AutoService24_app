import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../data/repositories/auth_repository.dart';
import '../data/models/user_model.dart';
import '../utils/storage_service.dart';
import '../utils/error_handler.dart';
import '../utils/helpers.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();
  var isUserDataLoaded = false.obs;

  // إعداد مقدمي الخدمة الاجتماعية
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  @override
  void onInit() {
    super.onInit();
    print("AuthController: onInit() called");
    _checkLoginStatus();
  }

  @override
  void onReady() {
    super.onReady();
    print("AuthController: onReady() called");
    print("AuthController onReady - currentUser: ${currentUser.value}");
    print("AuthController onReady - isLoggedIn: ${isLoggedIn.value}");
    print(
        "AuthController onReady - isUserDataLoaded: ${isUserDataLoaded.value}");
  }

  Future<void> _checkLoginStatus() async {
    try {
      print("AuthController: _checkLoginStatus() started");

      await Future.delayed(Duration(milliseconds: 100));

      final token = await StorageService.getToken();
      //print("AuthController: Token check - exists: ${token != null}");

      if (token != null && token.isNotEmpty) {
        //print("AuthController: Token found, loading user data...");
        await _loadUserData();

        if (currentUser.value != null) {
          isLoggedIn.value = true;
          //print("AuthController: User data loaded successfully");
          //print("AuthController: User: ${currentUser.value!.username}");
        } else {
          //print("AuthController: Failed to load user data despite token existing");
          isLoggedIn.value = false;
        }
      } else {
        //print("AuthController: No token found");
        isLoggedIn.value = false;
        currentUser.value = null;
      }
    } catch (e) {
      //print("AuthController Error in _checkLoginStatus: $e");
      isLoggedIn.value = false;
      currentUser.value = null;
    } finally {
      isUserDataLoaded.value = true;
      // print("AuthController: _checkLoginStatus() completed");
      // print("AuthController Final State:");
      // print("  - isLoggedIn: ${isLoggedIn.value}");
      // print("  - isUserDataLoaded: ${isUserDataLoaded.value}");
      // print("  - currentUser: ${currentUser.value?.username ?? 'null'}");
    }
  }

  Future<void> _loadUserData() async {
    try {
      //print("AuthController: _loadUserData() started");

      final userData = await StorageService.getUserData();
      // print("AuthController: Retrieved user data: $userData");

      if (userData != null && userData.isNotEmpty) {
        final hasId = userData.containsKey('_id') || userData.containsKey('id');

        if (hasId &&
            userData.containsKey('username') &&
            userData.containsKey('email')) {
          currentUser.value = UserModel.fromJson(userData);
          // print("AuthController: UserModel created successfully");
          // print("AuthController: User ID: ${currentUser.value!.id}");
          // print("AuthController: Username: ${currentUser.value!.username}");
          // print("AuthController: Email: ${currentUser.value!.email}");
          // print("AuthController: User Type: ${currentUser.value!.userType}");

          currentUser.refresh();
        } else {
          // print("AuthController: User data missing required fields");
          // print("AuthController: Available keys: ${userData.keys.toList()}");
        }
      } else {
        // print("AuthController: No user data found in storage");
      }
    } catch (e) {
      // print("AuthController: Error loading user data: $e");
      ErrorHandler.logError(e, null);
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      isLoading.value = true;
      // print("AuthController: login() started for email: $email");

      final response = await _authRepository.login(email, password);
      // print("AuthController: Login response received: ${response.keys}");

      if (response.containsKey('token') && response.containsKey('user')) {
        //  print("AuthController: Valid response received");

        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(response['user']);

        //print("AuthController: Data saved to storage");

        currentUser.value = UserModel.fromJson(response['user']);
        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        //print("AuthController: State updated");
        //print("AuthController: Current user set to: ${currentUser.value?.username}");

        Helpers.showSuccessSnackbar('Login successful');

        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        return true;
      } else {
        // print("AuthController: Invalid response structure");
        // print("AuthController: Response keys: ${response.keys}");
        Helpers.showErrorSnackbar('Invalid server response');
        return false;
      }
    } catch (e) {
      // print("AuthController: Login error: $e");

      // Extract user-friendly message from exception
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // =============================================================
  // دوال تسجيل الدخول بالوسائل الاجتماعية - محدّثة
  // =============================================================

  Future<bool> signInWithGoogle({String userType = 'user'}) async {
    try {
      isLoading.value = true;
      // print("AuthController: Google sign in started");

      final account = await _googleSignIn.signIn();
      if (account == null) {
        // المستخدم ألغى العملية
        Helpers.showErrorSnackbar('Google sign in cancelled');
        return false;
      }

      final authentication = await account.authentication;
      final idToken = authentication.idToken;

      if (idToken == null) {
        throw Exception('Failed to get Google ID token');
      }

      // إرسال التوكن للخادم مع نوع المستخدم
      return await _handleSocialLoginResponse('google', idToken, userType: userType);

    } catch (e) {
      // print("AuthController: Google sign in error: $e");
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
      // print("AuthController: Facebook sign in started");

      final result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final accessToken = result.accessToken!.token;

        // إرسال التوكن للخادم مع نوع المستخدم
        return await _handleSocialLoginResponse('facebook', accessToken, userType: userType);
      } else {
        // print("AuthController: Facebook login failed: ${result.message}");
        Helpers.showErrorSnackbar(result.message ?? 'Facebook sign in failed');
        return false;
      }
    } catch (e) {
      // print("AuthController: Facebook sign in error: $e");
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
      // print("AuthController: Apple sign in started");

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

      // إرسال التوكن للخادم مع نوع المستخدم
      return await _handleSocialLoginResponse('apple', identityToken, userType: userType);

    } catch (e) {
      // print("AuthController: Apple sign in error: $e");
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar('Apple sign in failed: $errorMessage');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // دالة مساعدة لمعالجة استجابة تسجيل الدخول الاجتماعي - محدّثة
  Future<bool> _handleSocialLoginResponse(String provider, String token, {String userType = 'user'}) async {
    try {
      // print("AuthController: Handling social login response for $provider with userType: $userType");

      final response = await _authRepository.socialLogin(provider, token, userType: userType);
      // print("AuthController: Social login response received: ${response.keys}");

      if (response.containsKey('token') && response.containsKey('user')) {
        // print("AuthController: Valid social login response received");

        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(response['user']);

        currentUser.value = UserModel.fromJson(response['user']);
        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        // print("AuthController: Social login successful for: ${currentUser.value?.username}");
        Helpers.showSuccessSnackbar('${_capitalizeProvider(provider)} login successful');

        // توجيه المستخدم حسب نوعه
        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        return true;
      } else {
        // print("AuthController: Invalid social login response structure");
        // print("AuthController: Response keys: ${response.keys}");
        Helpers.showErrorSnackbar('Invalid server response');
        return false;
      }
    } catch (e) {
      // print("AuthController: Social login processing error: $e");
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    }
  }

  // دالة لتحويل اسم المزود إلى شكل جميل
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

  // =============================================================
  // باقي دوال AuthController الأصلية
  // =============================================================

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      isLoading.value = true;
      // print("AuthController: register() started for ${userData['email']}");

      final response = await _authRepository.register(userData);
      // print("AuthController: Registration response received: ${response.keys}");

      // Check different response formats - registration vs login
      if (response.containsKey('token') && response.containsKey('user')) {
        // Login response format
        // print("AuthController: Valid login-style response");

        await StorageService.saveToken(response['token']);
        await StorageService.saveUserData(response['user']);

        currentUser.value = UserModel.fromJson(response['user']);
        isLoggedIn.value = true;
        isUserDataLoaded.value = true;

        // print("AuthController: Registration successful for: ${currentUser.value?.username}");
        Helpers.showSuccessSnackbar('Account created successfully');

        if (currentUser.value?.userType == 'owner') {
          Get.offAllNamed(AppRoutes.ownerHome);
        } else {
          Get.offAllNamed(AppRoutes.userHome);
        }

        return true;
      } else if (response.containsKey('status') &&
          response.containsKey('user')) {
        // Registration response format (no token)
        // print("AuthController: Valid registration-style response");

        if (response['status'] == true) {
          // Save user data without token (user will need to login)
          await StorageService.saveUserData(response['user']);

          // print("AuthController: Registration successful for: ${response['user']['username']}");
          Helpers.showSuccessSnackbar(
              response['message'] ?? 'Account created successfully');

          // Redirect to login page since no token provided
          Get.offAllNamed(AppRoutes.login);

          return true;
        } else {
          // print("AuthController: Registration failed - status false");
          Helpers.showErrorSnackbar(
              response['message'] ?? 'Registration failed');
          return false;
        }
      } else {
        //  print("AuthController: Invalid registration response structure");
        //print("AuthController: Response keys: ${response.keys}");
        //print("AuthController: Full response: $response");
        Helpers.showErrorSnackbar('Invalid server response');
        return false;
      }
    } catch (e) {
      //print("AuthController: Registration error: $e");

      // Extract user-friendly message from exception
      String errorMessage = _extractErrorMessage(e.toString());
      Helpers.showErrorSnackbar(errorMessage);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      // print("AuthController: logout() started");

      // تسجيل الخروج من الخدمات الاجتماعية
      await _signOutFromSocialProviders();

      await StorageService.clearAll();
      isLoggedIn.value = false;
      currentUser.value = null;
      isUserDataLoaded.value = true;

      Helpers.showSuccessSnackbar('Logged out successfully');
      Get.offAllNamed(AppRoutes.userHome);
    } catch (e) {
      print("AuthController: Logout error: $e");
      ErrorHandler.logError(e, null);
    }
  }

  // دالة مساعدة لتسجيل الخروج من جميع الخدمات الاجتماعية
  Future<void> _signOutFromSocialProviders() async {
    try {
      await _googleSignIn.signOut();
      await FacebookAuth.instance.logOut();
      // Apple لا يحتاج sign out explicit
    } catch (e) {
      // print("AuthController: Error signing out from social providers: $e");
    }
  }

  bool get isGuest => !isLoggedIn.value;

  bool get isOwner => currentUser.value?.userType == 'owner';

  bool get isUser => currentUser.value?.userType == 'user';

  String get displayName => currentUser.value?.username ?? 'Guest';

  String get userEmail => currentUser.value?.email ?? '';

  Future<void> refreshUserData() async {
    //print("AuthController: refreshUserData() called");
    isUserDataLoaded.value = false;
    await _checkLoginStatus();
  }

  void debugPrintState() {
    //   print("=== AuthController State Debug ===");
    //   print("isLoading: ${isLoading.value}");
    //  print("isLoggedIn: ${isLoggedIn.value}");
    //print("isUserDataLoaded: ${isUserDataLoaded.value}");
    //print("currentUser: ${currentUser.value}");
    if (currentUser.value != null) {
      //print("User JSON: ${currentUser.value!.toJson()}");
    }
    //print("isGuest: $isGuest");
    //print("isOwner: $isOwner");
    //print("isUser: $isUser");
    //print("displayName: $displayName");
    //print("================================");
  }

  bool get hasCompleteProfile {
    final user = currentUser.value;
    if (user == null) return false;

    return user.username.isNotEmpty &&
        user.email.isNotEmpty &&
        user.phone.isNotEmpty;
  }

  Future<bool> deleteAccount() async {
    try {
      isLoading.value = true;

      if (currentUser.value?.id != null) {
        await _authRepository.deleteAccount(currentUser.value!.id);
        await logout();
        Helpers.showSuccessSnackbar('Account deleted successfully');
        return true;
      }

      Helpers.showErrorSnackbar('Unable to delete account');
      return false;
    } catch (e) {
      // print("AuthController: Delete account error: $e");
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

  // Helper method to extract user-friendly error messages
  String _extractErrorMessage(String error) {
    if (error.contains('Exception:')) {
      // Extract message after "Exception: "
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