import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/data/models/auth_response_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = Dio(BaseOptions(
    // Android Emulator için 10.0.2.2 kullan
    baseUrl: 'http://10.0.2.2:3000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  final storageService = ref.watch(storageServiceProvider);

  return AuthService(dio, storageService);
});

class AuthService {
  final Dio _dio;
  final StorageService _storageService;

  AuthService(this._dio, this._storageService);

  // Register method matching API contract
  Future<AuthResponseModel> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {
          "username": username,
          "email": email,
          "password": password,
        },
      );

      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw e.response!.data['message'] ?? 'Registration failed';
      }
      throw 'Network error occurred';
    }
  }

  // Login method matching API contract
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          "email": email,
          "password": password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      if (authResponse.success && authResponse.token != null) {
        await _storageService.writeToken(authResponse.token!);
      }

      return authResponse;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw e.response!.data['message'] ?? 'Login failed';
      }
      throw 'Network error occurred';
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _storageService.readToken();
    return token != null;
  }

  // Logout
  Future<void> logout() async {
    await _storageService.deleteToken();
  }
}
