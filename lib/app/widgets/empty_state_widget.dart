import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Widget? customAction;

  const EmptyStateWidget({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonPressed,
    this.customAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.lightGrey,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: AppSizes.iconXLarge,
                color: AppColors.mediumGrey,
              ),
            ),
            SizedBox(height: AppSizes.spaceLarge),
            Text(
              title,
              style: TextStyle(
                fontSize: AppSizes.titleMedium,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppSizes.spaceSmall),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppSizes.textLarge,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              SizedBox(height: AppSizes.spaceLarge),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSizes.spaceLarge,
                    vertical: AppSizes.spaceMedium,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonBorderRadius,
                    ),
                  ),
                ),
              ),
            ],
            if (customAction != null) ...[
              SizedBox(height: AppSizes.spaceLarge),
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

  const NoServicesFound({Key? key, this.onRefresh}) : super(key: key);

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

  const NoWorkshopsFound({Key? key, this.onRefresh}) : super(key: key);

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

  const NoSavedServices({Key? key, this.onBrowse}) : super(key: key);

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

  const NoChatsFound({Key? key, this.onStartChat}) : super(key: key);

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
    Key? key,
    this.searchTerm,
    this.onClearSearch,
  }) : super(key: key);

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