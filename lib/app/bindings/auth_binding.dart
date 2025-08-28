import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Auth dependencies are already handled in AppModule
    // This binding ensures AuthController is available for auth views
    print("AuthBinding: Loading auth dependencies");
  }
}

class UserBinding extends Bindings {
  @override
  void dependencies() {
    // Since controllers are already created in AppModule with permanent: true,
    // we just need to ensure they're accessible (they already are)
    print("UserBinding: User view dependencies ready");

    // Optional: Force initialize controllers if needed
    try {
      Get.find<UserController>();
      Get.find<ServiceController>();
      Get.find<ChatController>();
      Get.find<AuthController>();
    } catch (e) {
      print("UserBinding error: Some controllers not found - $e");
    }
  }
}

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    // Since controllers are already created in AppModule with permanent: true,
    // we just need to ensure they're accessible (they already are)
    print("OwnerBinding: Owner view dependencies ready");

    // Optional: Force initialize controllers if needed
    try {
      Get.find<WorkshopController>();
      Get.find<ServiceController>();
      Get.find<ChatController>();
      Get.find<AuthController>();
      Get.find<UserController>();
    } catch (e) {
      print("OwnerBinding error: Some controllers not found - $e");
    }
  }
}

// Alternative approach - if you want to use lazy loading instead of permanent instances
class AlternativeAuthBinding extends Bindings {
  @override
  void dependencies() {
    // Lazy load only when needed
    Get.lazyPut<AuthController>(() => Get.find<AuthController>(), fenix: true);
  }
}

class AlternativeUserBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserController>(() => Get.find<UserController>(), fenix: true);
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>(), fenix: true);
    Get.lazyPut<ChatController>(() => Get.find<ChatController>(), fenix: true);
    Get.lazyPut<AuthController>(() => Get.find<AuthController>(), fenix: true);
  }
}

class AlternativeOwnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkshopController>(() => Get.find<WorkshopController>(), fenix: true);
    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>(), fenix: true);
    Get.lazyPut<ChatController>(() => Get.find<ChatController>(), fenix: true);
    Get.lazyPut<AuthController>(() => Get.find<AuthController>(), fenix: true);
    Get.lazyPut<UserController>(() => Get.find<UserController>(), fenix: true);
  }
}