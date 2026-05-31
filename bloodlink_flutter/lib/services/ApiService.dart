import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../utils/Config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final _storage = const FlutterSecureStorage();

  ApiService() {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  // --- Auth ---
  Future<Response> login(String username, String password) async {
    return await dio.post(
      '/login/',
      data: {'username': username, 'password': password},
    );
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await dio.post('/register/', data: data);
  }

  // --- Donors ---
  Future<Response> getDonors({String? bloodGroup, String? city}) async {
    return await dio.get(
      '/donors/',
      queryParameters: {
        if (bloodGroup != null) 'blood_group': bloodGroup,
        if (city != null) 'city': city,
      },
    );
  }

  // --- Cities & Blood Groups ---
  Future<Response> getCities() async {
    return await dio.get('/cities/');
  }

  Future<Response> getBloodGroups() async {
    return await dio.get('/blood-groups/');
  }
  Future<Response> sendBloodRequest(Map<String, dynamic> data) async {
    return await dio.post('/requests/send/', data: data);
  }

  Future<Response> getMyRequests(String role, {String? status}) async {
    return await dio.get(
      '/requests/my/',
      queryParameters: {
        'role': role,
        if (status != null) 'status': status,
      },
    );
  }

  Future<Response> updateRequestStatus(
    int id,
    String status, {
    String? message,
  }) async {
    return await dio.post(
      '/requests/update/',
      data: {'id': id, 'status': status, 'message': message},
    );
  }

  Future<Response> acknowledgeRequest(int id) async {
    return await dio.post(
      '/requests/acknowledge/',
      data: {'id': id},
    );
  }

  // --- Profile ---
  Future<Response> verifyPassword(String password) async {
    return await dio.post('/password/verify/', data: {'password': password});
  }

  Future<Response> updateProfile(
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    Map<String, dynamic> formDataMap = {...data};
    
    if (imagePath != null) {
      formDataMap['image'] = await MultipartFile.fromFile(
        imagePath,
        filename: imagePath.split('/').last,
      );
    }
    
    final formData = FormData.fromMap(formDataMap);
    
    return await dio.post('/profile/update/', data: formData);
  }

  Future<Response> changePassword(String oldPassword, String newPassword) async {
    return await dio.post(
      '/password/change/',
      data: {'old_password': oldPassword, 'new_password': newPassword},
    );
  }
}
