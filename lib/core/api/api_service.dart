// lib/core/api/api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_interceptor.dart';
import 'package:todo_social/core/services/storage_service.dart';

/// Global Dio instance provider with AuthInterceptor
final apiServiceProvider = Provider<Dio>((ref) {
  final storageService = ref.watch(storageServiceProvider);

  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  // FE-CORE-22: Add AuthInterceptor to Dio
  dio.interceptors.add(AuthInterceptor(storageService));

  return dio;
});
