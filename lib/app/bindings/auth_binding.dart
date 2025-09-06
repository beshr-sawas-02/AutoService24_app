import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {}
}

class UserBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.find<UserController>();
      Get.find<ServiceController>();
      Get.find<ChatController>();
      Get.find<AuthController>();
    } catch (e) {}
  }
}

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    try {
      Get.find<WorkshopController>();
      Get.find<ServiceController>();
      Get.find<ChatController>();
      Get.find<AuthController>();
      Get.find<UserController>();
    } catch (e) {}
  }
}

class AlternativeAuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => Get.find<AuthController>(), fenix: true);
  }
}

class AlternativeUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => Get.find<UserController>(), fenix: true);
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>(),
        fenix: true);
    Get.lazyPut<ChatController>(() => Get.find<ChatController>(), fenix: true);
    Get.lazyPut<AuthController>(() => Get.find<AuthController>(), fenix: true);
  }
}

class AlternativeOwnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkshopController>(() => Get.find<WorkshopController>(),
        fenix: true);
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>(),
        fenix: true);
    Get.lazyPut<ChatController>(() => Get.find<ChatController>(), fenix: true);
    Get.lazyPut<AuthController>(() => Get.find<AuthController>(), fenix: true);
    Get.lazyPut<UserController>(() => Get.find<UserController>(), fenix: true);
  }
}
