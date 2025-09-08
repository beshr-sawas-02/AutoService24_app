import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _languageKey = 'app_language';

  // ------------- Initialization -------------
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      // ← هنا
    } catch (e) {
    }
  }

  // -------------------- Language --------------------
  static Future<void> saveLanguage(String langCode) async {
    try {
      await _prefs?.setString(_languageKey, langCode);
    } catch (e) {
    }
  }

  static String? getLanguage() {
    try {
      return _prefs?.getString(_languageKey);
    } catch (e) {
      return null;
    }
  }

  static Future<void> removeLanguage() async {
    try {
      await _prefs?.remove(_languageKey);
    } catch (e) {
    }
  }

  // -------------------- Token --------------------
  static Future<void> saveToken(String token) async {
    try {
      await _prefs?.setString(_tokenKey, token);
    } catch (e) {
    }
  }

  static Future<String?> getToken() async {
    try {
      return _prefs?.getString(_tokenKey);
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

  // -------------------- User data --------------------
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

  // -------------------- Clear all --------------------
  static Future<void> clearAll() async {
    try {
      await _prefs?.clear();
    } catch (e) {
    }
  }

  // -------------------- Auth helpers --------------------
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      return token != null && token.isNotEmpty && userData != null;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> getUserType() async {
    try {
      final userData = await getUserData();
      return userData?['user_type'];
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserId() async {
    try {
      final userData = await getUserData();
      return userData?['_id'];
    } catch (e) {
      return null;
    }
  }

  // -------------------- Debug --------------------
  static Future<void> debugPrintStoredData() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      final lang = getLanguage();


      if (_prefs != null) {
        final keys = _prefs!.getKeys();
        for (String key in keys) {
          final value = _prefs!.get(key);
        }
      }
    } catch (e) {
    }
  }
}
