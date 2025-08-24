import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';

class CommonBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure all controllers are available for common/shared views
    // These are views that can be accessed by both users and owners
    // like chat, maps, service details, etc.

    // Authentication controller for session management
    Get.lazyPut<AuthController>(() => Get.find<AuthController>());

    // User controller for user-related operations
    Get.lazyPut<UserController>(() => Get.find<UserController>());

    // Workshop controller for workshop-related operations
    Get.lazyPut<WorkshopController>(() => Get.find<WorkshopController>());

    // Service controller for service-related operations
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>());

    // Chat controller for messaging functionality
    Get.lazyPut<ChatController>(() => Get.find<ChatController>());
  }
}