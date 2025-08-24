import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/workshop_repository.dart';
import '../data/repositories/service_repository.dart';
import '../data/repositories/chat_repository.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Auth dependencies are handled in AppModule
    // This ensures AuthController is available for auth views
  }
}

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure all controllers needed for user views are available
    Get.lazyPut<UserController>(() => Get.find<UserController>());
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>());
    Get.lazyPut<ChatController>(() => Get.find<ChatController>());
    Get.lazyPut<AuthController>(() => Get.find<AuthController>());
  }
}

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    // Ensure all controllers needed for owner views are available
    Get.lazyPut<WorkshopController>(() => Get.find<WorkshopController>());
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>());
    Get.lazyPut<ChatController>(() => Get.find<ChatController>());
    Get.lazyPut<AuthController>(() => Get.find<AuthController>());
    Get.lazyPut<UserController>(() => Get.find<UserController>());
  }
}