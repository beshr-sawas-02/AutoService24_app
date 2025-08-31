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
import 'utils/websocket_service.dart'; // إضافة جديدة

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

    // WebSocket Service - إضافة جديدة (يجب أن تكون قبل ChatController)
    Get.put<WebSocketService>(WebSocketService(), permanent: true);

    // Controllers
    Get.put<AuthController>(
        AuthController(Get.find<AuthRepository>()),
        permanent: true
    );

    // تصحيح UserController - يحتاج UserRepository و AuthRepository
    Get.put<UserController>(
        UserController(Get.find<UserRepository>(), Get.find<AuthRepository>()),
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

    // ChatController يجب أن يكون بعد WebSocketService
    Get.put<ChatController>(
        ChatController(Get.find<ChatRepository>()),
        permanent: true
    );

    print("🚀 AppModule: All dependencies initialized successfully");
  }

  // دالة للتحقق من أن كل التبعيات تم تحميلها بنجاح
  static void verifyDependencies() {
    try {
      Get.find<Dio>();
      Get.find<ApiProvider>();
      Get.find<AuthRepository>();
      Get.find<UserRepository>();
      Get.find<WorkshopRepository>();
      Get.find<ServiceRepository>();
      Get.find<ChatRepository>();
      Get.find<WebSocketService>(); // إضافة جديدة
      Get.find<AuthController>();
      Get.find<UserController>();
      Get.find<WorkshopController>();
      Get.find<ServiceController>();
      Get.find<ChatController>();

      print("✅ AppModule: All dependencies verified successfully");
    } catch (e) {
      print("❌ AppModule: Dependency verification failed: $e");
    }
  }

  // دالة لتنظيف جميع التبعيات (مفيدة للاختبارات أو إعادة التشغيل)
  static void cleanup() {
    try {
      // قطع اتصال WebSocket قبل التنظيف
      if (Get.isRegistered<WebSocketService>()) {
        Get.find<WebSocketService>().disconnect();
      }

      // حذف جميع التبعيات
      Get.deleteAll(force: true);
      print("🧹 AppModule: All dependencies cleaned up");
    } catch (e) {
      print("❌ AppModule: Cleanup failed: $e");
    }
  }

  // دالة لإعادة تهيئة WebSocket (مفيدة عند تغيير المستخدم)
  static Future<void> reinitializeWebSocket() async {
    try {
      if (Get.isRegistered<WebSocketService>()) {
        final webSocketService = Get.find<WebSocketService>();
        webSocketService.disconnect();
        await Future.delayed(Duration(seconds: 1));
        await webSocketService.connect();
        print("🔄 AppModule: WebSocket reinitialized");
      }
    } catch (e) {
      print("❌ AppModule: WebSocket reinitialization failed: $e");
    }
  }
}