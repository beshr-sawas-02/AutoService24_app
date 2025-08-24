import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/user/user_home_view.dart';
import '../views/user/user_profile_view.dart';
import '../views/user/saved_services_view.dart';
import '../views/owner/owner_home_view.dart';
import '../views/owner/owner_profile_view.dart';
import '../views/owner/add_workshop_view.dart';
import '../views/owner/add_service_view.dart';
import '../views/common/chat_view.dart';
import '../views/common/chat_list_view.dart';
import '../views/common/service_details_view.dart';
import '../views/common/workshop_details_view.dart';
import '../views/common/map_view.dart';
import '../views/common/edit_profile_view.dart';
import '../views/common/settings_view.dart';
import '../bindings/auth_binding.dart';
import '../bindings/common_binding.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String userHome = '/user-home';
  static const String userProfile = '/user-profile';
  static const String savedServices = '/saved-services';
  static const String ownerHome = '/owner-home';
  static const String ownerProfile = '/owner-profile';
  static const String addWorkshop = '/add-workshop';
  static const String addService = '/add-service';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String serviceDetails = '/service-details';
  static const String workshopDetails = '/workshop-details';
  static const String map = '/map';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';

  static List<GetPage> routes = [
    // Authentication Routes
    GetPage(
      name: splash,
      page: () => SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: login,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: register,
      page: () => RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => ForgotPasswordView(),
      binding: AuthBinding(),
    ),

    // User Routes
    GetPage(
      name: userHome,
      page: () => UserHomeView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: userProfile,
      page: () => UserProfileView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: savedServices,
      page: () => SavedServicesView(),
      binding: UserBinding(),
    ),

    // Owner Routes
    GetPage(
      name: ownerHome,
      page: () => OwnerHomeView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: ownerProfile,
      page: () => OwnerProfileView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: addWorkshop,
      page: () => AddWorkshopView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: addService,
      page: () => AddServiceView(),
      binding: OwnerBinding(),
    ),

    // Common/Shared Routes
    GetPage(
      name: chatList,
      page: () => ChatListView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: chat,
      page: () => ChatView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: serviceDetails,
      page: () => ServiceDetailsView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: workshopDetails,
      page: () => WorkshopDetailsView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: map,
      page: () => MapView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: editProfile,
      page: () => EditProfileView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: settings,
      page: () => SettingsView(),
      binding: CommonBinding(),
    ),
  ];
}