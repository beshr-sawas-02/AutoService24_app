import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/app_colors.dart';
import '../utils/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSizes.iconXLarge,
                color: AppColors.mediumGrey,
              ),
            ),
            const SizedBox(height: AppSizes.spaceLarge),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppSizes.titleMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSizes.spaceSmall),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: AppSizes.textLarge,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppSizes.spaceLarge),
              ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceLarge,
                    vertical: AppSizes.spaceMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonBorderRadius,
                    ),
                  ),
                ),
                child: Text(buttonText!),
              ),
            ],
            if (customAction != null) ...[
              const SizedBox(height: AppSizes.spaceLarge),
              customAction!,
            ],
          ],
        ),
      ),
    );
  }
}

// Predefined empty states for common scenarios
class NoServicesFound extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoServicesFound({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.build_outlined,
      title: 'no_services_found'.tr,
      subtitle: 'no_services_available'.tr,
      buttonText: onRefresh != null ? 'refresh'.tr : null,
      onButtonPressed: onRefresh,
    );
  }
}

class NoWorkshopsFound extends StatelessWidget {
  final VoidCallback? onRefresh;

  const NoWorkshopsFound({super.key, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.business_outlined,
      title: 'no_workshops_found'.tr,
      subtitle: 'no_workshops_available'.tr,
      buttonText: onRefresh != null ? 'refresh'.tr : null,
      onButtonPressed: onRefresh,
    );
  }
}

class NoSavedServices extends StatelessWidget {
  final VoidCallback? onBrowse;

  const NoSavedServices({super.key, this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.bookmark_border,
      title: 'no_saved_services'.tr,
      subtitle: 'no_saved_services_subtitle'.tr,
      buttonText: onBrowse != null ? 'browse_services'.tr : null,
      onButtonPressed: onBrowse,
    );
  }
}

class NoChatsFound extends StatelessWidget {
  final VoidCallback? onStartChat;

  const NoChatsFound({super.key, this.onStartChat});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.chat_bubble_outline,
      title: 'no_conversations'.tr,
      subtitle: 'no_conversations_subtitle'.tr,
      buttonText: onStartChat != null ? 'find_workshops'.tr : null,
      onButtonPressed: onStartChat,
    );
  }
}

class SearchNoResults extends StatelessWidget {
  final String? searchTerm;
  final VoidCallback? onClearSearch;

  const SearchNoResults({
    super.key,
    this.searchTerm,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'no_results_found'.tr,
      subtitle: searchTerm != null
          ? 'no_results_for_search'.tr.replaceAll('{searchTerm}', searchTerm!)
          : 'no_results_try_different'.tr,
      buttonText: onClearSearch != null ? 'clear_search'.tr : null,
      onButtonPressed: onClearSearch,
    );
  }
}