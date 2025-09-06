import 'package:flutter/material.dart';
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
      title: 'No Services Found',
      subtitle: 'No automotive services are available at the moment.',
      buttonText: onRefresh != null ? 'Refresh' : null,
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
      title: 'No Workshops Found',
      subtitle: 'No workshops are available in your area.',
      buttonText: onRefresh != null ? 'Refresh' : null,
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
      title: 'No Saved Services',
      subtitle: 'You haven\'t saved any services yet. Browse services to save your favorites.',
      buttonText: onBrowse != null ? 'Browse Services' : null,
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
      title: 'No Conversations',
      subtitle: 'You don\'t have any conversations yet. Start chatting with workshop owners.',
      buttonText: onStartChat != null ? 'Find Workshops' : null,
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
      title: 'No Results Found',
      subtitle: searchTerm != null
          ? 'No results found for "$searchTerm". Try different keywords.'
          : 'No results found. Try different search terms.',
      buttonText: onClearSearch != null ? 'Clear Search' : null,
      onButtonPressed: onClearSearch,
    );
  }
}