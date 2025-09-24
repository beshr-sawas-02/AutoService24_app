import '../providers/api_provider.dart';
import 'dart:io';

class AuthRepository {
  final ApiProvider _apiProvider;

  AuthRepository(this._apiProvider);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiProvider.login({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Login failed with status: ${response.statusCode}');
      }
    } catch (e) {

      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
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

  Future<Map<String, dynamic>> socialLogin(String provider, String token, {String userType = 'user'}) async {
    try {

      final response = await _apiProvider.socialLogin({
        'provider': provider,
        'Token': token,
        'usertype': userType,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Social login failed with status: ${response.statusCode}');
      }
    } catch (e) {

      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
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

      final response = await _apiProvider.register(userData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Registration failed with status: ${response.statusCode}');
      }
    } catch (e) {

      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
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


  Future<Map<String, dynamic>> updateProfileWithImage(String userId, Map<String, dynamic> data, File? imageFile) async {
    try {

      final response = await _apiProvider.updateProfileWithImage(userId, data, imageFile);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Profile update failed with status: ${response.statusCode}');
      }
    } catch (e) {

      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
        if (e.toString().contains('400')) {
          throw Exception('Invalid profile data');
        } else if (e.toString().contains('401')) {
          throw Exception('Unauthorized - Please login again');
        } else if (e.toString().contains('404')) {
          throw Exception('User not found');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error - Please try again later');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Profile update failed: ${e.toString()}');
    }
  }

  Future<void> forgotPassword(String email, String newPassword) async {
    try {
      final response = await _apiProvider.forgotPassword({
        'email': email,
        'newPassword': newPassword,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Password reset failed with status: ${response.statusCode}');
      }
    } catch (e) {

      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
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

  // Add these methods to your existing AuthRepository class

  Future<void> sendForgotPasswordCode(String email) async {
    try {
      final response = await _apiProvider.sendForgotPasswordCode({
        'email': email,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send verification code with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
        if (e.toString().contains('404')) {
          throw Exception('Email not found');
        } else if (e.toString().contains('400')) {
          throw Exception('Invalid email format');
        } else if (e.toString().contains('429')) {
          throw Exception('Too many requests - Please try again later');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error - Please try again later');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Failed to send verification code: ${e.toString()}');
    }
  }

  Future<void> verifyResetCode(String email, String code) async {
    try {
      final response = await _apiProvider.verifyResetCode({
        'email': email,
        'code': code,
      });

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Code verification failed with status: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
        if (e.toString().contains('400')) {
          throw Exception('Invalid or expired verification code');
        } else if (e.toString().contains('404')) {
          throw Exception('Verification code not found');
        } else if (e.toString().contains('500')) {
          throw Exception('Server error - Please try again later');
        } else {
          throw Exception('Network error - Check your connection');
        }
      }

      throw Exception('Code verification failed: ${e.toString()}');
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      final response = await _apiProvider.deleteUser(userId);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Account deletion failed with status: ${response.statusCode}');
      }
    } catch (e) {

      if (e.toString().contains('DioException') || e.toString().contains('DioError')) {
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