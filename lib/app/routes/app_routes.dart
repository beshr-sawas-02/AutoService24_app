import 'package:get/get.dart';
import '../controllers/privacy_policy_controller.dart';
import '../views/auth/email_verification_view.dart';
import '../views/common/workshop_map_search_view.dart';
import '../views/owner/owner_workshops_view.dart';
import '../views/privacy_policy_screen.dart';
import '../views/splash_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../views/auth/forgot_password_view.dart';
import '../views/user/user_home_view.dart';
import '../views/user/user_profile_view.dart';
import '../views/user/saved_services_view.dart';
import '../views/user/filtered_services_view.dart';
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

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String userHome = '/user-home';
  static const String userProfile = '/user-profile';
  static const String savedServices = '/saved-services';
  static const String filteredServices = '/filtered-services';
  static const String ownerHome = '/owner-home';
  static const String ownerProfile = '/owner-profile';
  static const String addWorkshop = '/add-workshop';
  static const String addService = '/add-service';
  static const String chatList = '/chat-list';
  static const String chat = '/chat';
  static const String serviceDetails = '/service-details';
  static const String workshopDetails = '/workshop-details';
  static const String ownerWorkshops = '/owner-workshops';
  static const String map = '/map';
  static const String workshopMapSearch = '/workshop-map-search';
  static const String editProfile = '/edit-profile';
  static const emailVerification = '/email-verification';
  static const String privacyPolicy = '/privacy-policy';


  static List<GetPage> routes = [
    GetPage(
      name: splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: register,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordView(),
    ),
    GetPage(
      name: AppRoutes.emailVerification,
      page: () => const EmailVerificationView(),
    ),
    GetPage(
      name: userHome,
      page: () => UserHomeView(),
    ),
    GetPage(
      name: userProfile,
      page: () => UserProfileView(),
    ),
    GetPage(
      name: savedServices,
      page: () => const SavedServicesView(),
    ),
    GetPage(
      name: filteredServices,
      page: () => const FilteredServicesView(),
    ),
    GetPage(
      name: ownerHome,
      page: () => const OwnerHomeView(),
    ),
    GetPage(
      name: ownerProfile,
      page: () => OwnerProfileView(),
    ),
    GetPage(
      name: addWorkshop,
      page: () => const AddWorkshopView(),
    ),
    GetPage(
      name: AppRoutes.ownerWorkshops,
      page: () => const OwnerWorkshopsView(),
    ),
    GetPage(
      name: addService,
      page: () => const AddServiceView(),
    ),
    GetPage(
      name: chatList,
      page: () => const ChatListView(),
    ),
    GetPage(
      name: chat,
      page: () => const ChatView(),
    ),
    GetPage(
      name: serviceDetails,
      page: () => const ServiceDetailsView(),
    ),
    GetPage(
      name: workshopDetails,
      page: () => const WorkshopDetailsView(),
    ),
    GetPage(
      name: map,
      page: () => const MapView(),
    ),
    GetPage(
      name: workshopMapSearch,
      page: () => const WorkshopMapSearchView(),
    ),
    GetPage(
      name: editProfile,
      page: () => const EditProfileView(),
    ),
    GetPage(
      name: privacyPolicy,
      page: () => PrivacyPolicyView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => PrivacyPolicyController());
      }),
    ),
  ];
}
