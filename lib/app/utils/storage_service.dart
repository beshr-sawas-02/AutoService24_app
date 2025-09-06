import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
    }
  }

  // Token methods
  static Future<void> saveToken(String token) async {
    try {
      await _prefs?.setString(_tokenKey, token);
    } catch (e) {
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = _prefs?.getString(_tokenKey);
      return token;
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeToken() async {
    try {
      await _prefs?.remove(_tokenKey);
    } catch (e) {
    }
  }

  // User data methods
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _prefs?.setString(_userDataKey, jsonString);
    } catch (e) {
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = _prefs?.getString(_userDataKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final userData = jsonDecode(jsonString) as Map<String, dynamic>;
        return userData;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeUserData() async {
    try {
      await _prefs?.remove(_userDataKey);
    } catch (e) {
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    try {
      await _prefs?.clear();
    } catch (e) {
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      final isLoggedIn = token != null && token.isNotEmpty && userData != null;
      return isLoggedIn;
    } catch (e) {
      return false;
    }
  }

  // Get user type
  static Future<String?> getUserType() async {
    try {
      final userData = await getUserData();
      final userType = userData?['user_type'];
      return userType;
    } catch (e) {
      return null;
    }
  }

  // Get user ID
  static Future<String?> getUserId() async {
    try {
      final userData = await getUserData();
      final userId = userData?['_id'];
      return userId;
    } catch (e) {
      return null;
    }
  }

  // Debug method to print all stored data
  static Future<void> debugPrintStoredData() async {
    try {
      final token = await getToken();
      final userData = await getUserData();

      if (token != null) {
      }
      if (userData != null) {
      }

      // طباعة كل المفاتيح المحفوظة
      if (_prefs != null) {
        final keys = _prefs!.getKeys();
        for (String key in keys) {
          final value = _prefs!.get(key);
          if (key == _tokenKey) {
          } else {
          }
        }
      }
    } catch (e) {
    }
  }
}