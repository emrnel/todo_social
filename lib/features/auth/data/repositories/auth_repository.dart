import 'package:dio/dio.dart';
import 'package:todo_social/data/models/auth_response_model.dart';
import 'package:todo_social/core/services/storage_service.dart';

/// Repository layer for authentication logic.
/// Handles API calls for login, register, and token management.
class AuthRepository {
  final Dio dio;

  /// Creates an instance of AuthRepository with injected Dio client.
  AuthRepository({required this.dio});


  /// Logs in the user with email and password.
  /// Returns AuthResponseModel on success.
  Future<AuthResponseModel> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/api/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      // You can add more detailed error handling here
      rethrow;
    }
  }

  /// Registers a new user with username, email, and password.
  /// Returns AuthResponseModel on success.
  Future<AuthResponseModel> register({required String username, required String email, required String password}) async {
    try {
      final response = await dio.post(
        '/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
        },
      );
      return AuthResponseModel.fromJson(response.data);
    } catch (e) {
      // You can add more detailed error handling here
      rethrow;
    }
  }

  /// Saves the authentication token using StorageService.
  /// Requires an instance of StorageService.
  Future<void> saveToken(String token, StorageService storageService) async {
    await storageService.writeToken(token);
  }
}
