import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/data/models/auth_response_model.dart';
import 'package:todo_social/core/services/storage_service.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'dart:developer' as developer;

/// Repository layer for authentication logic.
/// Handles API calls for login, register, and token management.
class AuthRepository {
  final Dio dio;

  /// Creates an instance of AuthRepository with injected Dio client.
  AuthRepository({required this.dio});

  /// Logs in the user with email and password.
  /// Returns AuthResponseModel on success.
  Future<AuthResponseModel> login(
      {required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      developer.log('Login error: ${e.message}\nResponse: ${e.response?.data}',
          name: 'AuthRepository');
      rethrow;
    } catch (e) {
      developer.log('Unexpected login error: $e', name: 'AuthRepository');
      rethrow;
    }
  }

  /// Registers a new user with username, email, and password.
  /// Returns AuthResponseModel on success.
  Future<AuthResponseModel> register(
      {required String username,
      required String email,
      required String password}) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      developer.log(
          'Register error: ${e.message}\nResponse: ${e.response?.data}',
          name: 'AuthRepository');
      rethrow;
    } catch (e) {
      developer.log('Unexpected register error: $e', name: 'AuthRepository');
      rethrow;
    }
  }

  /// Saves the authentication token using StorageService.
  /// Requires an instance of StorageService.
  Future<void> saveToken(String token, StorageService storageService) async {
    await storageService.writeToken(token);
  }
}

/// Riverpod provider for AuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return AuthRepository(dio: dio);
});
