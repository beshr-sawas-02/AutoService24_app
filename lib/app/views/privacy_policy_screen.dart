import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/privacy_policy_controller.dart';
import '../config/app_colors.dart';

class PrivacyPolicyView extends StatelessWidget {
  final PrivacyPolicyController privacyController =
      Get.find<PrivacyPolicyController>();
  final AuthController authController = Get.find<AuthController>();

  final bool showAcceptButton;
  final bool isFromRegistration;
  final VoidCallback? onAccepted;

  PrivacyPolicyView({
    super.key,
    this.showAcceptButton = false,
    this.isFromRegistration = false,
    this.onAccepted,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(isTablet),
      body: SafeArea(
        child: Column(
          children: [
            if (showAcceptButton)
              Obx(() {
                if (privacyController.hasAcceptedPrivacyPolicy.value) {
                  return _buildAcceptanceStatus(isTablet);
                }
                return const SizedBox.shrink();
              }),
            Expanded(
              child: _buildPrivacyContent(isTablet),
            ),
            if (showAcceptButton) _buildBottomActionBar(isTablet),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'privacy_policy_title'.tr,
        style: TextStyle(
          color: Colors.black87,
          fontSize: isTablet ? 18 : 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: Colors.grey[200],
        ),
      ),
    );
  }

  Widget _buildAcceptanceStatus(bool isTablet) {
    return Container(
      margin: EdgeInsets.all(isTablet ? 16 : 20),
      padding: EdgeInsets.all(isTablet ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user,
            color: Colors.green,
            size: isTablet ? 20 : 24,
          ),
          SizedBox(width: isTablet ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'privacy_accepted'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: isTablet ? 14 : 16,
                    color: Colors.green[800],
                  ),
                ),
                Text(
                  privacyController.acceptedDateText,
                  style: TextStyle(
                    fontSize: isTablet ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent(bool isTablet) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 20,
        vertical: isTablet ? 16 : 20,
      ),
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(isTablet),
            SizedBox(height: isTablet ? 32 : 40),
            _buildIntroduction(isTablet),
            SizedBox(height: isTablet ? 24 : 32),
            _buildSection(
              title: 'information_we_collect_title'.tr,
              content: _getInformationWeCollectContent(),
              icon: Icons.data_usage_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'how_we_use_title'.tr,
              content: _getHowWeUseContent(),
              icon: Icons.settings_applications_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'location_services_title'.tr,
              content: _getLocationServicesContent(),
              icon: Icons.location_on_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'data_sharing_title'.tr,
              content: _getDataSharingContent(),
              icon: Icons.share_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'data_security_title'.tr,
              content: _getDataSecurityContent(),
              icon: Icons.security_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'your_rights_title'.tr,
              content: _getYourRightsContent(),
              icon: Icons.account_circle_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'third_party_title'.tr,
              content: _getThirdPartyContent(),
              icon: Icons.link_rounded,
              isTablet: isTablet,
            ),
            _buildSection(
              title: 'children_privacy_title'.tr,
              content: _getChildrenPrivacyContent(),
              icon: Icons.child_care_rounded,
              isTablet: isTablet,
            ),
            _buildTermsOfService(isTablet),
            SizedBox(height: isTablet ? 32 : 40),
            _buildContactSection(isTablet),
            SizedBox(height: isTablet ? 24 : 32),
            _buildLastUpdated(isTablet),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 24 : 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A50), Color(0xFFFF6B35)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A50).withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  size: isTablet ? 32 : 36,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AutoService24',
                      style: TextStyle(
                        fontSize: isTablet ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'privacy_policy_header'.tr,
                      style: TextStyle(
                        fontSize: isTablet ? 14 : 16,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 20),
          Text(
            'privacy_commitment'.tr,
            style: TextStyle(
              fontSize: isTablet ? 14 : 16,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_rounded, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'important_notice'.tr,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'privacy_introduction'.tr,
            style: TextStyle(
              fontSize: isTablet ? 13 : 15,
              color: Colors.blue[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required bool isTablet,
    Color? backgroundColor,
  }) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 20),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          padding: EdgeInsets.all(isTablet ? 8 : 10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: isTablet ? 18 : 20),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 15 : 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
                isTablet ? 16 : 20, 0, isTablet ? 16 : 20, isTablet ? 16 : 20),
            child: Text(
              content,
              style: TextStyle(
                  fontSize: isTablet ? 13 : 15,
                  color: Colors.grey[700],
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsOfService(bool isTablet) {
    return _buildSection(
      title: 'terms_of_service_title'.tr,
      content: 'terms_of_service_content'.tr,
      icon: Icons.description_rounded,
      isTablet: isTablet,
      backgroundColor: Colors.purple[50],
    );
  }

  Widget _buildContactSection(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 20 : 24),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_support_rounded,
                  color: Colors.green[700], size: 24),
              const SizedBox(width: 12),
              Text(
                'contact_us_title'.tr,
                style: TextStyle(
                    fontSize: isTablet ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'contact_privacy_text'.tr,
            style: TextStyle(
                fontSize: isTablet ? 13 : 15,
                color: Colors.green[700],
                height: 1.6),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Icon(Icons.email_rounded, color: Colors.green[700], size: 20),
                const SizedBox(width: 8),
                Text(
                  'privacy@autoservice24.com',
                  style: TextStyle(
                      fontSize: isTablet ? 13 : 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.green[800]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isTablet ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'last_updated_title'.tr,
            style: TextStyle(
                fontSize: isTablet ? 12 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600]),
          ),
          SizedBox(height: isTablet ? 6 : 8),
          Text(
            'January 1, 2025',
            style: TextStyle(
                fontSize: isTablet ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800]),
          ),
          SizedBox(height: isTablet ? 4 : 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${'version_label'.tr}: ${PrivacyPolicyController.currentPrivacyVersion}',
                style: TextStyle(
                    fontSize: isTablet ? 12 : 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12)),
                child: Text(
                  'current_label'.tr,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      child: SafeArea(
        child: Obx(() {
          if (!privacyController.hasAcceptedPrivacyPolicy.value) {
            return SizedBox(
              width: double.infinity,
              height: isTablet ? 50 : 56,
              child: ElevatedButton(
                onPressed: privacyController.isLoading.value
                    ? null
                    : _handleAcceptPrivacy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 16)),
                ),
                child: privacyController.isLoading.value
                    ? SizedBox(
                        width: isTablet ? 20 : 24,
                        height: isTablet ? 20 : 24,
                        child: const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'accept_privacy_policy_button'.tr,
                            style: TextStyle(
                                fontSize: isTablet ? 14 : 16,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
              ),
            );
          } else {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(isTablet ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_user_rounded, color: Colors.green),
                  SizedBox(width: isTablet ? 8 : 12),
                  Text(
                    'privacy_policy_accepted_status'.tr,
                    style: TextStyle(
                        fontSize: isTablet ? 14 : 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[800]),
                  ),
                ],
              ),
            );
          }
        }),
      ),
    );
  }

  void _handleAcceptPrivacy() async {
    final success = await privacyController.acceptPrivacyPolicy();
    if (success) {
      if (onAccepted != null) onAccepted!();
      if (isFromRegistration) Get.back(result: true);
    }
  }

  // Content methods
  String _getInformationWeCollectContent() =>
      'information_we_collect_content'.tr;

  String _getHowWeUseContent() => 'how_we_use_content'.tr;

  String _getLocationServicesContent() => 'location_services_content'.tr;

  String _getDataSharingContent() => 'data_sharing_content'.tr;

  String _getDataSecurityContent() => 'data_security_content'.tr;

  String _getYourRightsContent() => 'your_rights_content'.tr;

  String _getThirdPartyContent() => 'third_party_content'.tr;

  String _getChildrenPrivacyContent() => 'children_privacy_content'.tr;
}
