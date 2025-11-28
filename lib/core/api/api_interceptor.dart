// lib/core/api/api_interceptor.dart
import 'package:dio/dio.dart';
import 'package:todo_social/core/services/storage_service.dart';

/// AuthInterceptor adds JWT token to all requests
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;

  AuthInterceptor(this._storageService);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // FE-CORE-20: Read token from storage
    final token = await _storageService.readToken();

    // FE-CORE-21: If token exists, add Authorization header
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Continue with the request
    handler.next(options);
  }
}
