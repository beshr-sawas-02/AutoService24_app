import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en': {
          'user_deleted_successfully': 'User deleted successfully',
          'reset_password': 'Reset Password',
          'forgot_password': 'Forgot Password?',
          'enter_email_reset':
              'Enter your email address to reset your password',
          'set_new_password': 'Set New Password',
          'create_new_password': 'Create a new password for your account',
          'reset_complete': 'Reset Complete',
          'password_reset_success': 'Your password has been successfully reset',
          'email_address': 'Email Address',
          'enter_registered_email': 'Enter your registered email',
          'verify_email_info':
              'We\'ll verify your email and allow you to set a new password.',
          'new_password': 'New Password',
          'enter_new_password': 'Enter your new password',
          'confirm_new_password': 'Confirm New Password',
          'confirm_new_password_hint': 'Confirm your new password',
          'password_requirements': 'Password Requirements:',
          'at_least_6_characters': 'At least 6 characters',
          'contains_letters_numbers': 'Contains letters and numbers',
          'no_spaces_allowed': 'No spaces allowed',
          'password_reset_successful': 'Password Reset Successful!',
          'password_updated_success':
              'Your password has been successfully updated. You can now login with your new password.',
          'verify_email': 'Verify Email',
          'go_to_login': 'Go to Login',
          'remember_password': 'Remember your password? ',

          // Login translations
          'login': 'Login',
          'welcome_back': 'Welcome Back!',
          'sign_in_account': 'Sign in to your account',
          'continue_with_google': 'Continue with Google',
          'continue_with_facebook': 'Continue with Facebook',
          'continue_with_apple': 'Continue with Apple',
          'or_continue_email': 'or continue with email',
          'email': 'Email',
          'password': 'Password',
          'forgot_password_link': 'Forgot Password?',
          'dont_have_account': 'Don\'t have an account? ',
          'sign_up': 'Sign Up',
          'continue_as_guest': 'Continue as Guest',
          'login_as': 'Login as:',
          'regular_user': 'Regular User',
          'workshop_owner': 'Workshop Owner',
          'enter_email': 'Enter your email',
          'enter_password': 'Enter your password',
          'please_enter_email': 'Please enter your email',
          'please_enter_valid_email': 'Please enter a valid email',
          'please_enter_password': 'Please enter your password',

          // Register translations
          'create_account': 'Create Account',
          'join_community': 'Join CarServiceHub community',
          'i_am_a': 'I am a:',
          'looking_for_services': 'Looking for services',
          'providing_services': 'Providing services',
          'username': 'Username',
          'phone_number': 'Phone Number',
          'confirm_password': 'Confirm Password',
          'please_enter_username': 'Please enter your username',
          'username_min_3_chars': 'Username must be at least 3 characters',
          'please_enter_phone': 'Please enter your phone number',
          'please_confirm_password': 'Please confirm your password',
          'passwords_do_not_match': 'Passwords do not match',
          'password_min_6_chars': 'Password must be at least 6 characters',
          'already_have_account': 'Already have an account? ',
          'sign_in': 'Sign In',
          'or_continue_with': 'or continue with',

          // Chat translations
          'messages': 'Messages',
          'connect_service_providers': 'Connect with Service Providers',
          'sign_in_to_chat':
              'Sign in to chat directly with workshops and service providers.',
          'chat_features': 'Chat features:',
          'direct_messaging': 'Direct messaging with providers',
          'schedule_appointments': 'Schedule appointments easily',
          'instant_quotes': 'Get instant price quotes',
          'share_photos': 'Share photos of your vehicle',
          'share_location': 'Share location details',
          'register': 'Register',
          'explore_services_instead': 'Explore Services Instead',
          'no_conversations_yet': 'No conversations yet',
          'start_chatting':
              'Start chatting with workshop owners and service providers',
          'browse_services': 'Browse Services',
          'starting_chat': 'Starting Chat...',
          'creating_chat_with': 'Creating chat with',
          'online': 'Online',
          'offline': 'Offline',
          'feature_coming_soon': 'Feature Coming Soon',
          'voice_call_soon': 'Voice call feature will be available soon',
          'view_service': 'View Service',
          'block_user': 'Block User',
          'report': 'Report',
          'discussing_service': 'Discussing:',
          'start_conversation': 'Start the conversation',
          'ask_about_service': 'Ask about',
          'send_message_begin': 'Send a message to begin chatting',
          'type_message': 'Type a message...',
          'is_typing': 'is typing',
          'connection_lost': 'Connection lost',
          'reconnecting': 'Reconnecting...',
          'are_you_sure_block': 'Are you sure you want to block',
          'block': 'Block',
          'cancel': 'Cancel',
          'report_user': 'Report User',
          'report_inappropriate': 'Report {name} for inappropriate behavior?',
          'user_blocking_soon': 'User blocking feature coming soon',
          'user_reporting_soon': 'User reporting feature coming soon',
          'just_now': 'Just now',
          'minutes_ago': '{minutes}m ago',
          'hours_ago': '{hours}h ago',
          'days_ago': '{days}d ago',

          // Profile translations
          'edit_profile': 'Edit Profile',
          'save': 'Save',
          'personal_information': 'Personal Information',
          'phone': 'Phone',
          'account_type': 'Account Type',
          'user': 'User',
          'save_changes': 'Save Changes',
          'tap_camera_change_photo': 'Tap camera icon to change photo',
          'new_photo_selected': 'New photo selected',
          'profile_updated_successfully': 'Profile updated successfully',

          // Map translations
          'workshop_locations': 'Workshop Locations',
          'view_details': 'View Details',
          'directions': 'Directions',
          'distance': 'Distance:',
          'km': 'km',
          'opening_directions': 'Opening directions to',

          // Service Details translations
          'description': 'Description',
          'workshop_information': 'Workshop Information',
          'workshop_id': 'Workshop ID',
          'service_duration': 'Service Duration',
          'warranty': 'Warranty',
          'reviews': 'Reviews',
          'contact_workshop': 'Contact Workshop',
          'view_workshop': 'View Workshop',
          'login_required': 'Login Required',
          'login_register_access':
              'Please login or register to access this feature.',
          'login_to_save': 'Login to save',
          'remove_from_saved': 'Remove from saved',
          'save_service': 'Save service',
          '1_2_hours': '1-2 hours',
          '30_days': '30 days',

          // Settings translations
          'settings': 'Settings',
          'account': 'Account',
          'change_password': 'Change Password',
          'update_password': 'Update your password',
          'preferences': 'Preferences',
          'push_notifications': 'Push Notifications',
          'receive_notifications':
              'Receive notifications about new messages and updates',
          'location_services': 'Location Services',
          'allow_location': 'Allow app to access your location',
          'dark_mode': 'Dark Mode',
          'use_dark_theme': 'Use dark theme',
          'app': 'App',
          'language': 'Language',
          'about': 'About',
          'app_version_info': 'App version and information',
          'help_support': 'Help & Support',
          'get_help_support': 'Get help and contact support',
          'privacy_policy': 'Privacy Policy',
          'read_privacy_policy': 'Read our privacy policy',
          'terms_of_service': 'Terms of Service',
          'read_terms': 'Read our terms of service',
          'data': 'Data',
          'download_data': 'Download Data',
          'download_copy_data': 'Download a copy of your data',
          'clear_cache': 'Clear Cache',
          'clear_temp_files': 'Clear app cache and temporary files',
          'sign_out': 'Sign Out',
          'settings_saved': 'Settings saved',
          'password_change_implemented':
              'Password change functionality would be implemented here.',
          'change': 'Change',
          'select_language': 'Select Language',
          'english': 'English',
          'arabic': 'Arabic',
          'german': 'German',
          'french': 'French',
          'spanish': 'Spanish',
          'about_autoservice': 'About AutoService24',
          'version': 'Version: 1.0.0',
          'car_service_partner': 'Your Car Service Partner',
          'find_book_services': 'Find and book automotive services near you.',
          'copyright': '© 2024 AutoService24. All rights reserved.',
          'ok': 'OK',
          'need_help_contact': 'Need help? Contact us:',
          'support_email': 'support@autoservice24.com',
          'support_phone': '+1 (555) 123-4567',
          'privacy_displayed_here': 'Privacy Policy would be displayed here',
          'terms_displayed_here': 'Terms of Service would be displayed here',
          'data_download_implemented':
              'Data download functionality would be implemented here',
          'are_you_sure_clear_cache':
              'Are you sure you want to clear the app cache? This will remove temporary files and may slow down the app initially.',
          'clear': 'Clear',
          'cache_cleared': 'Cache cleared successfully',
          'are_you_sure_sign_out': 'Are you sure you want to sign out?',

          // Workshop Details translations
          'workshop_info': 'Workshop Information',
          'working_hours': 'Working Hours',
          'location': 'Location',
          'rating_reviews': '4.5 (24 reviews)',
          'view_reviews': 'View Reviews',
          'services': 'Services',
          'view_all': 'View All',
          'no_services_available': 'No services available',
          'workshop_no_services':
              'This workshop hasn\'t added any services yet',
          'starting_conversation': 'Starting conversation with',
          'login_contact_workshops':
              'Please login or register to contact workshops.',

          // Add Service translations
          'add_service': 'Add Service',
          'create_new_service': 'Create New Service',
          'select_workshop': 'Select Workshop',
          'create_workshop_first':
              'You need to create a workshop first before adding services.',
          'service_title': 'Service Title',
          'service_type': 'Service Type',
          'price_usd': 'Price (\€)',
          'service_images': 'Service Images',
          'add_images': 'Add Images',
          'create_service': 'Create Service',
          'please_select_workshop': 'Please select a workshop',
          'service_created_successfully': 'Service created successfully!',
          'failed_create_service': 'Failed to create service',

          // Add Workshop translations
          'add_workshop': 'Add Workshop',
          'create_your_workshop': 'Create Your Workshop',
          'workshop_name': 'Workshop Name',
          'please_enter_workshop_name': 'Please enter workshop name',
          'please_enter_description': 'Please enter description',
          'working_hours_example': 'Working Hours (e.g., 8:00 AM - 6:00 PM)',
          'please_enter_working_hours': 'Please enter working hours',
          'workshop_location': 'Workshop Location',
          'tap_map_select_location':
              'Tap on the map to select your workshop location',
          'location_selected': 'Location selected:',
          'please_select_location': 'Please select a location on the map',
          'create_workshop': 'Create Workshop',
          'workshop_created_successfully': 'Workshop created successfully!',

          // Owner Home translations
          'carservicehub_owner': 'CarServiceHub - Owner',
          'home': 'Home',
          'profile': 'Profile',
          'hello_user': 'Hello {name}',
          'service_categories': 'Service Categories',
          'vehicle_inspection': 'Vehicle\nInspection',
          'change_oil': 'Change Oil',
          'change_tires': 'Change Tires',
          'remove_install_tires': 'Remove & Install\nTires',
          'cleaning': 'Cleaning',
          'diagnostic_test': 'Diagnostic Test',
          'pre_tuv_check': 'Pre-TÜV Check',
          'balance_tires': 'Balance Tires',
          'wheel_alignment': 'Wheel\nAlignment',
          'polish': 'Polish',
          'change_brake_fluid': 'Change Brake\nFluid',
          'logout': 'Logout',
          'are_you_sure_logout': 'Are you sure you want to logout?',

          // Owner Profile translations
          'contact_information': 'Contact Information',
          'not_provided': 'Not provided',
          'workshops': 'Workshops',
          'total_services': 'Total Services',
          'total_reviews': 'Total Reviews',
          'delete_account': 'Delete Account',
          'are_you_sure_sign_out_account':
              'Are you sure you want to sign out of your account?',
          'delete_confirmation_title': 'Delete Account',
          'this_will_permanently_delete': 'This will permanently delete:',
          'your_account': 'Your account',
          'all_workshops': 'All workshops',
          'all_services': 'All services',
          'all_conversations': 'All conversations',
          'all_business_data': 'All business data',
          'action_cannot_be_undone': 'This action cannot be undone.',
          'delete': 'Delete',
          'final_confirmation': 'Final Confirmation',
          'type_delete_confirm': 'Type "DELETE" to confirm account deletion:',
          'type_delete_here': 'Type DELETE here',
          'confirm_delete': 'Confirm Delete',
          'please_type_delete': 'Please type "DELETE" to confirm',
          'help_support_title': 'Help & Support',
          'mon_fri_hours': 'Mon-Fri: 9 AM - 6 PM',
          'about_carservicehub': 'About CarServiceHub',
          'your_car_service_partner': 'Your Car Service Partner',
          'connecting_workshops':
              'Connecting workshop owners with customers for easy automotive service management.',
          'carservicehub_rights': '© 2024 CarServiceHub. All rights reserved.',

          // Filtered Services translations
          'tune': 'Tune',
          'no_services_found': 'No services found',
          'no_services_for_category': 'No services available for',
          'havent_created_services': 'You haven\'t created any services for',
          'refresh': 'Refresh',
          'saved': 'Saved',
          'chat': 'Chat',
          'cannot_chat_yourself': 'You cannot chat with yourself',
          'workshop_not_found': 'Workshop not found',
          'failed_start_chat': 'Failed to start chat. Please try again.',

          // Saved Services translations
          'saved_services': 'Saved Services',
          'save_favorite_services': 'Save Your Favorite Services',
          'create_account_save':
              'Create an account to save services you love and access them anytime, anywhere.',
          'with_your_account': 'With your account:',
          'save_unlimited_services': 'Save unlimited services',
          'sync_all_devices': 'Sync across all devices',
          'track_service_history': 'Track your service history',
          'direct_chat_providers': 'Direct chat with providers',
          'loading_saved_services': 'Loading your saved services...',
          'no_saved_services': 'No Saved Services Yet',
          'start_exploring_save':
              'Start exploring services and save the ones you like for quick access later.',
          'explore_services': 'Explore Services',
          'remove_service': 'Remove Service',
          'remove_service_confirmation':
              'Are you sure you want to remove this service from your saved list?',
          'remove': 'Remove',
          'service_unavailable': 'Service Unavailable',
          'service_removed_unavailable':
              'This service may have been removed or is temporarily unavailable.',
          'saved_date': 'Saved {date}',
          'recently': 'recently',

          // User Home translations
          'auto_services': 'Auto Services',
          'categories': 'Categories',
          'search_categories': 'Search categories...',
          'failed_refresh_services': 'Failed to refresh services',

          // User Profile translations
          'guest_user': 'Guest User',
          'browsing_as_guest': 'You\'re browsing as a guest',
          'login_to_account': 'Login to Your Account',
          'create_new_account': 'Create New Account',
          'my_workshop': 'My Workshop',
          'manage_workshop': 'Manage your workshop',
          'my_services': 'My Services',
          'manage_services': 'Manage your services',
          'workshop_management_soon': 'Workshop management coming soon',
          'service_management_soon': 'Service management coming soon',
          'permanently_delete_account':
              'This will permanently delete your account and all data. This action cannot be undone.',
          'failed_delete_account':
              'Failed to delete account. Please try again.',

          // Guest banner
          'login_register_save_chat':
              'Login or register to save services, chat with workshops, and access more features.',

          // Language switcher
          'switch_language': 'Switch Language',
          'current_language': 'English',

          // New keys for UserHomeView
          'error': 'Error',
          'failed_remove_service':
              'Failed to remove service. Please try again.',
          'error_occurred_try_again': 'An error occurred. Please try again.',
          'service_image': 'Service Image',
          'user_not_logged_in': 'User not logged in',
          'info': 'Info',
          'view_location': 'View Location',
          'delete_service': 'Delete Service',
          'unknown_workshop': 'Unknown Workshop',
          'confirm_delete_service':
              'Are you sure you want to delete this service?',
          'deleted': 'Deleted',
          'service_deleted_successfully': 'Service deleted successfully',
          'failed_delete_service':
              'Failed to delete service. Please try again.',
          'error_deleting_service':
              'An error occurred while deleting the service.',
          'update_personal_information': 'Update your personal information',
          'success': 'Success',
          'please_enter_service_title': 'Please enter service title',
          'please_enter_valid_price': 'Please enter a valid price',
          'more_images': 'More Images',
          'contact_workshop_message':
              'This feature will open a chat with the workshop owner',
          'chat_information_missing': 'Chat information is missing',
          'unknown_user': 'Unknown User',
          'invalid_chat_information':
              'Invalid chat information. Missing required data.',
          'failed_create_chat': 'Failed to create chat',
          'ready_to_send': 'Ready to send',
          'uploading_image': 'Uploading image...',
          'add_caption': 'Add a caption...',
          'select_attachment': 'Select Attachment',
          'file': 'File',
          'file_attachment_soon': 'File attachment will be available soon',
          'failed_load_image': 'Failed to load image',
          'camera_error': 'Camera Error',
          'camera_permission_error':
              'Unable to access camera. Please enable camera permission in device settings.',
          'gallery_error': 'Gallery Error',
          'gallery_permission_error':
              'Unable to access gallery. Please enable storage permission in device settings.',
          'failed_send_message': 'Failed to send message',
          'camera': 'Camera',
          'gallery': 'Gallery',
          'forgot_password_question': 'Forgot Password?',
          'reset_password_button': 'Reset Password',
          'contact_workshop_button': 'Contact Workshop',
          'view_workshop_button': 'View Workshop',
          'image_counter': '{current} of {total}',
          'scroll_to_top': 'Scroll to top',
          'search': 'Search',
          'current_location': 'Current Location',
          'map_initialization_error': 'Map Initialization Error',
          'annotation_setup_error': 'Annotation Setup Error',
          'getting_location': 'Getting your location...',
          'markers_load_error': 'Error loading markers',
          'back_to_services': 'Back to Services',
          'navigation_error': 'Navigation Error',
          'map_not_ready': 'Map not ready',
          'current_location_not_found': 'Current location not found',
          'loading': 'Loading',
          'creating_route': 'Creating route...',
          'route_creation_error': 'Route Creation Error',
          'navigation_to': 'Navigation to',
          'estimated_time': 'Estimated Time',
          'start_navigation': 'Start Navigation',
          'clear_route': 'Clear Route',
          'navigation_started': 'Navigation Started',
          'navigating_to': 'Navigating to',
          'route_cleared': 'Route cleared',
          'image_selected_successfully': 'Image selected successfully',
          'failed_to_select_image': 'Failed to select image',
          'user_not_found': 'User not found',
          'failed_to_update_profile': 'Failed to update profile',
          'service': 'Service',
          'failed_to_load_image': 'Failed to load image',
          'empty_image_path': 'Empty image path',
          'network_error': 'Network error',
          'file_not_found': 'File not found',
          'invalid_image_path': 'Invalid image path',
          'search_on_map': 'Search on Map',
          'workshop_location_not_available': 'Workshop location not available',
          'workshop_location_not_set': 'Workshop location not set',
          'failed_to_open_workshop_location':
              'Failed to open workshop location',
          'no_location': 'No Location',
          'image_not_available': 'Image not available',
          'asset_not_found': 'Asset not found',
          'invalid_path': 'Invalid path',
          'find_nearby_workshops': 'Find Nearby Workshops',
          'search_workshops_by_location': 'Search workshops by location',
          'open_map_search': 'Open Map Search',
          'edit': 'Edit',
          'save_service_title': 'Save Service',
          'save_service_description':
              'Create an account to save your favorite services and access them anytime.',
          'no_workshops_found': 'No Workshops Found',
          'no_workshops_available': 'No workshops are available in your area.',
          'no_conversations': 'No Conversations',
          'no_conversations_subtitle':
              'You don\'t have any conversations yet. Start chatting with workshop owners.',
          'find_workshops': 'Find Workshops',
          'no_results_found': 'No Results Found',
          'no_results_for_search':
              'No results found for "{searchTerm}". Try different keywords.',
          'no_results_try_different':
              'No results found. Try different search terms.',
          'clear_search': 'Clear Search',
          'no_saved_services_subtitle':
              'You haven\'t saved any services yet. Browse services to save your favorites.',
          'youre_browsing_as_guest': 'You\'re browsing as a guest',
          'login_register_for_features':
              'Login or register to save services, chat with workshops, and access more features.',
          'select_service_type': 'Select Service Type',
          'tap_search_to_find_workshops': 'Tap search to find workshops',
          'select_service_type_first': 'Select service type first',
          'nearby_workshops': 'Nearby Workshops',
          'select_location_and_service': 'Select location and service type',
          'search_complete': 'Search Complete',
          'found_workshops': 'Found {count} workshops',
          'no_workshops_found_in_area': 'No workshops found in this area',
          'search_failed': 'Search failed',
          'opening_directions_to': 'Opening directions to',
          'view_location_on_map': 'View Location on Map',
          'focus_on_workshop': 'Focus on Workshop',
          'search_nearby_workshops': 'Search Nearby Workshops',
          'workshop_search_radius': 'Search Radius',
          'local': 'Local',
          'city': 'City',
          'region': 'Region',
          'national': 'National',
          'select_location': 'Select Location',
          'confirm': 'Confirm',
          'tap_map_to_select_workshop_location':
              'Tap on the map to select workshop location',
          'location_selected_successfully': 'Location Selected Successfully',
          'coordinates': 'Coordinates',
          'confirm_location': 'Confirm Location',
          'tap_confirm_or_select_another':
              'Tap confirm or select another location',
          'workshop_location_selected': 'Workshop Location Selected',
          'tap_to_open_map': 'Tap to open map',
          'select_workshop_location': 'Select Workshop Location',
          'cannot_get_current_location': 'Cannot get current location',
          'enter_verification_code': 'Enter Verification Code',
          'code_sent_to_email': 'We sent a 6-digit code to your email address',
          'verification_code': 'Verification Code',
          'enter_6_digit_code': 'Enter the 6-digit code',
          'send_verification_code': 'Send Verification Code',
          'verify_code': 'Verify Code',
          'resend_code': 'Resend Code',
          'verification_code_sent': 'Verification code sent successfully',
          'verification_code_sent_successfully':
              'Verification code sent to your email',
          'code_verified_successfully': 'Code verified successfully',
          'verification_code_required': 'Verification code is required',
          'code_must_be_6_digits': 'Code must be 6 digits',
          'code_must_be_numbers_only': 'Code must contain numbers only',
          'contact_workshop_owner': 'Contact Workshop Owner',
          'getting_phone_number': 'Getting phone number...',
          'cannot_open_phone_app': 'Cannot open phone app',
          'phone_number_not_available': 'Phone number not available',
          'error_getting_phone_number': 'Error getting phone number',
          'email_verification': 'Email Verification',
          'check_your_email': 'Check Your Email',
          'verification_sent_description':
              'A verification link has been sent to your email address. Please click on the link to activate your account.',
          'next_steps': 'Next Steps',
          'open_gmail_app': 'Open Gmail app or your email client',
          'find_verification_email':
              'Find verification email from AutoService24',
          'click_verify_button': 'Click on "Verify Email" button',
          'return_to_login': 'Return to login screen',
          'check_spam_folder':
              'If you don\'t see the email, please check your spam folder',
          'back_to_login': 'Back to Login',
          'create_different_account': 'Create Different Account',
          'app_name': 'Auto Service 24',
          'last_updated': 'Last Updated',
          'accept_privacy_policy': 'Accept Privacy Policy',

          // Introduction Section
          'privacy_intro_title': 'Introduction',
          'privacy_intro_content':
              'Welcome to Auto Service 24. We are committed to protecting your privacy and personal data. This privacy policy explains how we collect, use, and protect your personal information when using our app.\n\nBy using Auto Service 24, you agree to the information collection and use practices described in this policy.',

          // Data Collection Section
          'privacy_data_collection_title': 'Data We Collect',
          'privacy_data_collection_content':
              'We collect the following types of data to provide our services:',
          'privacy_data_personal_info':
              'Personal information: name, email address, phone number',
          'privacy_data_account_info':
              'Account information: username and encrypted password',
          'privacy_data_location': 'Geographic location data (with consent)',
          'privacy_data_files': 'Images and files you upload',
          'privacy_data_messages': 'Messages and conversations within the app',
          'privacy_data_device_info':
              'Device information and operating system type',
          'privacy_data_usage': 'App usage data and saved services',

          // Data Usage Section
          'privacy_data_usage_title': 'How We Use Your Data',
          'privacy_data_usage_content':
              'We use the collected data for the following purposes:',
          'privacy_usage_provide_services': 'Provide and operate app services',
          'privacy_usage_manage_accounts': 'Create and manage your accounts',
          'privacy_usage_find_workshops': 'Find workshops near your location',
          'privacy_usage_communication':
              'Facilitate communication between users and workshop owners',
          'privacy_usage_improve_app': 'Improve app quality and performance',
          'privacy_usage_notifications':
              'Send important service-related notifications',
          'privacy_usage_security':
              'Ensure security and prevent unauthorized use',

          // Data Sharing Section
          'privacy_data_sharing_title': 'Data Sharing',
          'privacy_data_sharing_content':
              'We do not sell or rent your personal data to third parties. We may share your information only in the following cases:',
          'privacy_sharing_workshops':
              'With workshop owners to facilitate communication and service',
          'privacy_sharing_legal': 'When required to comply with local laws',
          'privacy_sharing_rights': 'To protect our rights and users\' rights',
          'privacy_sharing_emergency':
              'In emergency situations to ensure safety',

          // Location Data Section
          'privacy_location_title': 'Geographic Location Data',
          'privacy_location_content':
              'We use Mapbox services to provide mapping and location services. Location data is collected only with permission and is used for:',
          'privacy_location_find_nearby':
              'Finding nearby workshops and services',
          'privacy_location_distance':
              'Determining distances and estimated arrival times',
          'privacy_location_maps': 'Displaying maps and directions',
          'privacy_location_search_accuracy':
              'Improving search result accuracy',
          'privacy_location_disable_info':
              'You can disable location sharing at any time from app or device settings',

          // Security Section
          'privacy_security_title': 'Data Security',
          'privacy_security_content':
              'We implement comprehensive security measures to protect your data:',
          'privacy_security_encryption': 'Encrypt passwords and sensitive data',
          'privacy_security_https':
              'Use HTTPS protocols for secure communications',
          'privacy_security_servers': 'Store data on protected servers',
          'privacy_security_monitoring':
              'Continuous monitoring for suspicious activities',
          'privacy_security_updates': 'Regular security system updates',
          'privacy_security_training': 'Train staff on security best practices',

          // User Rights Section
          'privacy_rights_title': 'Your Rights',
          'privacy_rights_content':
              'You have the following rights regarding your personal data:',
          'privacy_rights_access': 'Access your stored data',
          'privacy_rights_correct': 'Correct or update incorrect information',
          'privacy_rights_delete': 'Delete your account and data permanently',
          'privacy_rights_withdraw': 'Withdraw consent for data processing',
          'privacy_rights_restrict':
              'Restrict or object to the use of your data',
          'privacy_rights_copy': 'Obtain a copy of your data',

          // Storage Section
          'privacy_storage_title': 'Local Storage',
          'privacy_storage_content':
              'The app uses local storage on your device to save:',
          'privacy_storage_settings': 'App settings and selected language',
          'privacy_storage_login': 'Login information (encrypted)',
          'privacy_storage_cache': 'Temporary data to improve performance',
          'privacy_storage_favorites': 'Services saved in favorites',

          // Third Party Section
          'privacy_third_party_title': 'External Services',
          'privacy_third_party_content':
              'The app integrates with the following external services:',
          'privacy_third_party_mapbox_desc': 'For maps and geographic location',
          'privacy_third_party_note':
              'These services are subject to their own privacy policies. We recommend reviewing their policies for detailed information.',

          // Data Retention Section
          'privacy_retention_title': 'Data Retention',
          'privacy_retention_content':
              'We retain your personal data for the time necessary to provide our services or as required by law:',
          'privacy_retention_account':
              'Account data: throughout the account\'s active period',
          'privacy_retention_messages':
              'Messages and conversations: until deleted by you',
          'privacy_retention_location':
              'Location data: stored temporarily only for service',
          'privacy_retention_activity': 'Activity logs: maximum one year',

          // Minors Section
          'privacy_minors_title': 'Protection of Minors',
          'privacy_minors_content':
              'The app is intended for users aged 18 and above. We do not knowingly collect personal information from children under 18 years of age. If we learn that we have collected personal information from a minor, we will take immediate steps to delete that information.',

          // Policy Changes Section
          'privacy_changes_title': 'Policy Updates',
          'privacy_changes_content':
              'We may update this privacy policy from time to time. We will notify you of any important changes through:',
          'privacy_changes_notification': 'In-app notification',
          'privacy_changes_email': 'Email message (if you have an account)',
          'privacy_changes_date':
              'Updating the "Last Updated" date at the top of this page',
          'privacy_changes_notice':
              'Continued use of the app after updates means you agree to the new policy.',

          // Contact Section
          'privacy_contact_title': 'Contact Us',
          'privacy_contact_content':
              'If you have any questions or concerns about this privacy policy or our data practices, please contact us via:',
          'privacy_contact_email': 'Email',
          'privacy_contact_phone': 'Phone',
          'privacy_contact_address': 'Address',
          'privacy_contact_address_value': 'Kingdom of Saudi Arabia',
          'i_agree_to': 'I agree to the ',
          'privacy_terms_agreement':
              'You must agree to the Privacy Policy and Terms of Use to continue',
          'agree_to': 'I agree to ',
          'and': ' and ',
          'terms_of_use': 'Terms of Use',
          'terms_page_coming_soon': 'Terms of Use page will be available soon',
          'privacy_policy_subtitle': 'See how your data is protected',
          'by_continuing_you_agree': 'By continuing, you agree to',
          'privacy_policy_accepted_successfully':
              'Privacy policy accepted successfully',
          'failed_to_accept_privacy_policy': 'Failed to accept privacy policy',
          'privacy_consent_revoked': 'Privacy consent has been revoked',
          'failed_to_revoke_consent': 'Failed to revoke consent',
          'privacy_not_accepted': 'Privacy policy not accepted',
          'privacy_needs_update': 'Privacy policy needs update',
          'privacy_accepted': 'Privacy policy accepted',
          'not_accepted': 'Not accepted',
          'privacy_required_for_operation':
              'You must accept the privacy policy to use this feature',

          // Privacy Policy View Headers
          'privacy_policy_title': 'Privacy Policy & Terms',
          'privacy_policy_header': 'Privacy & Terms of Service',
          'privacy_commitment':
              'We are committed to protecting your privacy and ensuring the security of your personal information while you use Auto Service 24.',
          'important_notice': 'Important Notice',
          'privacy_introduction':
              'This privacy policy explains how Auto Service 24 collects, uses, and protects your information when you use our automotive service platform. By using our services, you agree to the collection and use of information in accordance with this policy.',

          // Main Content Sections
          'information_we_collect_title': 'Information We Collect',
          'information_we_collect_content':
              '''We collect the following types of information:

• Personal Information: Name, email address, phone number, and profile photo when you create an account
• Location Data: Your current location to find nearby workshops and calculate distances (with your permission)
• Service Requests: Details about automotive services you request, including vehicle information and service history
• Communication Data: Messages exchanged between you and workshop owners through our chat system
• Device Information: Device type, operating system, and app version for technical support
• Usage Analytics: How you interact with our app to improve user experience

We only collect information that is necessary to provide our services effectively.''',

          'how_we_use_title': 'How We Use Your Information',
          'how_we_use_content': '''Your information is used to:

• Connect you with qualified automotive service providers in your area
• Process and manage your service requests
• Enable secure communication between customers and workshop owners
• Send important notifications about your service requests
• Improve our app functionality and user experience
• Provide customer support when needed
• Ensure platform security and prevent fraud
• Comply with legal obligations

We never use your personal information for advertising to third parties.''',

          'location_services_title': 'Location Services',
          'location_services_content':
              '''Location information is essential for our core services:

• Finding nearby workshops and service providers
• Calculating accurate distances and estimated arrival times
• Providing location-based service recommendations
• Enabling workshop owners to locate customers when needed

You can control location permissions in your device settings. However, disabling location services may limit some app functionality. We only access your location when you're actively using the app or have a pending service request.''',

          'data_sharing_title': 'Information Sharing',
          'data_sharing_content':
              '''We share your information only when necessary:

With Workshop Owners:
• Your name and contact information when you request services
• Your location (with permission) for service delivery
• Service history relevant to your current request

With Service Providers:
• Maps and navigation services for location features
• Cloud storage providers for data backup
• Analytics tools for app performance monitoring

Legal Requirements:
• When required by law enforcement or legal proceedings
• To protect our rights, property, or safety of users

We never sell your personal information to third parties for marketing purposes.''',

          'data_security_title': 'Data Security',
          'data_security_content': '''We implement multiple security measures:

• End-to-end encryption for sensitive communications
• Secure servers with regular security updates
• Multi-factor authentication options
• Regular security audits and vulnerability assessments
• Data backup and recovery systems

While we use industry-standard security measures, no system is 100% secure. We encourage users to use strong passwords and keep their devices updated.''',

          'your_rights_title': 'Your Rights and Choices',
          'your_rights_content': '''You have the right to:

• Access and review your personal information
• Update or correct your account details at any time
• Delete your account and associated data
• Download your data in a portable format
• Opt out of non-essential communications
• Control location sharing permissions
• Request information about how your data is used

To exercise these rights, contact us at privacy@autoservice24.com or use the account settings in the app.''',

          'third_party_title': 'Third-Party Services',
          'third_party_content':
              '''Our app integrates with trusted third-party services:


• Mapbox: For mapping and location services
• Analytics Tools: For app performance monitoring

These services have their own privacy policies. We recommend reviewing them:
• Mapbox Privacy Policy: mapbox.com/legal/privacy
• We only share the minimum necessary information with these services.''',

          'children_privacy_title': 'Children\'s Privacy',
          'children_privacy_content':
              '''Auto Service 24 is intended for users 18 years and older. We do not knowingly collect personal information from children under 18. If we discover that a child has provided us with personal information, we will delete it immediately. If you believe a child has provided us with information, please contact us at privacy@autoservice24.com.''',

          'terms_of_service_title': 'Terms of Service',
          'terms_of_service_content': '''By using Auto Service 24, you agree to:

Acceptable Use:
• Use the service only for legitimate automotive service needs
• Provide accurate information in your profile and service requests
• Treat workshop owners and other users with respect
• Not use the platform for illegal activities or fraud

Service Availability:
• Services are provided "as is" without warranties
• We may temporarily suspend service for maintenance
• Workshop owners set their own service details and availability

Communication:
• Direct communication between users and workshop owners
• Messages are stored securely and can be deleted by users
• Users are responsible for their own service arrangements

Limitation of Liability:
• Auto Service 24 connects customers with service providers but is not responsible for the quality of services performed
• We are not liable for damages arising from service interactions
• Users arrange services directly with workshop owners
• Our liability is limited to the maximum extent permitted by law

Termination:
• You may delete your account at any time
• We may suspend accounts that violate these terms
• Deleted accounts and data are permanently removed within 30 days''',

          'contact_us_title': 'Contact Us',
          'contact_privacy_text':
              'If you have questions about this privacy policy, your data rights, or our data practices, please contact our privacy team. We respond to all inquiries within 48 hours.',

          'last_updated_title': 'Last Updated',
          'version_label': 'Version',
          'current_label': 'Current',

          // Action Buttons
          'accept_privacy_policy_button': 'Accept Privacy Policy & Terms',
          'privacy_policy_accepted_status': 'Privacy Policy Accepted',

          // Register Form
          'privacy_policy_accepted_short': 'Privacy policy accepted',

          // Profile
          'privacy_security': 'Privacy & Security',
          'view_privacy_policy': 'View privacy policy and terms',
          'accept': 'Accept',

          // Additional translations
          'your_reliable_auto_service_partner':
              'Your reliable auto service partner',
          'version_1_0': 'Version 1.0',
          'account_created_and_verified':
              'Account created and verified successfully',
          'account_created_verify_email':
              'Account created! Please verify your email',
          'invalid_server_response': 'Invalid server response',
          'registration_failed': 'Registration failed',
          'login_to_manage_privacy': 'Login to manage privacy settings',
          "delete_chat": "Delete Chat",
          "are_you_sure_delete_chat":
              "Are you sure you want to delete this chat?",
          "show_results": "Show Results",
          'tap_to_view_conversation': 'Tap to view conversation',
          'retry': 'Retry',

          // Connection errors
          'connection_timeout': 'Connection timeout. Check your internet',
          'request_timeout': 'Request timeout. Try again',
          'server_timeout': 'Server response timeout. Try again',
          'connection_error': 'Connection error. Check your internet',
          'request_cancelled': 'Request cancelled',
          'unexpected_error': 'An unexpected error occurred',
          'something_went_wrong': 'Something went wrong. Please try again',

          // HTTP errors
          'bad_request': 'Bad request. Check your input',
          'unauthorized_login_again': 'Session expired. Please login again',
          'access_forbidden': 'You don\'t have permission for this action',
          'resource_not_found': 'Content not found',
          'resource_already_exists': 'Item already exists',
          'invalid_data_provided': 'Invalid data provided',
          'too_many_requests': 'Too many requests. Try later',
          'server_error': 'Server issue. Try later',
          'bad_gateway': 'Server temporarily unavailable',
          'gateway_timeout': 'Gateway timeout',
          'server_error_occurred': 'Server error occurred',

          // Data errors
          'invalid_data_format': 'Invalid data format',
          'data_type_error': 'Data type error',

          // Other messages
          'validation_error': 'Validation error',
          'session_expired': 'Session expired. Please login again',

          // Service actions
          'removed_unavailable_services':
              '{count} unavailable services removed',
          'service_already_saved': 'Service is already saved',
          'service_saved_successfully': 'Service saved successfully',
          'service_already_in_list': 'Service is already in your saved list',
          'service_removed_successfully': 'Service removed from saved',
          'images_uploaded_successfully': 'Images uploaded successfully',
          'service_updated_successfully': 'Service updated successfully',

          // Chat actions
          'image_sent_successfully': 'Image sent successfully',
          'message_deleted_successfully': 'Message deleted successfully',
          'chat_deleted_successfully': 'Chat deleted successfully',

          // Auth actions
          'verify_account_first':
              'Please verify your account first. Check your email',
          'login_successful': 'Login successful',
          'login_failed_check_credentials':
              'Login failed. Check your email and password',
          'profile_image_updated_successfully':
              'Profile image updated successfully',
          'google_signin_cancelled': 'Google sign in cancelled',
          'facebook_signin_failed': 'Facebook sign in failed',
          'logged_out_successfully': 'Logged out successfully',
          'account_deleted_successfully': 'Account deleted successfully',
          'unable_to_delete_account': 'Unable to delete account',
          'password_updated_successfully': 'Password updated successfully',
          'workshop_updated_successfully': 'Workshop updated successfully',
          'workshop_deleted_successfully': 'Workshop deleted successfully',
          'my_workshops': 'My Workshops',
          'loading_workshops': 'Loading workshops...',
          'no_workshops_yet': 'No workshops yet',
          'create_first_workshop':
              'Create your first workshop to start offering services',
          'no_address': 'No address',
          'view_services': 'View Services',
          'edit_workshop': 'Edit Workshop',
          'delete_workshop': 'Delete Workshop',
          'services_count': 'Services',
          'confirm_delete_workshop':
              'Are you sure you want to delete this workshop?',
          'workshop_services_will_be_deleted':
              '{count} services will be permanently deleted',
          'deleting_workshop': 'Deleting workshop...',
          'please_wait': 'Please wait',
          'edit_workshop_info': 'Edit Workshop Info',
          'enter_workshop_name': 'Enter workshop name',
          'enter_workshop_description': 'Enter workshop description',
          'enter_working_hours': 'e.g., Mon-Fri: 9AM-6PM',
          'workshop_name_required': 'Workshop name is required',
          'workshop_description_required': 'Workshop description is required',
          'working_hours_required': 'Working hours is required',
          'manage_workshops_services': 'Manage your workshops and services',
        },
        'de': {
          'user_deleted_successfully': 'Benutzer erfolgreich gelöscht',
          'tap_to_view_conversation': 'Tippen, um die Unterhaltung anzuzeigen',
          "show_results": "Ergebnisse anzeigen",
          "delete_chat": "Chat löschen",
          "are_you_sure_delete_chat":
              "Möchten Sie diesen Chat wirklich löschen?",
          'login_to_manage_privacy':
              'Anmelden, um Datenschutzeinstellungen zu verwalten',
          'privacy_policy_accepted_successfully':
              'Datenschutzrichtlinie erfolgreich akzeptiert',
          'failed_to_accept_privacy_policy':
              'Fehler beim Akzeptieren der Datenschutzrichtlinie',
          'privacy_consent_revoked':
              'Datenschutz-Einwilligung wurde widerrufen',
          'failed_to_revoke_consent': 'Fehler beim Widerrufen der Einwilligung',
          'privacy_not_accepted': 'Datenschutzrichtlinie nicht akzeptiert',
          'privacy_needs_update': 'Datenschutzrichtlinie benötigt Update',
          'privacy_accepted': 'Datenschutzrichtlinie akzeptiert',
          'not_accepted': 'Nicht akzeptiert',
          'privacy_required_for_operation':
              'Sie müssen die Datenschutzrichtlinie akzeptieren, um diese Funktion zu nutzen',

          // Privacy Policy View Headers
          'privacy_policy_title': 'Datenschutzrichtlinie & AGB',
          'privacy_policy_header': 'Datenschutz & Nutzungsbedingungen',
          'privacy_commitment':
              'Wir verpflichten uns, Ihre Privatsphäre zu schützen und die Sicherheit Ihrer persönlichen Daten während der Nutzung von Auto Service 24 zu gewährleisten.',
          'important_notice': 'Wichtiger Hinweis',
          'privacy_introduction':
              'Diese Datenschutzrichtlinie erklärt, wie Auto Service 24 Ihre Informationen sammelt, verwendet und schützt, wenn Sie unsere Automotive-Service-Plattform nutzen. Durch die Nutzung unserer Services stimmen Sie der Sammlung und Verwendung von Informationen gemäß dieser Richtlinie zu.',

          // Main Content Sections
          'information_we_collect_title': 'Informationen, die wir sammeln',
          'information_we_collect_content':
              '''Wir sammeln folgende Arten von Informationen:

• Persönliche Daten: Name, E-Mail-Adresse, Telefonnummer und Profilbild bei der Kontoerstellung
• Standortdaten: Ihr aktueller Standort, um nahegelegene Werkstätten zu finden und Entfernungen zu berechnen (mit Ihrer Erlaubnis)
• Service-Anfragen: Details zu angeforderten Automotive-Services, einschließlich Fahrzeuginformationen und Service-Historie
• Kommunikationsdaten: Nachrichten zwischen Ihnen und Werkstattbesitzern über unser Chat-System
• Geräteinformationen: Gerätetyp, Betriebssystem und App-Version für technischen Support
• Nutzungsanalytik: Wie Sie mit unserer App interagieren, um die Benutzererfahrung zu verbessern

Wir sammeln nur Informationen, die notwendig sind, um unsere Services effektiv bereitzustellen.''',

          'how_we_use_title': 'Wie wir Ihre Informationen nutzen',
          'how_we_use_content': '''Ihre Informationen werden verwendet, um:

• Sie mit qualifizierten Automotive-Service-Anbietern in Ihrer Nähe zu verbinden
• Ihre Service-Anfragen zu verarbeiten und zu verwalten
• Sichere Kommunikation zwischen Kunden und Werkstattbesitzern zu ermöglichen
• Wichtige Benachrichtigungen über Ihre Service-Anfragen zu senden
• Unsere App-Funktionalität und Benutzererfahrung zu verbessern
• Kundensupport bei Bedarf bereitzustellen
• Plattform-Sicherheit zu gewährleisten und Betrug zu verhindern
• Rechtlichen Verpflichtungen nachzukommen

Wir verwenden Ihre persönlichen Daten niemals für Werbung bei Dritten.''',

          'location_services_title': 'Standortdienste',
          'location_services_content':
              '''Standortinformationen sind wesentlich für unsere Hauptservices:

• Finden nahegelegener Werkstätten und Service-Anbieter
• Berechnung genauer Entfernungen und geschätzter Ankunftszeiten
• Bereitstellung standortbasierter Service-Empfehlungen
• Ermöglichung für Werkstattbesitzer, Kunden bei Bedarf zu lokalisieren

Sie können Standortberechtigungen in Ihren Geräteeinstellungen kontrollieren. Das Deaktivieren von Standortdiensten kann jedoch einige App-Funktionen einschränken. Wir greifen nur auf Ihren Standort zu, wenn Sie die App aktiv nutzen oder eine ausstehende Service-Anfrage haben.''',

          'data_sharing_title': 'Informationsfreigabe',
          'data_sharing_content':
              '''Wir teilen Ihre Informationen nur bei Bedarf:

Mit Werkstattbesitzern:
• Ihr Name und Kontaktdaten bei Service-Anfragen
• Ihr Standort (mit Erlaubnis) für Service-Lieferung
• Service-Historie relevant für Ihre aktuelle Anfrage

Mit Service-Anbietern:
• Karten- und Navigationsdienste für Standortfunktionen
• Cloud-Speicher-Anbieter für Datensicherung
• Analytics-Tools für App-Leistungsüberwachung

Rechtliche Anforderungen:
• Bei Anforderung durch Strafverfolgung oder Gerichtsverfahren
• Zum Schutz unserer Rechte, Eigentum oder Sicherheit der Nutzer

Wir verkaufen Ihre persönlichen Daten niemals an Dritte für Marketingzwecke.''',

          'data_security_title': 'Datensicherheit',
          'data_security_content':
              '''Wir implementieren mehrere Sicherheitsmaßnahmen:

• End-zu-End-Verschlüsselung für sensible Kommunikation
• Sichere Server mit regelmäßigen Sicherheitsupdates
• Multi-Faktor-Authentifizierungsoptionen
• Regelmäßige Sicherheitsaudits und Schwachstellenbewertungen
• Datensicherung und Wiederherstellungssysteme

Während wir branchenübliche Sicherheitsmaßnahmen verwenden, ist kein System zu 100% sicher. Wir ermutigen Nutzer, starke Passwörter zu verwenden und ihre Geräte aktuell zu halten.''',

          'your_rights_title': 'Ihre Rechte und Wahlmöglichkeiten',
          'your_rights_content': '''Sie haben das Recht auf:

• Zugriff und Überprüfung Ihrer persönlichen Daten
• Aktualisierung oder Korrektur Ihrer Kontodaten jederzeit
• Löschung Ihres Kontos und zugehöriger Daten
• Download Ihrer Daten in einem portablen Format
• Abmeldung von nicht-essentiellen Kommunikationen
• Kontrolle über Standortfreigabe-Berechtigungen
• Anfrage von Informationen über die Nutzung Ihrer Daten

Um diese Rechte auszuüben, kontaktieren Sie uns unter privacy@autoservice24.com oder nutzen Sie die Kontoeinstellungen in der App.''',

          'third_party_title': 'Drittanbieter-Services',
          'third_party_content':
              '''Unsere App integriert vertrauenswürdige Drittanbieter-Services:

• Mapbox: Für Karten und Standortdienste
• Analytics-Tools: Für App-Leistungsüberwachung

Diese Services haben ihre eigenen Datenschutzrichtlinien. Wir empfehlen deren Überprüfung:
• Mapbox Datenschutzrichtlinie: mapbox.com/legal/privacy
• Wir teilen nur die minimal notwendigen Informationen mit diesen Services.''',

          'children_privacy_title': 'Datenschutz für Kinder',
          'children_privacy_content':
              '''Auto Service 24 ist für Nutzer ab 18 Jahren bestimmt. Wir sammeln wissentlich keine persönlichen Daten von Kindern unter 18 Jahren. Wenn wir entdecken, dass ein Kind uns persönliche Daten zur Verfügung gestellt hat, werden wir diese sofort löschen. Wenn Sie glauben, dass ein Kind uns Informationen gegeben hat, kontaktieren Sie uns bitte unter privacy@autoservice24.com.''',

          'terms_of_service_title': 'Nutzungsbedingungen',
          'terms_of_service_content':
              '''Durch die Nutzung von Auto Service 24 stimmen Sie zu:

Akzeptable Nutzung:
• Den Service nur für legitime Automotive-Service-Bedürfnisse nutzen
• Genaue Informationen in Ihrem Profil und Service-Anfragen bereitstellen
• Werkstattbesitzer und andere Nutzer respektvoll behandeln
• Die Plattform nicht für illegale Aktivitäten oder Betrug nutzen

Service-Verfügbarkeit:
• Services werden "wie besehen" ohne Garantien bereitgestellt
• Wir können den Service temporär für Wartung aussetzen
• Werkstattbesitzer legen ihre eigenen Service-Details und Verfügbarkeit fest

Kommunikation:
• Direkte Kommunikation zwischen Nutzern und Werkstattbesitzern
• Nachrichten werden sicher gespeichert und können von Nutzern gelöscht werden
• Nutzer sind für ihre eigenen Service-Vereinbarungen verantwortlich

Haftungsbeschränkung:
• Auto Service 24 verbindet Kunden mit Service-Anbietern, ist aber nicht verantwortlich für die Qualität der durchgeführten Services
• Wir haften nicht für Schäden aus Service-Interaktionen
• Nutzer vereinbaren Services direkt mit Werkstattbesitzern
• Unsere Haftung ist auf das gesetzlich maximal zulässige Maß beschränkt

Kündigung:
• Sie können Ihr Konto jederzeit löschen
• Wir können Konten aussetzen, die gegen diese Bedingungen verstoßen
• Gelöschte Konten und Daten werden innerhalb von 30 Tagen dauerhaft entfernt''',

          'contact_us_title': 'Kontaktieren Sie uns',
          'contact_privacy_text':
              'Bei Fragen zu dieser Datenschutzrichtlinie, Ihren Datenrechten oder unseren Datenpraktiken kontaktieren Sie bitte unser Datenschutz-Team. Wir antworten auf alle Anfragen innerhalb von 48 Stunden.',

          'last_updated_title': 'Zuletzt aktualisiert',
          'version_label': 'Version',
          'current_label': 'Aktuell',

          // Action Buttons
          'accept_privacy_policy_button':
              'Datenschutzrichtlinie & AGB akzeptieren',
          'privacy_policy_accepted_status': 'Datenschutzrichtlinie akzeptiert',

          // Register Form
          'privacy_policy_accepted_short': 'Datenschutzrichtlinie akzeptiert',

          // Profile
          'privacy_security': 'Datenschutz & Sicherheit',
          'view_privacy_policy':
              'Datenschutzrichtlinie und Bedingungen anzeigen',
          'accept': 'Akzeptieren',

          // Additional translations
          'your_reliable_auto_service_partner':
              'Ihr zuverlässiger Auto-Service-Partner',
          'version_1_0': 'Version 1.0',
          'account_created_and_verified':
              'Konto erfolgreich erstellt und verifiziert',
          'account_created_verify_email':
              'Konto erstellt! Bitte verifizieren Sie Ihre E-Mail',
          'invalid_server_response': 'Ungültige Server-Antwort',
          'registration_failed': 'Registrierung fehlgeschlagen',
          'by_continuing_you_agree': 'Indem Sie fortfahren, stimmen Sie zu',
          'privacy_policy_subtitle':
              'Erfahren Sie, wie Ihre Daten geschützt werden',
          'agree_to': 'Ich stimme ',
          'privacy_policy': 'Datenschutzrichtlinie',
          'and': ' und ',
          'terms_of_use': 'Nutzungsbedingungen',
          'info': 'Info',
          'terms_page_coming_soon':
              'Die Seite mit den Nutzungsbedingungen wird bald verfügbar sein',
          'privacy_terms_agreement':
              'Sie müssen der Datenschutzrichtlinie und den Nutzungsbedingungen zustimmen, um fortzufahren',
          'i_agree_to': 'Ich stimme der ',
          'select_service_type': 'Service-Typ auswählen',
          'tap_search_to_find_workshops':
              'Tippen Sie auf Suchen, um Werkstätten zu finden',
          'select_service_type_first':
              'Wählen Sie zuerst einen Service-Typ aus',
          'nearby_workshops': 'Werkstätten in der Nähe',
          'select_location_and_service': 'Standort und Service-Typ auswählen',
          'search_complete': 'Suche abgeschlossen',
          'found_workshops': '{count} Werkstätten gefunden',
          'no_workshops_found_in_area':
              'Keine Werkstätten in diesem Bereich gefunden',
          'search_failed': 'Suche fehlgeschlagen',
          'opening_directions_to': 'Wegbeschreibung wird geöffnet zu',
          'view_location_on_map': 'Standort auf Karte anzeigen',
          'focus_on_workshop': 'Auf Werkstatt fokussieren',
          'search_nearby_workshops': 'Werkstätten in der Nähe suchen',
          'workshop_search_radius': 'Suchradius',
          'local': 'Lokal',
          'city': 'Stadt',
          'region': 'Region',
          'national': 'National',
          'youre_browsing_as_guest': 'Sie surfen als Gast',
          'login_register_for_features':
              'Melden Sie sich an oder registrieren Sie sich, um Services zu speichern, mit Werkstätten zu chatten und auf weitere Funktionen zuzugreifen.',
          'search_on_map': 'Auf Karte suchen',
          'workshop_location_not_available':
              'Werkstatt-Standort nicht verfügbar',
          'workshop_location_not_set': 'Werkstatt-Standort nicht festgelegt',
          'failed_to_open_workshop_location':
              'Werkstatt-Standort konnte nicht geöffnet werden',
          'no_location': 'Kein Standort',
          'workshop_location': 'Werkstatt-Standort',
          'image_not_available': 'Bild nicht verfügbar',
          'file_not_found': 'Datei nicht gefunden',
          'asset_not_found': 'Asset nicht gefunden',
          'invalid_path': 'Ungültiger Pfad',
          'find_nearby_workshops': 'Werkstätten in der Nähe finden',
          'search_workshops_by_location': 'Werkstätten nach Standort suchen',
          'open_map_search': 'Kartensuche öffnen',
          'save': 'Speichern',
          'sign_out': 'Abmelden',
          'are_you_sure_sign_out_account':
              'Sind Sie sicher, dass Sie sich von Ihrem Konto abmelden möchten?',
          'permanently_delete_account':
              'Dies wird Ihr Konto und alle Daten dauerhaft löschen. Diese Aktion kann nicht rückgängig gemacht werden.',
          'failed_delete_account':
              'Konto konnte nicht gelöscht werden. Bitte versuchen Sie es erneut.',
          'empty_image_path': 'Leerer Bildpfad',
          'network_error': 'Netzwerkfehler',
          'invalid_image_path': 'Ungültiger Bildpfad',
          'image_counter': '{current} von {total}',
          // Already exists but double checking
          'scroll_to_top': 'Nach oben scrollen',
          'about': 'Über',
          'view_service': 'Service anzeigen',
          'block_user': 'Benutzer blockieren',
          'service': 'Service',
          'user_blocking_soon': 'Benutzer-Blockierungsfunktion kommt bald',
          'user_reporting_soon': 'Benutzer-Meldefunktion kommt bald',
          'failed_to_load_image': 'Bild konnte nicht geladen werden',

          // Additional chat keys that might be used
          'connection_lost': 'Verbindung verloren',
          'reconnecting': 'Verbindung wird wiederhergestellt...',
          'feature_coming_soon': 'Funktion kommt bald',
          'file_attachment_soon': 'Dateianhang wird bald verfügbar sein',
          'camera_error': 'Kamera-Fehler',
          'gallery_error': 'Galerie-Fehler',
          'camera_permission_error':
              'Zugriff auf Kamera nicht möglich. Bitte aktivieren Sie die Kamera-Berechtigung in den Geräteeinstellungen.',
          'gallery_permission_error':
              'Zugriff auf Galerie nicht möglich. Bitte aktivieren Sie die Speicher-Berechtigung in den Geräteeinstellungen.',
          'image_selected_successfully': 'Bild erfolgreich ausgewählt',
          'failed_to_select_image': 'Bild konnte nicht ausgewählt werden',
          'user_not_found': 'Benutzer nicht gefunden',
          'failed_to_update_profile': 'Profil konnte nicht aktualisiert werden',
          'search': 'Suchen',
          'current_location': 'Aktueller Standort',
          'map_initialization_error': 'Karten-Initialisierungsfehler',
          'annotation_setup_error': 'Anmerkungen-Setup-Fehler',
          'getting_location': 'Ihr Standort wird ermittelt...',
          'markers_load_error': 'Fehler beim Laden der Markierungen',
          'back_to_services': 'Zurück zu den Services',
          'navigation_error': 'Navigationsfehler',
          'map_not_ready': 'Karte nicht bereit',
          'current_location_not_found': 'Aktueller Standort nicht gefunden',
          'loading': 'Wird geladen',
          'creating_route': 'Route wird erstellt...',
          'route_creation_error': 'Fehler bei der Routenerstellung',
          'navigation_to': 'Navigation zu',
          'estimated_time': 'Geschätzte Zeit',
          'start_navigation': 'Navigation starten',
          'clear_route': 'Route löschen',
          'navigation_started': 'Navigation gestartet',
          'navigating_to': 'Navigiere zu',
          'route_cleared': 'Route gelöscht',
          'contact_workshop_button': 'Werkstatt kontaktieren',
          'view_workshop_button': 'Werkstatt anzeigen',
          'forgot_password_question': 'Passwort vergessen?',
          'reset_password_button': 'Passwort zurücksetzen',
          'chat_information_missing': 'Chat-Informationen fehlen',
          'unknown_user': 'Unbekannter Benutzer',
          'invalid_chat_information':
              'Ungültige Chat-Informationen. Erforderliche Daten fehlen.',
          'failed_create_chat': 'Chat konnte nicht erstellt werden',
          'creating_chat_with': 'Chat wird erstellt mit {name}...',
          'discussing_service': 'Diskussion über: {service}',
          'ask_about_service': 'Fragen über {service}',
          'ready_to_send': 'Bereit zum Senden',
          'uploading_image': 'Bild wird hochgeladen...',
          'add_caption': 'Bildunterschrift hinzufügen...',
          'select_attachment': 'Anhang auswählen',
          'file': 'Datei',
          'failed_load_image': 'Bild konnte nicht geladen werden',
          'failed_send_message': 'Nachricht konnte nicht gesendet werden',
          'camera': 'Kamera',
          'gallery': 'Galerie',
          'username': 'Benutzername',
          'login': 'Anmelden',
          'password': 'Passwort',
          'forgot_password': 'Passwort vergessen?',
          'reset_password': 'Passwort zurücksetzen',
          'new_password': 'Neues Passwort',
          'confirm_password': 'Passwort bestätigen',
          'email': 'E-Mail',
          'more_images': 'Weitere Bilder',
          'contact_workshop_message':
              'Diese Funktion startet einen Chat mit dem Werkstattbesitzer',
          'please_enter_service_title': 'Bitte geben Sie den Service-Titel ein',
          'please_enter_valid_price':
              'Bitte geben Sie einen gültigen Preis ein',
          'success': 'Erfolgreich',
          'workshop_owner': 'Werkstattbesitzer',
          'update_personal_information':
              'Aktualisieren Sie Ihre persönlichen Informationen',
          'service_image': 'Service-Bild',
          'user_not_logged_in': 'Benutzer nicht angemeldet',
          'view_location': 'Standort anzeigen',
          'delete_service': 'Service löschen',
          'unknown_workshop': 'Unbekannte Werkstatt',
          'confirm_delete_service':
              'Sind Sie sicher, dass Sie diesen Service löschen möchten?',
          'deleted': 'Gelöscht',
          'service_deleted_successfully': 'Service erfolgreich gelöscht',
          'failed_delete_service':
              'Service konnte nicht gelöscht werden. Bitte versuchen Sie es erneut.',
          'error_deleting_service':
              'Es ist ein Fehler beim Löschen des Services aufgetreten.',

          // Guest banner
          'browsing_as_guest': 'Sie surfen als Gast',
          'login_register_save_chat':
              'Melden Sie sich an oder registrieren Sie sich, um Dienstleistungen zu speichern, mit Werkstätten zu chatten und auf mehr Funktionen zuzugreifen.',

          // Auth translations
          'enter_email_reset':
              'Geben Sie Ihre E-Mail-Adresse ein, um Ihr Passwort zurückzusetzen',
          'set_new_password': 'Neues Passwort festlegen',
          'create_new_password':
              'Erstellen Sie ein neues Passwort für Ihr Konto',
          'reset_complete': 'Zurücksetzung abgeschlossen',
          'password_reset_success':
              'Ihr Passwort wurde erfolgreich zurückgesetzt',
          'email_address': 'E-Mail-Adresse',
          'enter_registered_email': 'Geben Sie Ihre registrierte E-Mail ein',
          'verify_email_info':
              'Wir überprüfen Ihre E-Mail und ermöglichen Ihnen, ein neues Passwort festzulegen.',
          'enter_new_password': 'Geben Sie Ihr neues Passwort ein',
          'confirm_new_password': 'Neues Passwort bestätigen',
          'confirm_new_password_hint': 'Bestätigen Sie Ihr neues Passwort',
          'password_requirements': 'Passwort-Anforderungen:',
          'at_least_6_characters': 'Mindestens 6 Zeichen',
          'contains_letters_numbers': 'Enthält Buchstaben und Zahlen',
          'no_spaces_allowed': 'Keine Leerzeichen erlaubt',
          'password_reset_successful': 'Passwort erfolgreich zurückgesetzt!',
          'password_updated_success':
              'Ihr Passwort wurde erfolgreich aktualisiert. Sie können sich jetzt mit Ihrem neuen Passwort anmelden.',
          'verify_email': 'E-Mail bestätigen',
          'go_to_login': 'Zur Anmeldung',
          'remember_password': 'Erinnern Sie sich an Ihr Passwort? ',

          // Login translations
          'welcome_back': 'Willkommen zurück!',
          'sign_in_account': 'Melden Sie sich in Ihrem Konto an',
          'continue_with_google': 'Mit Google fortfahren',
          'continue_with_facebook': 'Mit Facebook fortfahren',
          'continue_with_apple': 'Mit Apple fortfahren',
          'or_continue_email': 'oder mit E-Mail fortfahren',
          'forgot_password_link': 'Passwort vergessen?',
          'dont_have_account': 'Haben Sie kein Konto? ',
          'sign_up': 'Registrieren',
          'continue_as_guest': 'Als Gast fortfahren',
          'login_as': 'Anmelden als:',
          'regular_user': 'Normaler Benutzer',
          'enter_email': 'Geben Sie Ihre E-Mail ein',
          'enter_password': 'Geben Sie Ihr Passwort ein',
          'please_enter_email': 'Bitte geben Sie Ihre E-Mail ein',
          'please_enter_valid_email': 'Bitte geben Sie eine gültige E-Mail ein',
          'please_enter_password': 'Bitte geben Sie Ihr Passwort ein',

          // Register translations
          'create_account': 'Konto erstellen',
          'join_community': 'Treten Sie der CarServiceHub-Community bei',
          'i_am_a': 'Ich bin ein:',
          'looking_for_services': 'Suche nach Dienstleistungen',
          'providing_services': 'Biete Dienstleistungen an',
          'phone_number': 'Telefonnummer',
          'please_enter_username': 'Bitte geben Sie Ihren Benutzernamen ein',
          'username_min_3_chars':
              'Benutzername muss mindestens 3 Zeichen haben',
          'please_enter_phone': 'Bitte geben Sie Ihre Telefonnummer ein',
          'please_confirm_password': 'Bitte bestätigen Sie Ihr Passwort',
          'passwords_do_not_match': 'Passwörter stimmen nicht überein',
          'password_min_6_chars': 'Passwort muss mindestens 6 Zeichen haben',
          'already_have_account': 'Haben Sie bereits ein Konto? ',
          'sign_in': 'Anmelden',
          'or_continue_with': 'oder fortfahren mit',

          // Chat translations
          'messages': 'Nachrichten',
          'connect_service_providers': 'Mit Dienstleistern verbinden',
          'sign_in_to_chat':
              'Melden Sie sich an, um direkt mit Werkstätten und Dienstleistern zu chatten.',
          'chat_features': 'Chat-Funktionen:',
          'direct_messaging': 'Direktnachrichten mit Anbietern',
          'schedule_appointments': 'Termine einfach planen',
          'instant_quotes': 'Sofortige Kostenvoranschläge erhalten',
          'share_photos': 'Fotos Ihres Fahrzeugs teilen',
          'share_location': 'Standortdetails teilen',
          'register': 'Registrieren',
          'explore_services_instead': 'Dienstleistungen erkunden',
          'no_conversations_yet': 'Noch keine Unterhaltungen',
          'start_chatting':
              'Beginnen Sie zu chatten mit Werkstattbesitzern und Dienstleistern',
          'browse_services': 'Dienstleistungen durchsuchen',
          'starting_chat': 'Chat wird gestartet...',
          'online': 'Online',
          'offline': 'Offline',
          'voice_call_soon': 'Sprachanruf-Funktion wird bald verfügbar sein',
          'report': 'Melden',
          'start_conversation': 'Unterhaltung beginnen',
          'send_message_begin': 'Senden Sie eine Nachricht, um zu chatten',
          'type_message': 'Nachricht eingeben...',
          'is_typing': 'schreibt',
          'are_you_sure_block': 'Sind Sie sicher, dass Sie blockieren möchten',
          'block': 'Blockieren',
          'cancel': 'Abbrechen',
          'report_user': 'Benutzer melden',
          'report_inappropriate':
              '{name} wegen unangemessenen Verhaltens melden?',
          'just_now': 'Gerade eben',
          'minutes_ago': 'vor {minutes}m',
          'hours_ago': 'vor {hours}h',
          'days_ago': 'vor {days}d',

          // Profile translations
          'edit_profile': 'Profil bearbeiten',
          'personal_information': 'Persönliche Informationen',
          'phone': 'Telefon',
          'account_type': 'Kontotyp',
          'user': 'Benutzer',
          'save_changes': 'Änderungen speichern',
          'tap_camera_change_photo':
              'Tippen Sie auf das Kamera-Symbol, um das Foto zu ändern',
          'new_photo_selected': 'Neues Foto ausgewählt',
          'profile_updated_successfully': 'Profil erfolgreich aktualisiert',

          // Map translations
          'workshop_locations': 'Werkstatt-Standorte',
          'view_details': 'Details anzeigen',
          'directions': 'Wegbeschreibung',
          'distance': 'Entfernung:',
          'km': 'km',
          'opening_directions': 'Wegbeschreibung wird geöffnet zu',

          // Service Details translations
          'description': 'Beschreibung',
          'workshop_information': 'Werkstatt-Informationen',
          'workshop_id': 'Werkstatt-ID',
          'service_duration': 'Servicedauer',
          'warranty': 'Garantie',
          'reviews': 'Bewertungen',
          'contact_workshop': 'Werkstatt kontaktieren',
          'view_workshop': 'Werkstatt anzeigen',
          'login_required': 'Anmeldung erforderlich',
          'login_register_access':
              'Bitte melden Sie sich an oder registrieren Sie sich, um auf diese Funktion zuzugreifen.',
          'login_to_save': 'Zum Speichern anmelden',
          'remove_from_saved': 'Aus gespeicherten entfernen',
          'save_service': 'Service speichern',
          '1_2_hours': '1-2 Stunden',
          '30_days': '30 Tage',

          // Settings translations
          'settings': 'Einstellungen',
          'account': 'Konto',
          'change_password': 'Passwort ändern',
          'update_password': 'Ihr Passwort aktualisieren',
          'preferences': 'Einstellungen',
          'push_notifications': 'Push-Benachrichtigungen',
          'receive_notifications':
              'Benachrichtigungen über neue Nachrichten und Updates erhalten',
          'location_services': 'Standortdienste',
          'allow_location': 'App den Zugriff auf Ihren Standort erlauben',
          'dark_mode': 'Dunkler Modus',
          'use_dark_theme': 'Dunkles Design verwenden',
          'app': 'App',
          'language': 'Sprache',
          'app_version_info': 'App-Version und Informationen',
          'help_support': 'Hilfe & Support',
          'get_help_support': 'Hilfe erhalten und Support kontaktieren',
          'read_privacy_policy': 'Unsere Datenschutzrichtlinie lesen',
          'terms_of_service': 'Nutzungsbedingungen',
          'read_terms': 'Unsere Nutzungsbedingungen lesen',
          'data': 'Daten',
          'download_data': 'Daten herunterladen',
          'download_copy_data': 'Eine Kopie Ihrer Daten herunterladen',
          'clear_cache': 'Cache leeren',
          'clear_temp_files': 'App-Cache und temporäre Dateien leeren',
          'settings_saved': 'Einstellungen gespeichert',
          'password_change_implemented':
              'Passwort-Änderungsfunktion würde hier implementiert werden.',
          'change': 'Ändern',
          'select_language': 'Sprache auswählen',
          'english': 'Englisch',
          'arabic': 'Arabisch',
          'german': 'Deutsch',
          'french': 'Französisch',
          'spanish': 'Spanisch',
          'about_autoservice': 'Über AutoService24',
          'version': 'Version: 1.0.0',
          'car_service_partner': 'Ihr Auto-Service-Partner',
          'find_book_services':
              'Finden und buchen Sie Kfz-Services in Ihrer Nähe.',
          'copyright': '© 2024 AutoService24. Alle Rechte vorbehalten.',
          'ok': 'OK',
          'need_help_contact': 'Brauchen Sie Hilfe? Kontaktieren Sie uns:',
          'support_email': 'support@autoservice24.com',
          'support_phone': '+1 (555) 123-4567',
          'privacy_displayed_here':
              'Datenschutzrichtlinie würde hier angezeigt werden',
          'terms_displayed_here':
              'Nutzungsbedingungen würden hier angezeigt werden',
          'data_download_implemented':
              'Daten-Download-Funktion würde hier implementiert werden',
          'are_you_sure_clear_cache':
              'Sind Sie sicher, dass Sie den App-Cache leeren möchten? Dies entfernt temporäre Dateien und kann die App anfangs verlangsamen.',
          'clear': 'Leeren',
          'cache_cleared': 'Cache erfolgreich geleert',
          'are_you_sure_sign_out':
              'Sind Sie sicher, dass Sie sich abmelden möchten?',

          // Workshop Details translations
          'workshop_info': 'Werkstatt-Informationen',
          'working_hours': 'Arbeitszeiten',
          'location': 'Standort',
          'rating_reviews': '4,5 (24 Bewertungen)',
          'view_reviews': 'Bewertungen anzeigen',
          'services': 'Dienstleistungen',
          'view_all': 'Alle anzeigen',
          'no_services_available': 'Keine Dienstleistungen verfügbar',
          'workshop_no_services':
              'Diese Werkstatt hat noch keine Dienstleistungen hinzugefügt',
          'starting_conversation': 'Unterhaltung beginnen mit',
          'login_contact_workshops':
              'Bitte melden Sie sich an oder registrieren Sie sich, um Werkstätten zu kontaktieren.',

          // Add Service translations
          'add_service': 'Service hinzufügen',
          'create_new_service': 'Neuen Service erstellen',
          'select_workshop': 'Werkstatt auswählen',
          'create_workshop_first':
              'Sie müssen zuerst eine Werkstatt erstellen, bevor Sie Services hinzufügen können.',
          'service_title': 'Service-Titel',
          'service_type': 'Service-Typ',
          'price_usd': 'Preis (\€)',
          'service_images': 'Service-Bilder',
          'add_images': 'Bilder hinzufügen',
          'create_service': 'Service erstellen',
          'please_select_workshop': 'Bitte wählen Sie eine Werkstatt aus',
          'service_created_successfully': 'Service erfolgreich erstellt!',
          'failed_create_service': 'Service konnte nicht erstellt werden',

          // Add Workshop translations
          'add_workshop': 'Werkstatt hinzufügen',
          'create_your_workshop': 'Ihre Werkstatt erstellen',
          'workshop_name': 'Werkstatt-Name',
          'please_enter_workshop_name':
              'Bitte geben Sie den Werkstatt-Namen ein',
          'please_enter_description': 'Bitte geben Sie eine Beschreibung ein',
          'working_hours_example': 'Arbeitszeiten (z.B. 8:00 - 18:00)',
          'please_enter_working_hours': 'Bitte geben Sie die Arbeitszeiten ein',
          'tap_map_select_location':
              'Tippen Sie auf die Karte, um den Standort Ihrer Werkstatt auszuwählen',
          'location_selected': 'Standort ausgewählt:',
          'please_select_location':
              'Bitte wählen Sie einen Standort auf der Karte aus',
          'create_workshop': 'Werkstatt erstellen',
          'workshop_created_successfully': 'Werkstatt erfolgreich erstellt!',

          // Owner Home translations
          'carservicehub_owner': 'CarServiceHub - Besitzer',
          'home': 'Startseite',
          'profile': 'Profil',
          'hello_user': 'Hallo {name}',
          'service_categories': 'Service-Kategorien',
          'vehicle_inspection': 'Fahrzeug-\nInspektion',
          'change_oil': 'Öl wechseln',
          'change_tires': 'Reifen wechseln',
          'remove_install_tires': 'Reifen aus- und\neinbauen',
          'cleaning': 'Reinigung',
          'diagnostic_test': 'Diagnose-Test',
          'pre_tuv_check': 'Vor-TÜV-Prüfung',
          'balance_tires': 'Reifen auswuchten',
          'wheel_alignment': 'Rad-\nausrichtung',
          'polish': 'Polieren',
          'change_brake_fluid': 'Brems-\nflüssigkeit wechseln',
          'logout': 'Abmelden',
          'are_you_sure_logout':
              'Sind Sie sicher, dass Sie sich abmelden möchten?',

          // Owner Profile translations
          'contact_information': 'Kontakt-Informationen',
          'not_provided': 'Nicht angegeben',
          'workshops': 'Werkstätten',
          'total_services': 'Gesamte Services',
          'total_reviews': 'Gesamte Bewertungen',
          'delete_account': 'Konto löschen',
          'delete_confirmation_title': 'Konto löschen',
          'this_will_permanently_delete': 'Dies wird dauerhaft löschen:',
          'your_account': 'Ihr Konto',
          'all_workshops': 'Alle Werkstätten',
          'all_services': 'Alle Services',
          'all_conversations': 'Alle Unterhaltungen',
          'all_business_data': 'Alle Geschäftsdaten',
          'action_cannot_be_undone':
              'Diese Aktion kann nicht rückgängig gemacht werden.',
          'delete': 'Löschen',
          'final_confirmation': 'Endgültige Bestätigung',
          'type_delete_confirm':
              'Geben Sie "DELETE" ein, um die Konto-Löschung zu bestätigen:',
          'type_delete_here': 'DELETE hier eingeben',
          'confirm_delete': 'Löschen bestätigen',
          'please_type_delete': 'Bitte geben Sie "DELETE" zur Bestätigung ein',
          'help_support_title': 'Hilfe & Support',
          'mon_fri_hours': 'Mo-Fr: 9-18 Uhr',
          'about_carservicehub': 'Über CarServiceHub',
          'your_car_service_partner': 'Ihr Auto-Service-Partner',
          'connecting_workshops':
              'Verbindet Werkstattbesitzer mit Kunden für einfaches Kfz-Service-Management.',
          'carservicehub_rights':
              '© 2024 CarServiceHub. Alle Rechte vorbehalten.',

          // Filtered Services translations
          'tune': 'Filter',
          'no_services_found': 'Keine Services gefunden',
          'no_services_for_category': 'Keine Services verfügbar für',
          'havent_created_services':
              'Sie haben noch keine Services erstellt für',
          'refresh': 'Aktualisieren',
          'saved': 'Gespeichert',
          'chat': 'Chat',
          'cannot_chat_yourself': 'Sie können nicht mit sich selbst chatten',
          'workshop_not_found': 'Werkstatt nicht gefunden',
          'failed_start_chat':
              'Chat konnte nicht gestartet werden. Bitte versuchen Sie es erneut.',

          // Saved Services translations
          'saved_services': 'Gespeicherte Services',
          'save_favorite_services': 'Speichern Sie Ihre Lieblings-Services',
          'create_account_save':
              'Erstellen Sie ein Konto, um Services zu speichern, die Sie mögen, und greifen Sie jederzeit und überall darauf zu.',
          'with_your_account': 'Mit Ihrem Konto:',
          'save_unlimited_services': 'Unbegrenzt Services speichern',
          'sync_all_devices': 'Auf allen Geräten synchronisieren',
          'track_service_history': 'Service-Verlauf verfolgen',
          'direct_chat_providers': 'Direkter Chat mit Anbietern',
          'loading_saved_services':
              'Ihre gespeicherten Services werden geladen...',
          'no_saved_services': 'Noch keine gespeicherten Services',
          'start_exploring_save':
              'Erkunden Sie Services und speichern Sie diejenigen, die Ihnen gefallen, für schnellen Zugriff später.',
          'explore_services': 'Services erkunden',
          'remove_service': 'Service entfernen',
          'remove_service_confirmation':
              'Sind Sie sicher, dass Sie diesen Service aus Ihrer Speicherliste entfernen möchten?',
          'remove': 'Entfernen',
          'service_unavailable': 'Service nicht verfügbar',
          'service_removed_unavailable':
              'Dieser Service wurde möglicherweise entfernt oder ist vorübergehend nicht verfügbar.',
          'saved_date': 'Gespeichert {date}',
          'recently': 'kürzlich',

          // User Home translations
          'auto_services': 'Auto-Dienstleistungen',
          'categories': 'Kategorien',
          'search_categories': 'Kategorien suchen...',
          'failed_refresh_services':
              'Services konnten nicht aktualisiert werden',

          // User Profile translations
          'guest_user': 'Gast-Benutzer',
          'login_to_account': 'Bei Ihrem Konto anmelden',
          'create_new_account': 'Neues Konto erstellen',
          'my_workshop': 'Meine Werkstatt',
          'manage_workshop': 'Ihre Werkstatt verwalten',
          'my_services': 'Meine Services',
          'manage_services': 'Ihre Services verwalten',
          'workshop_management_soon': 'Werkstatt-Verwaltung kommt bald',
          'service_management_soon': 'Service-Verwaltung kommt bald',
          'switch_language': 'Sprache wechseln',
          'current_language': 'Deutsch',
          'error': 'Fehler',
          'failed_remove_service':
              'Service konnte nicht entfernt werden. Bitte versuchen Sie es erneut.',
          'error_occurred_try_again':
              'Es ist ein Fehler aufgetreten. Bitte versuchen Sie es erneut.',
          'edit': 'Bearbeiten',
          'save_service_title': 'Service speichern',
          'save_service_description':
              'Erstellen Sie ein Konto, um Ihre Lieblings-Services zu speichern und jederzeit darauf zuzugreifen.',
          'no_workshops_found': 'Keine Werkstätten gefunden',
          'no_workshops_available':
              'In Ihrer Nähe sind keine Werkstätten verfügbar.',
          'no_conversations': 'Keine Unterhaltungen',
          'no_conversations_subtitle':
              'Sie haben noch keine Unterhaltungen. Beginnen Sie ein Gespräch mit Werkstattbesitzern.',
          'find_workshops': 'Werkstätten finden',
          'no_results_found': 'Keine Ergebnisse gefunden',
          'no_results_for_search':
              'Keine Ergebnisse für "{searchTerm}" gefunden. Versuchen Sie andere Suchbegriffe.',
          'no_results_try_different':
              'Keine Ergebnisse gefunden. Versuchen Sie andere Suchbegriffe.',
          'clear_search': 'Suche löschen',
          'no_saved_services_subtitle':
              'Sie haben noch keine Services gespeichert. Durchsuchen Sie Services, um Ihre Favoriten zu speichern.',
          'select_location': 'Standort auswählen',
          'confirm': 'Bestätigen',
          'tap_map_to_select_workshop_location':
              'Tippen Sie auf die Karte, um den Werkstattstandort auszuwählen',
          'location_selected_successfully': 'Standort erfolgreich ausgewählt',
          'coordinates': 'Koordinaten',
          'confirm_location': 'Standort bestätigen',
          'tap_confirm_or_select_another':
              'Tippen Sie bestätigen oder wählen Sie einen anderen Standort',
          'workshop_location_selected': 'Werkstattstandort ausgewählt',
          'tap_to_open_map': 'Tippen Sie, um die Karte zu öffnen',
          'select_workshop_location': 'Werkstattstandort auswählen',
          'cannot_get_current_location':
              'Aktueller Standort kann nicht abgerufen werden',
          'enter_verification_code': 'Bestätigungscode eingeben',
          'code_sent_to_email':
              'Wir haben einen 6-stelligen Code an Ihre E-Mail-Adresse gesendet',
          'verification_code': 'Bestätigungscode',
          'enter_6_digit_code': 'Geben Sie den 6-stelligen Code ein',
          'send_verification_code': 'Bestätigungscode senden',
          'verify_code': 'Code bestätigen',
          'resend_code': 'Code erneut senden',
          'verification_code_sent': 'Bestätigungscode erfolgreich gesendet',
          'verification_code_sent_successfully':
              'Bestätigungscode an Ihre E-Mail gesendet',
          'code_verified_successfully': 'Code erfolgreich bestätigt',
          'verification_code_required': 'Bestätigungscode ist erforderlich',
          'code_must_be_6_digits': 'Code muss 6 Ziffern haben',
          'code_must_be_numbers_only': 'Code darf nur Zahlen enthalten',
          'contact_workshop_owner': 'Werkstattbesitzer kontaktieren',
          'getting_phone_number': 'Telefonnummer wird abgerufen...',
          'cannot_open_phone_app': 'Telefon-App kann nicht geöffnet werden',
          'phone_number_not_available': 'Telefonnummer nicht verfügbar',
          'error_getting_phone_number': 'Fehler beim Abrufen der Telefonnummer',
          'email_verification': 'E-Mail-Verifizierung',
          'check_your_email': 'Überprüfen Sie Ihre E-Mail',
          'verification_sent_description':
              'Ein Bestätigungslink wurde an Ihre E-Mail-Adresse gesendet. Bitte klicken Sie auf den Link, um Ihr Konto zu aktivieren.',
          'next_steps': 'Nächste Schritte',
          'open_gmail_app': 'Öffnen Sie Gmail oder Ihren E-Mail-Client',
          'find_verification_email':
              'Finden Sie die Bestätigungs-E-Mail von AutoService24',
          'click_verify_button': 'Klicken Sie auf "E-Mail bestätigen"',
          'return_to_login': 'Zur Anmeldeseite zurückkehren',
          'check_spam_folder':
              'Wenn Sie die E-Mail nicht sehen, überprüfen Sie Ihren Spam-Ordner',
          'back_to_login': 'Zurück zur Anmeldung',
          'create_different_account': 'Anderes Konto erstellen',
          'app_name': 'Auto Service 24',
          'last_updated': 'Zuletzt aktualisiert',
          'accept_privacy_policy': 'Datenschutzrichtlinie akzeptieren',

          // Introduction Section
          'privacy_intro_title': 'Einleitung',
          'privacy_intro_content':
              'Willkommen bei Auto Service 24. Wir verpflichten uns, Ihre Privatsphäre und persönlichen Daten zu schützen. Diese Datenschutzrichtlinie erklärt, wie wir Ihre persönlichen Informationen sammeln, verwenden und schützen, wenn Sie unsere App nutzen.\n\nDurch die Nutzung von Auto Service 24 stimmen Sie den in dieser Richtlinie beschriebenen Praktiken zur Datensammlung und -nutzung zu.',

          // Data Collection Section
          'privacy_data_collection_title': 'Daten, die wir sammeln',
          'privacy_data_collection_content':
              'Wir sammeln die folgenden Datentypen, um unsere Dienste bereitzustellen:',
          'privacy_data_personal_info':
              'Persönliche Informationen: Name, E-Mail-Adresse, Telefonnummer',
          'privacy_data_account_info':
              'Kontoinformationen: Benutzername und verschlüsseltes Passwort',
          'privacy_data_location':
              'Geografische Standortdaten (mit Zustimmung)',
          'privacy_data_files': 'Bilder und Dateien, die Sie hochladen',
          'privacy_data_messages':
              'Nachrichten und Gespräche innerhalb der App',
          'privacy_data_device_info':
              'Geräteinformationen und Betriebssystemtyp',
          'privacy_data_usage': 'App-Nutzungsdaten und gespeicherte Services',

          // Data Usage Section
          'privacy_data_usage_title': 'Wie wir Ihre Daten verwenden',
          'privacy_data_usage_content':
              'Wir verwenden die gesammelten Daten für folgende Zwecke:',
          'privacy_usage_provide_services':
              'Bereitstellung und Betrieb von App-Services',
          'privacy_usage_manage_accounts':
              'Erstellen und Verwalten Ihrer Konten',
          'privacy_usage_find_workshops':
              'Finden von Werkstätten in Ihrer Nähe',
          'privacy_usage_communication':
              'Kommunikation zwischen Nutzern und Werkstattbesitzern erleichtern',
          'privacy_usage_improve_app': 'App-Qualität und -Leistung verbessern',
          'privacy_usage_notifications':
              'Wichtige servicebezogene Benachrichtigungen senden',
          'privacy_usage_security':
              'Sicherheit gewährleisten und unbefugte Nutzung verhindern',

          // Data Sharing Section
          'privacy_data_sharing_title': 'Datenaustausch',
          'privacy_data_sharing_content':
              'Wir verkaufen oder vermieten Ihre persönlichen Daten nicht an Dritte. Wir können Ihre Informationen nur in folgenden Fällen teilen:',
          'privacy_sharing_workshops':
              'Mit Werkstattbesitzern zur Erleichterung der Kommunikation und des Services',
          'privacy_sharing_legal':
              'Wenn erforderlich, um lokalen Gesetzen zu entsprechen',
          'privacy_sharing_rights':
              'Zum Schutz unserer Rechte und der Rechte der Nutzer',
          'privacy_sharing_emergency':
              'In Notfallsituationen zur Gewährleistung der Sicherheit',

          // Location Data Section
          'privacy_location_title': 'Geografische Standortdaten',
          'privacy_location_content':
              'Wir nutzen Mapbox-Services für Karten- und Standortdienste. Standortdaten werden nur mit Erlaubnis gesammelt und verwendet für:',
          'privacy_location_find_nearby':
              'Finden nahegelegener Werkstätten und Services',
          'privacy_location_distance':
              'Bestimmung von Entfernungen und geschätzten Ankunftszeiten',
          'privacy_location_maps': 'Anzeige von Karten und Wegbeschreibungen',
          'privacy_location_search_accuracy':
              'Verbesserung der Suchgenauigkeit',
          'privacy_location_disable_info':
              'Sie können die Standortfreigabe jederzeit in den App- oder Geräteeinstellungen deaktivieren',

          // Security Section
          'privacy_security_title': 'Datensicherheit',
          'privacy_security_content':
              'Wir implementieren umfassende Sicherheitsmaßnahmen zum Schutz Ihrer Daten:',
          'privacy_security_encryption':
              'Verschlüsselung von Passwörtern und sensiblen Daten',
          'privacy_security_https':
              'Verwendung von HTTPS-Protokollen für sichere Kommunikation',
          'privacy_security_servers':
              'Speicherung von Daten auf geschützten Servern',
          'privacy_security_monitoring':
              'Kontinuierliche Überwachung verdächtiger Aktivitäten',
          'privacy_security_updates': 'Regelmäßige Sicherheitssystem-Updates',
          'privacy_security_training':
              'Schulung der Mitarbeiter in Sicherheits-Best-Practices',

          // User Rights Section
          'privacy_rights_title': 'Ihre Rechte',
          'privacy_rights_content':
              'Sie haben folgende Rechte bezüglich Ihrer persönlichen Daten:',
          'privacy_rights_access': 'Zugriff auf Ihre gespeicherten Daten',
          'privacy_rights_correct':
              'Korrektur oder Aktualisierung falscher Informationen',
          'privacy_rights_delete':
              'Dauerhaftes Löschen Ihres Kontos und Ihrer Daten',
          'privacy_rights_withdraw':
              'Widerruf der Einwilligung zur Datenverarbeitung',
          'privacy_rights_restrict':
              'Einschränkung oder Widerspruch gegen die Nutzung Ihrer Daten',
          'privacy_rights_copy': 'Erhalt einer Kopie Ihrer Daten',

          // Storage Section
          'privacy_storage_title': 'Lokale Speicherung',
          'privacy_storage_content':
              'Die App verwendet lokale Speicherung auf Ihrem Gerät zum Speichern von:',
          'privacy_storage_settings':
              'App-Einstellungen und ausgewählte Sprache',
          'privacy_storage_login': 'Login-Informationen (verschlüsselt)',
          'privacy_storage_cache': 'Temporäre Daten zur Leistungsverbesserung',
          'privacy_storage_favorites': 'In Favoriten gespeicherte Services',

          // Third Party Section
          'privacy_third_party_title': 'Externe Services',
          'privacy_third_party_content':
              'Die App integriert sich mit folgenden externen Services:',
          'privacy_third_party_mapbox_desc':
              'Für Karten und geografische Standortbestimmung',
          'privacy_third_party_note':
              'Diese Services unterliegen ihren eigenen Datenschutzrichtlinien. Wir empfehlen, deren Richtlinien für detaillierte Informationen zu überprüfen.',

          // Data Retention Section
          'privacy_retention_title': 'Datenspeicherung',
          'privacy_retention_content':
              'Wir speichern Ihre persönlichen Daten für die Zeit, die zur Bereitstellung unserer Services erforderlich ist, oder wie gesetzlich vorgeschrieben:',
          'privacy_retention_account':
              'Kontodaten: während der aktiven Kontoperiode',
          'privacy_retention_messages':
              'Nachrichten und Gespräche: bis zur Löschung durch Sie',
          'privacy_retention_location':
              'Standortdaten: nur temporär für den Service gespeichert',
          'privacy_retention_activity':
              'Aktivitätsprotokolle: maximal ein Jahr',

          // Minors Section
          'privacy_minors_title': 'Schutz Minderjähriger',
          'privacy_minors_content':
              'Die App ist für Nutzer ab 18 Jahren bestimmt. Wir sammeln wissentlich keine persönlichen Informationen von Kindern unter 18 Jahren. Wenn wir erfahren, dass wir persönliche Informationen von einem Minderjährigen gesammelt haben, werden wir sofort Schritte unternehmen, um diese Informationen zu löschen.',

          // Policy Changes Section
          'privacy_changes_title': 'Richtlinien-Updates',
          'privacy_changes_content':
              'Wir können diese Datenschutzrichtlinie von Zeit zu Zeit aktualisieren. Wir werden Sie über wichtige Änderungen informieren durch:',
          'privacy_changes_notification': 'In-App-Benachrichtigung',
          'privacy_changes_email':
              'E-Mail-Nachricht (wenn Sie ein Konto haben)',
          'privacy_changes_date':
              'Aktualisierung des "Zuletzt aktualisiert"-Datums oben auf dieser Seite',
          'privacy_changes_notice':
              'Die fortgesetzte Nutzung der App nach Updates bedeutet, dass Sie der neuen Richtlinie zustimmen.',

          // Contact Section
          'privacy_contact_title': 'Kontaktieren Sie uns',
          'privacy_contact_content':
              'Wenn Sie Fragen oder Bedenken zu dieser Datenschutzrichtlinie oder unseren Datenpraktiken haben, kontaktieren Sie uns bitte über:',
          'privacy_contact_email': 'E-Mail',
          'privacy_contact_phone': 'Telefon',
          'privacy_contact_address': 'Adresse',
          'privacy_contact_address_value': 'Königreich Saudi-Arabien',
          'retry': 'Wiederholen',

          // Verbindungsfehler
          'connection_timeout':
              'Verbindungszeitüberschreitung. Prüfen Sie Ihr Internet',
          'request_timeout':
              'Anfragezeitüberschreitung. Versuchen Sie es erneut',
          'server_timeout':
              'Server-Antwortzeitüberschreitung. Versuchen Sie es erneut',
          'connection_error': 'Verbindungsfehler. Prüfen Sie Ihr Internet',
          'request_cancelled': 'Anfrage abgebrochen',
          'unexpected_error': 'Ein unerwarteter Fehler ist aufgetreten',
          'something_went_wrong':
              'Etwas ist schiefgelaufen. Bitte versuchen Sie es erneut',

          // HTTP-Fehler
          'bad_request': 'Ungültige Anfrage. Überprüfen Sie Ihre Eingabe',
          'unauthorized_login_again':
              'Sitzung abgelaufen. Bitte melden Sie sich erneut an',
          'access_forbidden': 'Sie haben keine Berechtigung für diese Aktion',
          'resource_not_found': 'Inhalt nicht gefunden',
          'resource_already_exists': 'Element existiert bereits',
          'invalid_data_provided': 'Ungültige Daten angegeben',
          'too_many_requests': 'Zu viele Anfragen. Versuchen Sie es später',
          'server_error': 'Serverproblem. Versuchen Sie es später',
          'bad_gateway': 'Server vorübergehend nicht verfügbar',
          'gateway_timeout': 'Gateway-Zeitüberschreitung',
          'server_error_occurred': 'Serverfehler aufgetreten',

          // Datenfehler
          'invalid_data_format': 'Ungültiges Datenformat',
          'data_type_error': 'Datentypfehler',

          // Andere Nachrichten
          'validation_error': 'Validierungsfehler',
          'session_expired':
              'Sitzung abgelaufen. Bitte melden Sie sich erneut an',

          // Service-Aktionen
          'removed_unavailable_services':
              '{count} nicht verfügbare Dienste entfernt',
          'service_already_saved': 'Dienst ist bereits gespeichert',
          'service_saved_successfully': 'Dienst erfolgreich gespeichert',
          'service_already_in_list':
              'Dienst ist bereits in Ihrer gespeicherten Liste',
          'service_removed_successfully': 'Dienst aus gespeicherten entfernt',
          'images_uploaded_successfully': 'Bilder erfolgreich hochgeladen',
          'service_updated_successfully': 'Dienst erfolgreich aktualisiert',

          // Chat-Aktionen
          'image_sent_successfully': 'Bild erfolgreich gesendet',
          'message_deleted_successfully': 'Nachricht erfolgreich gelöscht',
          'chat_deleted_successfully': 'Chat erfolgreich gelöscht',

          // Auth-Aktionen
          'verify_account_first':
              'Bitte verifizieren Sie zuerst Ihr Konto. Überprüfen Sie Ihre E-Mail',
          'login_successful': 'Anmeldung erfolgreich',
          'login_failed_check_credentials':
              'Anmeldung fehlgeschlagen. Überprüfen Sie E-Mail und Passwort',
          'profile_image_updated_successfully':
              'Profilbild erfolgreich aktualisiert',
          'google_signin_cancelled': 'Google-Anmeldung abgebrochen',
          'facebook_signin_failed': 'Facebook-Anmeldung fehlgeschlagen',
          'logged_out_successfully': 'Erfolgreich abgemeldet',
          'account_deleted_successfully': 'Konto erfolgreich gelöscht',
          'unable_to_delete_account': 'Konto kann nicht gelöscht werden',
          'password_updated_successfully': 'Passwort erfolgreich aktualisiert',
          'workshop_updated_successfully': 'Werkstatt erfolgreich aktualisiert',
          'workshop_deleted_successfully': 'Werkstatt erfolgreich gelöscht',
          'my_workshops': 'Meine Werkstätten',
          'loading_workshops': 'Werkstätten werden geladen...',
          'no_workshops_yet': 'Noch keine Werkstätten',
          'create_first_workshop':
              'Erstellen Sie Ihre erste Werkstatt, um Dienste anzubieten',
          'no_address': 'Keine Adresse',
          'view_services': 'Dienste anzeigen',
          'edit_workshop': 'Werkstatt bearbeiten',
          'delete_workshop': 'Werkstatt löschen',
          'services_count': 'Dienste',
          'confirm_delete_workshop':
              'Möchten Sie diese Werkstatt wirklich löschen?',
          'workshop_services_will_be_deleted':
              '{count} Dienste werden dauerhaft gelöscht',
          'deleting_workshop': 'Werkstatt wird gelöscht...',
          'please_wait': 'Bitte warten',
          'edit_workshop_info': 'Werkstatt-Info bearbeiten',
          'enter_workshop_name': 'Werkstattnamen eingeben',
          'enter_workshop_description': 'Werkstattbeschreibung eingeben',
          'enter_working_hours': 'z.B., Mo-Fr: 9-18 Uhr',
          'workshop_name_required': 'Werkstattname ist erforderlich',
          'workshop_description_required':
              'Werkstattbeschreibung ist erforderlich',
          'working_hours_required': 'Arbeitszeiten sind erforderlich',
          'manage_workshops_services':
              'Verwalten Sie Ihre Werkstätten und Dienste',
        },
      };
}
