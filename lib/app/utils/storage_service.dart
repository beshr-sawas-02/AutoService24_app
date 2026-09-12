import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _languageKey = 'app_language';
  static const String _privacyAcceptedKey = 'privacy_policy_accepted';
  static const String _privacyVersionKey = 'privacy_policy_version';

  // ------------- Initialization -------------
  static Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      debugPrint('StorageService initialized successfully');
    } catch (e) {
      debugPrint('StorageService initialization failed: $e');
    }
  }

  // -------------------- Language --------------------
  static Future<void> saveLanguage(String langCode) async {
    try {
      await _prefs?.setString(_languageKey, langCode);
      debugPrint('Language saved: $langCode');
    } catch (e) {
      debugPrint('Failed to save language: $e');
    }
  }

  static String? getLanguage() {
    try {
      final lang = _prefs?.getString(_languageKey);
      debugPrint('Language retrieved: $lang');
      return lang;
    } catch (e) {
      debugPrint('Failed to get language: $e');
      return null;
    }
  }

  static Future<void> removeLanguage() async {
    try {
      await _prefs?.remove(_languageKey);
      debugPrint('Language removed');
    } catch (e) {
      debugPrint('Failed to remove language: $e');
    }
  }

  // -------------------- Token --------------------
  static Future<void> saveToken(String token) async {
    try {
      await _prefs?.setString(_tokenKey, token);
      debugPrint('Token saved successfully');
    } catch (e) {
      debugPrint('Failed to save token: $e');
    }
  }

  static Future<String?> getToken() async {
    try {
      final token = _prefs?.getString(_tokenKey);
      debugPrint('Token retrieved: ${token != null ? "***TOKEN***" : "null"}');
      return token;
    } catch (e) {
      debugPrint('Failed to get token: $e');
      return null;
    }
  }

  static Future<void> removeToken() async {
    try {
      await _prefs?.remove(_tokenKey);
      debugPrint('Token removed');
    } catch (e) {
      debugPrint('Failed to remove token: $e');
    }
  }

  // -------------------- User data --------------------
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final jsonString = jsonEncode(userData);
      await _prefs?.setString(_userDataKey, jsonString);
      debugPrint('User data saved successfully');
    } catch (e) {
      debugPrint('Failed to save user data: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final jsonString = _prefs?.getString(_userDataKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final userData = jsonDecode(jsonString) as Map<String, dynamic>;
        debugPrint('User data retrieved successfully');
        return userData;
      }
      debugPrint('No user data found');
      return null;
    } catch (e) {
      debugPrint('Failed to get user data: $e');
      return null;
    }
  }

  static Future<void> removeUserData() async {
    try {
      await _prefs?.remove(_userDataKey);
      debugPrint('User data removed');
    } catch (e) {
      debugPrint('Failed to remove user data: $e');
    }
  }

  // -------------------- Privacy Policy Methods --------------------
  static Future<bool> hasAcceptedPrivacyPolicy() async {
    try {
      final accepted = _prefs?.getBool(_privacyAcceptedKey) ?? false;
      debugPrint('Privacy policy acceptance status: $accepted');
      return accepted;
    } catch (e) {
      debugPrint('Failed to check privacy policy acceptance: $e');
      return false;
    }
  }

  static Future<void> setAcceptedPrivacyPolicy(bool accepted) async {
    try {
      await _prefs?.setBool(_privacyAcceptedKey, accepted);
      debugPrint('Privacy policy acceptance set to: $accepted');
    } catch (e) {
      debugPrint('Failed to set privacy policy acceptance: $e');
    }
  }

  static Future<String?> getAcceptedPrivacyVersion() async {
    try {
      final version = _prefs?.getString(_privacyVersionKey);
      debugPrint('Accepted privacy policy version: $version');
      return version;
    } catch (e) {
      debugPrint('Failed to get privacy policy version: $e');
      return null;
    }
  }

  static Future<void> setAcceptedPrivacyVersion(String version) async {
    try {
      await _prefs?.setString(_privacyVersionKey, version);
      debugPrint('Privacy policy version set to: $version');
    } catch (e) {
      debugPrint('Failed to set privacy policy version: $e');
    }
  }

  static Future<void> clearPrivacyData() async {
    try {
      await _prefs?.remove(_privacyAcceptedKey);
      await _prefs?.remove(_privacyVersionKey);
      debugPrint('Privacy policy data cleared');
    } catch (e) {
      debugPrint('Failed to clear privacy policy data: $e');
    }
  }

  // -------------------- Clear all --------------------
  static Future<void> clearAll() async {
    try {
      await _prefs?.clear();
      debugPrint('All storage data cleared');
    } catch (e) {
      debugPrint('Failed to clear all data: $e');
    }
  }

  // -------------------- Auth helpers --------------------
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      final isLoggedIn = token != null && token.isNotEmpty && userData != null;
      debugPrint('Login status: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      debugPrint('Failed to check login status: $e');
      return false;
    }
  }

  static Future<String?> getUserType() async {
    try {
      final userData = await getUserData();
      final userType = userData?['user_type'];
      debugPrint('User type: $userType');
      return userType;
    } catch (e) {
      debugPrint('Failed to get user type: $e');
      return null;
    }
  }

  static Future<String?> getUserId() async {
    try {
      final userData = await getUserData();
      final userId = userData?['_id'] ?? userData?['id'];
      debugPrint('User ID: $userId');
      return userId;
    } catch (e) {
      debugPrint('Failed to get user ID: $e');
      return null;
    }
  }

  // -------------------- Privacy Policy Status Check --------------------
  static Future<bool> needsPrivacyPolicyAcceptance() async {
    try {
      final hasAccepted = await hasAcceptedPrivacyPolicy();
      if (!hasAccepted) return true;

      final acceptedVersion = await getAcceptedPrivacyVersion();
      const currentVersion = "1.0"; // Should match PrivacyPolicyController.currentPrivacyVersion

      final needsUpdate = acceptedVersion != currentVersion;
      debugPrint('Needs privacy policy acceptance: $needsUpdate');
      return needsUpdate;
    } catch (e) {
      debugPrint('Failed to check privacy policy needs: $e');
      return true; // Default to requiring acceptance if check fails
    }
  }

  static Future<Map<String, dynamic>> getPrivacyPolicyStatus() async {
    try {
      final hasAccepted = await hasAcceptedPrivacyPolicy();
      final version = await getAcceptedPrivacyVersion();
      final needsUpdate = await needsPrivacyPolicyAcceptance();

      return {
        'hasAccepted': hasAccepted,
        'version': version,
        'needsUpdate': needsUpdate,
        'currentVersion': "1.0"
      };
    } catch (e) {
      debugPrint('Failed to get privacy policy status: $e');
      return {
        'hasAccepted': false,
        'version': null,
        'needsUpdate': true,
        'currentVersion': "1.0"
      };
    }
  }

  // -------------------- Debug --------------------
  static Future<void> debugPrintStoredData() async {
    try {
      final token = await getToken();
      final userData = await getUserData();
      final lang = getLanguage();
      final privacyStatus = await getPrivacyPolicyStatus();

      debugPrint('=== StorageService Debug Info ===');
      debugPrint('Token: ${token != null ? "***EXISTS***" : "null"}');
      debugPrint('Language: $lang');
      debugPrint('Privacy Status: $privacyStatus');

      if (userData != null) {
        debugPrint('User Data Keys: ${userData.keys.toList()}');
        debugPrint('Username: ${userData['username']}');
        debugPrint('Email: ${userData['email']}');
        debugPrint('User Type: ${userData['user_type']}');
      } else {
        debugPrint('User Data: null');
      }

      if (_prefs != null) {
        final keys = _prefs!.getKeys();
        debugPrint('All Storage Keys: ${keys.toList()}');
        for (String key in keys) {
          final value = _prefs!.get(key);
          if (key != _tokenKey && key != _userDataKey) {
            debugPrint('$key: $value');
          }
        }
      }
      debugPrint('=== End Debug Info ===');
    } catch (e) {
      debugPrint('Failed to print debug data: $e');
    }
  }

  // -------------------- Utility Methods --------------------
  static void copyToClipboard(String text) {
    try {
      Clipboard.setData(ClipboardData(text: text));
      debugPrint('Text copied to clipboard');
    } catch (e) {
      debugPrint('Failed to copy to clipboard: $e');
    }
  }

  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Information',
      message,
      backgroundColor: Colors.blue.withValues(alpha: 0.1),
      colorText: Colors.blue,
      icon: const Icon(Icons.info_outline, color: Colors.blue),
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  // -------------------- Backup and Restore (Future Use) --------------------
  static Future<Map<String, dynamic>> exportUserPreferences() async {
    try {
      return {
        'language': getLanguage(),
        'privacyAccepted': await hasAcceptedPrivacyPolicy(),
        'privacyVersion': await getAcceptedPrivacyVersion(),
        'exportDate': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Failed to export user preferences: $e');
      return {};
    }
  }

  static Future<void> importUserPreferences(Map<String, dynamic> preferences) async {
    try {
      if (preferences['language'] != null) {
        await saveLanguage(preferences['language']);
      }
      if (preferences['privacyAccepted'] == true) {
        await setAcceptedPrivacyPolicy(true);
      }
      if (preferences['privacyVersion'] != null) {
        await setAcceptedPrivacyVersion(preferences['privacyVersion']);
      }
      debugPrint('User preferences imported successfully');
    } catch (e) {
      debugPrint('Failed to import user preferences: $e');
    }
  }
}