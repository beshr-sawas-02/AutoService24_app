import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure all controllers needed for workshop owner functionality are available
    // These controllers are already initialized in AppModule,
    // but we make sure they're accessible for owner views

    // Authentication controller for owner session management
    Get.lazyPut<AuthController>(() => Get.find<AuthController>());

    // Workshop controller for managing workshops
    Get.lazyPut<WorkshopController>(() => Get.find<WorkshopController>());

    // Service controller for managing services
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>());

    // Chat controller for messaging with customers
    Get.lazyPut<ChatController>(() => Get.find<ChatController>());

    // User controller for profile management (owners are also users)
    Get.lazyPut<UserController>(() => Get.find<UserController>());
  }
}