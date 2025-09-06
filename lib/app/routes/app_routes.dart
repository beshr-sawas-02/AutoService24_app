import 'package:get/get.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/user/user_home_view.dart';
import '../views/user/user_profile_view.dart';
import '../views/user/saved_services_view.dart';
import '../views/user/filtered_services_view.dart'; // إضافة الاستيراد الجديد
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
  static const String filteredServices = '/filtered-services'; // الروت الجديد
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
      page: () => const SplashView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: AuthBinding(),
    ),

    // User Routes
    GetPage(
      name: userHome,
      page: () => const UserHomeView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: userProfile,
      page: () => UserProfileView(),
      binding: UserBinding(),
    ),
    GetPage(
      name: savedServices,
      page: () => const SavedServicesView(),
      binding: UserBinding(),
    ),
    // الصفحة الجديدة للخدمات المفلترة
    GetPage(
      name: filteredServices,
      page: () => const FilteredServicesView(),
      binding: UserBinding(), // استخدام نفس binding لأن ServiceController موجود فيه
    ),

    // Owner Routes
    GetPage(
      name: ownerHome,
      page: () => const OwnerHomeView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: ownerProfile,
      page: () => OwnerProfileView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: addWorkshop,
      page: () => const AddWorkshopView(),
      binding: OwnerBinding(),
    ),
    GetPage(
      name: addService,
      page: () => const AddServiceView(),
      binding: OwnerBinding(),
    ),

    // Common/Shared Routes
    GetPage(
      name: chatList,
      page: () => const ChatListView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: chat,
      page: () => const ChatView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: serviceDetails,
      page: () => ServiceDetailsView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: workshopDetails,
      page: () => const WorkshopDetailsView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: map,
      page: () => const MapView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: editProfile,
      page: () => const EditProfileView(),
      binding: CommonBinding(),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsView(),
      binding: CommonBinding(),
    ),
  ];
}