import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../controllers/auth_controller.dart';
import '../controllers/privacy_policy_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';
import '../controllers/map_controller.dart';
import '../controllers/Language_Controller.dart';
import '../utils/location_service.dart';
import '../utils/network_service.dart';
import '../data/providers/api_provider.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/workshop_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../utils/websocket_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    _initializeServices();
    _initializeRepositories();
    _initializeControllers();
  }

  void _initializeServices() {
    if (!Get.isRegistered<NetworkService>()) {
      Get.put<NetworkService>(NetworkService(), permanent: true);
    }

    if (!Get.isRegistered<LocationService>()) {
      Get.put<LocationService>(LocationService(), permanent: true);
    }

    if (!Get.isRegistered<LanguageController>()) {
      Get.put<LanguageController>(LanguageController(), permanent: true);
    }

    if (!Get.isRegistered<WebSocketService>()) {
      Get.put<WebSocketService>(WebSocketService(), permanent: true);
    }

    if (!Get.isRegistered<Dio>()) {
      Get.put<Dio>(Dio(), permanent: true);
    }

    if (!Get.isRegistered<ApiProvider>()) {
      Get.put<ApiProvider>(ApiProvider(Get.find<Dio>()), permanent: true);
    }
  }

  void _initializeRepositories() {
    if (!Get.isRegistered<AuthRepository>()) {
      Get.put<AuthRepository>(AuthRepository(Get.find<ApiProvider>()),
          permanent: true);
    }

    if (!Get.isRegistered<UserRepository>()) {
      Get.put<UserRepository>(UserRepository(Get.find<ApiProvider>()),
          permanent: true);
    }

    Get.lazyPut<WorkshopRepository>(
        () => WorkshopRepository(Get.find<ApiProvider>()),
        fenix: true);

    Get.lazyPut<ServiceRepository>(
        () => ServiceRepository(Get.find<ApiProvider>()),
        fenix: true);

    Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find<ApiProvider>()),
        fenix: true);
  }

  void _initializeControllers() {
    if (!Get.isRegistered<AuthController>()) {
      Get.put<AuthController>(AuthController(Get.find<AuthRepository>()),
          permanent: true);
    }

    if (!Get.isRegistered<UserController>()) {
      Get.put<UserController>(
          UserController(
              Get.find<UserRepository>(), Get.find<AuthRepository>()),
          permanent: true);
    }

    Get.lazyPut<MapController>(() => MapController(), fenix: true);

    Get.lazyPut<WorkshopController>(
        () => WorkshopController(Get.find<WorkshopRepository>()),
        fenix: true);

    Get.lazyPut<ServiceController>(
        () => ServiceController(Get.find<ServiceRepository>()),
        fenix: true);

    Get.lazyPut<ChatController>(
        () => ChatController(Get.find<ChatRepository>()),
        fenix: true);

    Get.lazyPut(() => PrivacyPolicyController(), fenix: true);

  }
}
