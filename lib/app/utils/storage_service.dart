import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      print("StorageService: Initialized successfully");
    } catch (e) {
      print("StorageService: Failed to initialize: $e");
    }
  }

  // Token methods
  static Future<void> saveToken(String token) async {
    try {
      await _prefs?.setString(_tokenKey, token);
      print("StorageService: Token saved successfully");
    } catch (e) {
      print("StorageService: Failed to save token: $e");
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = _prefs?.getString(_tokenKey);
      print("StorageService: Retrieved token: ${token != null ? 'exists' : 'null'}");
      return token;
    } catch (e) {
      print("StorageService: Failed to get token: $e");
      return null;
    }
  }

  static Future<void> removeToken() async {
    try {
      await _prefs?.remove(_tokenKey);
      print("StorageService: Token removed successfully");
    } catch (e) {
      print("StorageService: Failed to remove token: $e");
    }
  }

  // User data methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _prefs?.setString(_userDataKey, jsonString);
      print("StorageService: User data saved: ${userData['username']}");
    } catch (e) {
      print("StorageService: Failed to save user data: $e");
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = _prefs?.getString(_userDataKey);
      print("StorageService: Retrieved user data string: ${jsonString != null ? 'exists' : 'null'}");

      if (jsonString != null && jsonString.isNotEmpty) {
        final userData = jsonDecode(jsonString) as Map<String, dynamic>;
        print("StorageService: Parsed user data: ${userData['username']}");
        return userData;
      }
      return null;
    } catch (e) {
      print("StorageService: Failed to get user data: $e");
      return null;
    }
  }

  static Future<void> removeUserData() async {
    try {
      await _prefs?.remove(_userDataKey);
      print("StorageService: User data removed successfully");
    } catch (e) {
      print("StorageService: Failed to remove user data: $e");
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    try {
      await _prefs?.clear();
      print("StorageService: All data cleared successfully");
    } catch (e) {
      print("StorageService: Failed to clear all data: $e");
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      final isLoggedIn = token != null && token.isNotEmpty && userData != null;
      print("StorageService: Is logged in: $isLoggedIn");
      return isLoggedIn;
    } catch (e) {
      print("StorageService: Failed to check login status: $e");
      return false;
    }
  }

  // Get user type
  static Future<String?> getUserType() async {
    try {
      final userData = await getUserData();
      final userType = userData?['user_type'];
      print("StorageService: User type: $userType");
      return userType;
    } catch (e) {
      print("StorageService: Failed to get user type: $e");
      return null;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final userData = await getUserData();
      final userId = userData?['_id'];
      print("StorageService: User ID: ${userId != null ? 'exists' : 'null'}");
      return userId;
    } catch (e) {
      print("StorageService: Failed to get user ID: $e");
      return null;
    }
  }

  // Debug method to print all stored data
  static Future<void> debugPrintStoredData() async {
    try {
      final token = await getToken();
      final userData = await getUserData();

      print("=== StorageService Debug ===");
      print("SharedPreferences initialized: ${_prefs != null}");
      print("Token exists: ${token != null}");
      if (token != null) {
        print("Token length: ${token.length}");
        print("Token preview: ${token.substring(0, token.length > 20 ? 20 : token.length)}...");
      }
      print("User data exists: ${userData != null}");
      if (userData != null) {
        print("Raw user data: $userData");
        print("Username: ${userData['username']}");
        print("Email: ${userData['email']}");
        print("User type: ${userData['user_type']}");
        print("User ID: ${userData['_id']}");
        print("Phone: ${userData['phone']}");
        print("Profile image: ${userData['profile_image']}");
      }

      // طباعة كل المفاتيح المحفوظة
      if (_prefs != null) {
        final keys = _prefs!.getKeys();
        print("All stored keys: $keys");
        for (String key in keys) {
          final value = _prefs!.get(key);
          if (key == _tokenKey) {
            print("$key: ${value != null ? 'TOKEN_EXISTS' : 'null'}");
          } else {
            print("$key: $value");
          }
        }
      }
      print("========================");
    } catch (e) {
      print("StorageService: Debug print failed: $e");
    }
  }
}