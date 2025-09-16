// // bindings/initial_binding.dart
// import 'package:get/get.dart';
// import 'package:dio/dio.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/user_controller.dart';
// import '../controllers/workshop_controller.dart';
// import '../controllers/service_controller.dart';
// import '../controllers/chat_controller.dart';
// import '../controllers/map_controller.dart';
// import '../utils/location_service.dart';
// import '../data/providers/api_provider.dart';
// import '../data/repositories/auth_repository.dart';
// import '../data/repositories/user_repository.dart';
// import '../data/repositories/workshop_repository.dart';
// import '../data/repositories/service_repository.dart';
// import '../data/repositories/chat_repository.dart';
//
// class InitialBinding extends Bindings {
//   @override
//   void dependencies() {
//     _initializeBasicServices();
//
//     _initializeRepositories();
//
//     _initializeBasicControllers();
//
//     _initializeAdditionalServices();
//   }
//
//   void _initializeBasicServices() {
//     Get.put<Dio>(Dio(), permanent: true);
//
//     // ApiProvider
//     Get.put<ApiProvider>(ApiProvider(Get.find<Dio>()), permanent: true);
//   }
//
//   void _initializeRepositories() {
//     Get.put<AuthRepository>(AuthRepository(Get.find<ApiProvider>()),
//         permanent: true);
//
//     Get.put<UserRepository>(UserRepository(Get.find<ApiProvider>()),
//         permanent: true);
//
//     Get.lazyPut<WorkshopRepository>(
//         () => WorkshopRepository(Get.find<ApiProvider>()));
//
//     Get.lazyPut<ServiceRepository>(
//         () => ServiceRepository(Get.find<ApiProvider>()));
//
//     Get.lazyPut<ChatRepository>(() => ChatRepository(Get.find<ApiProvider>()));
//   }
//
//   void _initializeBasicControllers() {
//     Get.put<AuthController>(AuthController(Get.find<AuthRepository>()),
//         permanent: true);
//
//     Get.put<UserController>(
//         UserController(Get.find<UserRepository>(), Get.find<AuthRepository>()),
//         permanent: true);
//   }
//
//   void _initializeAdditionalServices() {
//     Get.lazyPut<MapController>(() => MapController());
//
//     Get.lazyPut<WorkshopController>(
//         () => WorkshopController(Get.find<WorkshopRepository>()));
//
//     Get.lazyPut<ServiceController>(
//         () => ServiceController(Get.find<ServiceRepository>()));
//
//     Get.lazyPut<ChatController>(
//         () => ChatController(Get.find<ChatRepository>()));
//   }
// }
