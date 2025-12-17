// lib/core/api/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_interceptor.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'dart:developer' as developer;

/// Global Dio instance provider with AuthInterceptor
final apiServiceProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(storageServiceProvider);

  final dio = Dio(BaseOptions(
    baseUrl: _resolveBaseUrl(),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // FE-CORE-22: Add AuthInterceptor to Dio
  dio.interceptors.add(AuthInterceptor(storageService));

  // Add debug logging interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        developer.log(
            'Request: ${options.method} ${options.baseUrl}${options.path}',
            name: 'Dio');
        developer.log('Body: ${options.data}', name: 'Dio');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        developer.log(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
            name: 'Dio');
        return handler.next(response);
      },
      onError: (error, handler) {
        developer.log('Error: ${error.message}', name: 'Dio');
        developer.log('Status: ${error.response?.statusCode}', name: 'Dio');
        developer.log('Response: ${error.response?.data}', name: 'Dio');
        return handler.next(error);
      },
    ),
  );

  return dio;
});

/// Alias for dioProvider (commonly used name)
final dioProvider = apiServiceProvider;

/// Resolve API base URL per platform so mobile emulators reach localhost backend.
String _resolveBaseUrl() {
  const apiPort = 3000;

  if (kIsWeb) return 'http://localhost:$apiPort/api';

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return 'http://10.0.2.2:$apiPort/api';
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return 'http://localhost:$apiPort/api';
  }
}
