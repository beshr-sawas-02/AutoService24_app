import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'controllers/auth_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/workshop_controller.dart';
import 'controllers/service_controller.dart';
import 'controllers/chat_controller.dart';
import 'data/providers/api_provider.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/repositories/workshop_repository.dart';
import 'data/repositories/service_repository.dart';
import 'data/repositories/chat_repository.dart';

class AppModule {
  static void init() {
    // Core dependencies
    Get.put<Dio>(Dio(), permanent: true);

    // Providers
    Get.put<ApiProvider>(
        ApiProvider(Get.find<Dio>()),
        permanent: true
    );

    // Repositories
    Get.put<AuthRepository>(
        AuthRepository(Get.find<ApiProvider>()),
        permanent: true
    );
    Get.put<UserRepository>(
        UserRepository(Get.find<ApiProvider>()),
        permanent: true
    );
    Get.put<WorkshopRepository>(
        WorkshopRepository(Get.find<ApiProvider>()),
        permanent: true
    );
    Get.put<ServiceRepository>(
        ServiceRepository(Get.find<ApiProvider>()),
        permanent: true
    );
    Get.put<ChatRepository>(
        ChatRepository(Get.find<ApiProvider>()),
        permanent: true
    );

    // Controllers
    Get.put<AuthController>(
        AuthController(Get.find<AuthRepository>()),
        permanent: true
    );
    Get.put<UserController>(
        UserController(Get.find<UserRepository>()),
        permanent: true
    );
    Get.put<WorkshopController>(
        WorkshopController(Get.find<WorkshopRepository>()),
        permanent: true
    );
    Get.put<ServiceController>(
        ServiceController(Get.find<ServiceRepository>()),
        permanent: true
    );
    Get.put<ChatController>(
        ChatController(Get.find<ChatRepository>()),
        permanent: true
    );
  }
}