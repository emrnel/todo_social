import 'package:dio/dio.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'));

  AuthService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await SecureStorage.saveToken(token);
        }
        return true;
      }
    } catch (e) {
      print('Register error: $e');
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        final token = response.data['token'];
        if (token != null) {
          await SecureStorage.saveToken(token);
        }
        return true;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return false;
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return response.data;
    } catch (e) {
      print('Get profile error: $e');
      return null;
    }
  }

}
