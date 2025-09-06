import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/user_controller.dart';
import '../controllers/workshop_controller.dart';
import '../controllers/service_controller.dart';
import '../controllers/chat_controller.dart';

class OwnerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => Get.find<AuthController>());

    Get.lazyPut<WorkshopController>(() => Get.find<WorkshopController>());

    Get.lazyPut<ServiceController>(() => Get.find<ServiceController>());

    Get.lazyPut<ChatController>(() => Get.find<ChatController>());

    Get.lazyPut<UserController>(() => Get.find<UserController>());
  }
}
