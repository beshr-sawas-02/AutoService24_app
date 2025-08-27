import '../providers/api_provider.dart';

class AuthRepository {
  final ApiProvider _apiProvider;

  AuthRepository(this._apiProvider);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiProvider.login({
        'email': email,
        'password': password,
      });

      // print("LOGIN RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // print("AuthRepository Login Error: $e");

      // Handle Dio errors specifically
      if (e.toString().contains('DioException') ||
          e.toString().contains('DioError')) {
        if (e.toString().contains('400')) {
          throw Exception('Invalid email or password');
        } else if (e.toString().contains('401')) {
          throw Exception('Unauthorized - Invalid credentials');
        } else if (e.toString().contains('404')) {
          throw Exception('User not found');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error - Please try again later');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // إضافة دالة تسجيل الدخول الاجتماعي مع دعم userType
  Future<Map<String, dynamic>> socialLogin(String provider, String token, {String userType = 'user'}) async {
    try {
      // print("AuthRepository: Attempting social login with $provider, userType: $userType");

      final response = await _apiProvider.socialLogin({
        'provider': provider,
        'token': token,
        'userType': userType,
      });

      // print("SOCIAL LOGIN RESPONSE STATUS: ${response.statusCode}");
      // print("SOCIAL LOGIN RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Social login failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // print("AuthRepository Social Login Error: $e");

      // Handle Dio errors specifically
      if (e.toString().contains('DioException') ||
          e.toString().contains('DioError')) {
        if (e.toString().contains('400')) {
          throw Exception('Invalid social login data');
        } else if (e.toString().contains('401')) {
          throw Exception('Social login unauthorized');
        } else if (e.toString().contains('403')) {
          throw Exception('Social login forbidden - Account may be restricted');
        } else if (e.toString().contains('404')) {
          throw Exception('Social login endpoint not found');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error - Please try again later');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Social login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      // print("AuthRepository: Attempting registration for ${userData['email']}");

      final response = await _apiProvider.register(userData);

      // print("REGISTER RESPONSE STATUS: ${response.statusCode}");
      // print("REGISTER RESPONSE DATA: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Registration failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // print("AuthRepository Registration Error: $e");

      // Handle Dio errors specifically
      if (e.toString().contains('DioException') ||
          e.toString().contains('DioError')) {
        if (e.toString().contains('400')) {
          throw Exception('Invalid registration data');
        } else if (e.toString().contains('409')) {
          throw Exception('Email already exists');
        } else if (e.toString().contains('422')) {
          throw Exception('Validation failed - Check your input');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error - Please try again later');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email, String newPassword) async {
    try {
      //  print("AuthRepository: Attempting forgot password for $email");

      final response = await _apiProvider.forgotPassword({
        'email': email,
        'newPassword': newPassword,
      });

      //print("FORGOT PASSWORD RESPONSE: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(
            'Password reset failed with status: ${response.statusCode}');
      }
    } catch (e) {
      //print("AuthRepository Forgot Password Error: $e");

      if (e.toString().contains('DioException') ||
          e.toString().contains('DioError')) {
        if (e.toString().contains('404')) {
          throw Exception('Email not found');
        } else if (e.toString().contains('400')) {
          throw Exception('Invalid email or password format');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      //  print("AuthRepository: Attempting to delete account $userId");

      final response = await _apiProvider.deleteUser(userId);

      // print("DELETE ACCOUNT RESPONSE: ${response.statusCode}");

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
            'Account deletion failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // print("AuthRepository Delete Account Error: $e");

      if (e.toString().contains('DioException') ||
          e.toString().contains('DioError')) {
        if (e.toString().contains('404')) {
          throw Exception('Account not found');
        } else if (e.toString().contains('401')) {
          throw Exception('Unauthorized - Please login again');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Account deletion failed: ${e.toString()}');
    }
  }
}