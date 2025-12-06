import 'package:dio/dio.dart';
import 'dart:io';
import '../../utils/constants.dart';
import '../../utils/storage_service.dart';

class ApiProvider {
  static const String baseUrl = AppConstants.baseUrl;
  late Dio _dio;

  ApiProvider(Dio dio) {
    _dio = dio;
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

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
      final response = await _dio.post(
        '/auth/social-login',
        data: data,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );

      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> forgotPassword(Map<String, dynamic> data) async {
    return await _dio.post('/auth/forgot-password', data: data);
  }

  Future<Response> updateProfileWithImage(
      String userId,
      Map<String, dynamic> data,
      File? imageFile,
      ) async {
    try {
      FormData formData = FormData();

      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;

        formData.files.add(
          MapEntry(
            'profileImage',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: fileName,
            ),
          ),
        );
      }

      final response = await _dio.put(
        '/auth/edit/$userId',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${StorageService.getToken()}',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> sendForgotPasswordCode(Map<String, dynamic> data) async {
    return await _dio.post('/auth/sendforgotPassword', data: data);
  }

  Future<Response> verifyResetCode(Map<String, dynamic> data) async {
    return await _dio.post('/auth/verify-reset', data: data);
  }

  // User endpoints
  Future<Response> getUsers() async {
    return await _dio.get('/user');
  }

  Future<Response> getUser(String id) async {
    return await getUserById(id);
  }

  Future<Response> getUserById(String userId) async {
    try {
      final response = await _dio.get('/user/$userId');
      return response;
    } catch (e) {
      rethrow;
    }
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

  // Get nearby workshops by service type and location
  Future<Response> getNearbyWorkshops({
    required String type,
    required double longitude,
    required double latitude,
    int? radius,
  }) async {
    try {
      String url =
          '/workshop/nearby-workshops?type=$type&lng=$longitude&lat=$latitude';

      if (radius != null) {
        url += '&radius=$radius';
      }

      final response = await _dio.get(url);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Alternative method with Map parameters
  Future<Response> searchNearbyWorkshops(Map<String, dynamic> params) async {
    try {
      final response = await _dio.get(
        '/workshop/nearby-workshops',
        queryParameters: params,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> searchMapboxAddress(String address) async {
    final dio = Dio();
    return await dio.get(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$address.json',
      queryParameters: {
        'access_token': AppConstants.mapboxAccessToken,
        'country': 'SA',
        'language': 'ar',
        'limit': 5,
      },
    );
  }

  Future<Response> reverseGeocodeMapbox(double lat, double lng) async {
    final dio = Dio();
    return await dio.get(
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$lng,$lat.json',
      queryParameters: {
        'access_token': AppConstants.mapboxAccessToken,
        'language': 'ar',
      },
    );
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

  // Service endpoints - مع الـ Pagination
  Future<Response> getServices({
    String? serviceType,
    int skip = 0,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
      };

      if (serviceType != null && serviceType.isNotEmpty) {
        // تحويل من اسم الـ Enum إلى القيمة
        // CHANGE_OIL → Change oil
        final serviceTypeMap = {
          'VEHICLE_INSPECTION': 'Vehicle inspection & emissions test',
          'CHANGE_OIL': 'Change oil',
          'CHANGE_TIRES': 'Change tires',
          'REMOVE_INSTALL_TIRES': 'Remove & install tires',
          'CLEANING': 'Cleaning',
          'DIAGNOSTIC_TEST': 'Test with diagnostic',
          'AU_TUV': 'AU & TÜV ',
          'BALANCE_TIRES': 'Balance tires',
          'WHEEL_ALIGNMENT': 'Adjust wheel alignment',
          'POLISH': 'Polish',
          'CHANGE_BRAKE_FLUID': 'Change brake fluid',
        };

        final convertedValue = serviceTypeMap[serviceType];
        if (convertedValue != null) {
          queryParams['serviceType'] = convertedValue;
        }
      }

      final response = await _dio.get(
        '/services',
        queryParameters: queryParams,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> createService(Map<String, dynamic> data) async {
    return await _dio.post('/services/createservice', data: data);
  }

  Future<Response> createServiceWithImages(
      Map<String, dynamic> data, List<File>? imageFiles) async {
    try {
      FormData formData = FormData();

      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

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
      rethrow;
    }
  }

  Future<Response> uploadServiceImages(
      String serviceId, List<File> imageFiles) async {
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
      rethrow;
    }
  }

  Future<Response> searchServices(
      String query, {
        String? serviceType,
        int skip = 0,
        int limit = 10,
      }) async {
    try {
      final queryParams = {
        'q': query,
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (serviceType != null) {
        queryParams['serviceType'] = serviceType;
      }
      return await _dio.get(
        '/services/search',
        queryParameters: queryParams,
      );
    } catch (e) {
      rethrow;
    }
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
    try {
      final response = await _dio.post('/messages/sendmessage', data: data);
      return response;
    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  // Updated sendMessageWithImage method
  Future<Response> sendMessageWithImage(
      Map<String, dynamic> data, File? imageFile) async {
    try {
      if (imageFile == null) {
        return await sendMessage(data);
      }

      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist');
      }

      // Check file size (max 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image file is too large (max 10MB)');
      }

      FormData formData = FormData();

      // Add all text data
      data.forEach((key, value) {
        if (value != null) {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      // Add image file
      String fileName = imageFile.path.split('/').last;

      formData.files.add(
        MapEntry(
          'image', // This matches the backend FileInterceptor field name
          await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
          ),
        ),
      );

      final response = await _dio.post(
        '/messages/sendmessage',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          // Add timeout for large files
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 413) {
        throw Exception('Image file is too large');
      } else if (e.response?.statusCode == 415) {
        throw Exception('Image format not supported');
      } else if (e.response?.statusCode == 500) {
        throw Exception('Server error - Please try again later');
      }

      rethrow;
    } catch (e) {
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

  Future<Response> getWorkshopOwnerPhone(String serviceId) async {
    try {
      final response = await _dio.get('/services/$serviceId/owner-phone');
      return response;
    } catch (e) {
      rethrow;
    }
  }
}