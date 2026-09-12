import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../utils/storage_service.dart';
import '../utils/helpers.dart';

class PrivacyPolicyController extends GetxController {
  static const String currentPrivacyVersion = "1.0";

  var isLoading = false.obs;
  var hasAcceptedPrivacyPolicy = false.obs;
  var acceptedPrivacyVersion = Rxn<String>();
  var isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPrivacyStatus();
  }

  @override
  void onReady() {
    super.onReady();
    if (kDebugMode) {
      _debugPrivacyStatus();
    }
  }

  Future<void> _loadPrivacyStatus() async {
    try {
      isLoading.value = true;

      final hasAccepted = await StorageService.hasAcceptedPrivacyPolicy();
      final version = await StorageService.getAcceptedPrivacyVersion();

      hasAcceptedPrivacyPolicy.value = hasAccepted;
      acceptedPrivacyVersion.value = version;

      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Loaded - hasAccepted: $hasAccepted, version: $version');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Error loading privacy status - $e');
      }
      // Set default values on error
      hasAcceptedPrivacyPolicy.value = false;
      acceptedPrivacyVersion.value = null;
    } finally {
      isLoading.value = false;
      isInitialized.value = true;
    }
  }

  Future<bool> acceptPrivacyPolicy() async {
    try {
      isLoading.value = true;

      await StorageService.setAcceptedPrivacyPolicy(true);
      await StorageService.setAcceptedPrivacyVersion(currentPrivacyVersion);

      hasAcceptedPrivacyPolicy.value = true;
      acceptedPrivacyVersion.value = currentPrivacyVersion;

      Helpers.showSuccessSnackbar('privacy_policy_accepted_successfully'.tr);

      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Privacy policy accepted successfully');
      }

      return true;

    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Error accepting privacy policy - $e');
      }
      Helpers.showErrorSnackbar('failed_to_accept_privacy_policy'.tr);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> revokePrivacyConsent() async {
    try {
      isLoading.value = true;

      await StorageService.clearPrivacyData();

      hasAcceptedPrivacyPolicy.value = false;
      acceptedPrivacyVersion.value = null;

      Helpers.showInfoSnackbar('privacy_consent_revoked'.tr);

      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Privacy consent revoked');
      }

    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Error revoking consent - $e');
      }
      Helpers.showErrorSnackbar('failed_to_revoke_consent'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshPrivacyStatus() async {
    await _loadPrivacyStatus();
  }

  // Getters for computed properties
  bool get needsPrivacyUpdate {
    if (!hasAcceptedPrivacyPolicy.value) return true;
    return acceptedPrivacyVersion.value != currentPrivacyVersion;
  }

  bool get canProceed {
    return hasAcceptedPrivacyPolicy.value && !needsPrivacyUpdate;
  }

  String get privacyStatusText {
    if (!hasAcceptedPrivacyPolicy.value) {
      return 'privacy_not_accepted'.tr;
    } else if (needsPrivacyUpdate) {
      return 'privacy_needs_update'.tr;
    } else {
      return 'privacy_accepted'.tr;
    }
  }

  String get acceptedDateText {
    if (acceptedPrivacyVersion.value != null) {
      return '${'version'.tr}: ${acceptedPrivacyVersion.value}';
    }
    return 'not_accepted'.tr;
  }

  // Check if user needs to accept privacy policy before using certain features
  bool get requiresAcceptanceForFeatures {
    return !canProceed;
  }

  // Get privacy policy status for debugging
  Map<String, dynamic> get privacyStatus {
    return {
      'hasAccepted': hasAcceptedPrivacyPolicy.value,
      'acceptedVersion': acceptedPrivacyVersion.value,
      'currentVersion': currentPrivacyVersion,
      'needsUpdate': needsPrivacyUpdate,
      'canProceed': canProceed,
      'isInitialized': isInitialized.value,
    };
  }

  // For future use - handle privacy policy updates
  Future<bool> updatePrivacyPolicyVersion(String newVersion) async {
    try {
      isLoading.value = true;

      // If user has accepted the current version, mark as needs update
      if (hasAcceptedPrivacyPolicy.value) {
        hasAcceptedPrivacyPolicy.value = false;
        acceptedPrivacyVersion.value = null;

        await StorageService.clearPrivacyData();

        Helpers.showInfoSnackbar('privacy_needs_update'.tr);

        if (kDebugMode) {
          debugPrint('PrivacyPolicyController: Privacy policy updated to version $newVersion - user needs to re-accept');
        }

        return true;
      }

      return false;

    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Error updating privacy policy version - $e');
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // Export privacy data for user (GDPR compliance)
  Future<Map<String, dynamic>> exportPrivacyData() async {
    try {
      final privacyData = await StorageService.getPrivacyPolicyStatus();
      return {
        'privacyPolicy': privacyData,
        'exportedAt': DateTime.now().toIso8601String(),
        'appVersion': currentPrivacyVersion,
      };
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrivacyPolicyController: Error exporting privacy data - $e');
      }
      return {};
    }
  }

  // Validate privacy acceptance before sensitive operations
  Future<bool> validatePrivacyForSensitiveOperation() async {
    if (!canProceed) {
      Helpers.showErrorSnackbar('privacy_required_for_operation'.tr);
      return false;
    }
    return true;
  }

  void _debugPrivacyStatus() {
    if (kDebugMode) {
      debugPrint('=== Privacy Policy Controller Debug ===');
      debugPrint('Status: ${privacyStatus.toString()}');
      debugPrint('Privacy Status Text: $privacyStatusText');
      debugPrint('Accepted Date Text: $acceptedDateText');
      debugPrint('Can Proceed: $canProceed');
      debugPrint('Needs Update: $needsPrivacyUpdate');
      debugPrint('======================================');
    }
  }

  @override
  void onClose() {
    if (kDebugMode) {
      debugPrint('PrivacyPolicyController: Controller disposed');
    }
    super.onClose();
  }
}