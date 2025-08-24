import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure all controllers needed for user functionality are available
    // These controllers are already initialized in AppModule,
    // but we make sure they're accessible for user views

    // Authentication controller for user session management
    Get.lazyPut<AuthController>(() => Get.find<AuthController>());

    // User controller for profile management
    Get.lazyPut<UserController>(() => Get.find<UserController>());

    // Service controller for browsing and saving services
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>());

    // Chat controller for messaging with workshop owners
    Get.lazyPut<ChatController>(() => Get.find<ChatController>());
  }
}