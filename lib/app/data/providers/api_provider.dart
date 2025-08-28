import 'package:dio/dio.dart';
import 'dart:io';
import '../../utils/storage_service.dart';

class ApiProvider {
  static const String baseUrl = 'http://192.168.201.167:8000';
  late Dio _dio;

  ApiProvider(Dio dio) {
    _dio = dio;
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = Duration(seconds: 30);
    _dio.options.receiveTimeout = Duration(seconds: 30);

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await StorageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          StorageService.clearAll();
        }
        handler.next(error);
      },
    ));
  }

  // Auth endpoints
  Future<Response> login(Map<String, dynamic> data) async {
    return await _dio.post('/auth/signin', data: data);
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/auth/signup', data: data);
  }

  Future<Response> socialLogin(Map<String, dynamic> data) async {
    try {
      print("ApiProvider: socialLogin called with provider: ${data['provider']}");

      final response = await _dio.post(
        '/auth/social-login',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      print("ApiProvider: socialLogin response status: ${response.statusCode}");
      return response;
    } on DioException catch (e) {
      print("ApiProvider: socialLogin DioException: ${e.message}");
      print("ApiProvider: socialLogin response data: ${e.response?.data}");
      rethrow;
    } catch (e) {
      print("ApiProvider: socialLogin general error: $e");
      rethrow;
    }
  }

  Future<Response> forgotPassword(Map<String, dynamic> data) async {
    return await _dio.post('/auth/forgot-password', data: data);
  }

  // دالة جديدة لتحديث الملف الشخصي مع رفع الصورة
  Future<Response> updateProfileWithImage(String userId, Map<String, dynamic> data, File? imageFile) async {
    try {
      print("ApiProvider: updateProfileWithImage called for user $userId");

      FormData formData = FormData();

      // إضافة البيانات النصية
      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // إضافة الصورة إذا كانت موجودة
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        print("ApiProvider: Adding image file: $fileName");

        formData.files.add(
          MapEntry(
            'images', // هذا يطابق اسم الحقل في backend controller
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      print("ApiProvider: Sending PUT request to /auth/edit/$userId");

      final response = await _dio.put(
        '/auth/edit/$userId',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print("ApiProvider: updateProfileWithImage response status: ${response.statusCode}");
      return response;
    } catch (e) {
      print("ApiProvider updateProfileWithImage Error: $e");
      rethrow;
    }
  }

  // User endpoints
  Future<Response> getUsers() async {
    return await _dio.get('/user');
  }

  Future<Response> getUser(String id) async {
    return await _dio.get('/user/$id');
  }

  Future<Response> updateUser(String id, Map<String, dynamic> data) async {
    return await _dio.patch('/user/$id', data: data);
  }

  Future<Response> deleteUser(String id) async {
    return await _dio.delete('/user/$id');
  }

  // Workshop endpoints
  Future<Response> createWorkshop(Map<String, dynamic> data) async {
    return await _dio.post('/workshop/createworkshop', data: data);
  }

  Future<Response> getWorkshops() async {
    return await _dio.get('/workshop/getallworkshop');
  }

  Future<Response> getWorkshop(String id) async {
    return await _dio.get('/workshop/$id');
  }

  Future<Response> updateWorkshop(String id, Map<String, dynamic> data) async {
    return await _dio.patch('/workshop/$id', data: data);
  }

  Future<Response> deleteWorkshop(String id) async {
    return await _dio.delete('/workshop/$id');
  }

  // Service endpoints
  Future<Response> createService(Map<String, dynamic> data) async {
    return await _dio.post('/services/createservice', data: data);
  }

  // دالة جديدة لإنشاء خدمة مع صور
  Future<Response> createServiceWithImages(Map<String, dynamic> data, List<File>? imageFiles) async {
    try {
      FormData formData = FormData();

      // إضافة البيانات النصية
      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // إضافة الصور إذا كانت موجودة
      if (imageFiles != null && imageFiles.isNotEmpty) {
        for (File imageFile in imageFiles) {
          String fileName = imageFile.path.split('/').last;
          formData.files.add(
            MapEntry(
              'images',
              await MultipartFile.fromFile(
                imageFile.path,
                filename: fileName,
              ),
            ),
          );
        }
      }

      return await _dio.post(
        '/services/createservice',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      print("ApiProvider createServiceWithImages Error: $e");
      rethrow;
    }
  }

  // دالة لرفع صور إضافية لخدمة موجودة
  Future<Response> uploadServiceImages(String serviceId, List<File> imageFiles) async {
    try {
      FormData formData = FormData();

      for (File imageFile in imageFiles) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      return await _dio.post(
        '/services/$serviceId/upload-images',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      print("ApiProvider uploadServiceImages Error: $e");
      rethrow;
    }
  }

  Future<Response> getServices({String? serviceType}) async {
    String url = '/services/findallservice';
    if (serviceType != null) {
      url += '?serviceType=$serviceType';
    }
    return await _dio.get(url);
  }

  Future<Response> searchServices(String query, {String? serviceType}) async {
    String url = '/services/search?q=$query';
    if (serviceType != null) {
      url += '&serviceType=$serviceType';
    }
    return await _dio.get(url);
  }

  Future<Response> getServiceTypes() async {
    return await _dio.get('/services/types');
  }

  Future<Response> getService(String id) async {
    return await _dio.get('/services/$id');
  }

  Future<Response> updateService(String id, Map<String, dynamic> data) async {
    return await _dio.put('/services/$id', data: data);
  }

  Future<Response> deleteService(String id) async {
    return await _dio.delete('/services/$id');
  }

  // Saved services endpoints
  Future<Response> saveService(Map<String, dynamic> data) async {
    return await _dio.post('/saved-services', data: data);
  }

  Future<Response> getSavedServices() async {
    return await _dio.get('/saved-services');
  }

  Future<Response> unsaveService(String id) async {
    return await _dio.delete('/saved-services/$id');
  }

  // Chat endpoints
  Future<Response> createChat(Map<String, dynamic> data) async {
    return await _dio.post('/chats/createchat', data: data);
  }

  Future<Response> getChats() async {
    return await _dio.get('/chats/getallchat');
  }

  Future<Response> getChat(String id) async {
    return await _dio.get('/chats/$id');
  }

  Future<Response> deleteChat(String id) async {
    return await _dio.delete('/chats/$id');
  }

  // Message endpoints
  Future<Response> sendMessage(Map<String, dynamic> data) async {
    return await _dio.post('/messages/sendmessage', data: data);
  }

  // دالة جديدة لإرسال رسالة مع صورة
  Future<Response> sendMessageWithImage(Map<String, dynamic> data, File? imageFile) async {
    try {
      FormData formData = FormData();

      // إضافة البيانات النصية
      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // إضافة الصورة إذا كانت موجودة
      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'images',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      return await _dio.post(
        '/messages/sendmessage',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } catch (e) {
      print("ApiProvider sendMessageWithImage Error: $e");
      rethrow;
    }
  }

  Future<Response> getChatMessages(String chatId) async {
    return await _dio.get('/messages/chat/$chatId');
  }

  Future<Response> getMessage(String id) async {
    return await _dio.get('/messages/$id');
  }

  Future<Response> updateMessage(String id, Map<String, dynamic> data) async {
    return await _dio.patch('/messages/$id', data: data);
  }

  Future<Response> deleteMessage(String id) async {
    return await _dio.delete('/messages/$id');
  }
}