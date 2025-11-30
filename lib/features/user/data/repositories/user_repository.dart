import 'package:dio/dio.dart';

import '../../../../data/models/user_model.dart';
import '../models/user_profile_model.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

  Future<List<UserModel>> searchUsers(String query) async {
    // API contract specifies a minimum of 2 characters for search
    if (query.length < 2) {
      return [];
    }
    
    try {
      final response = await _dio.get(
        '/users/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> userList = response.data['data']['users'];
      return userList.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error searching users: $e');
      rethrow;
    }
  }

  Future<UserProfileModel> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/users/profile/$username');
      return UserProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error getting user profile: $e');
      rethrow;
    }
  }

  Future<UserModel> getMyProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error getting my profile: $e');
      rethrow;
    }
  }

  Future<void> followUser(int userId) async {
    try {
      await _dio.post('/users/follow/$userId');
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error following user: $e');
      rethrow;
    }
  }

  Future<void> unfollowUser(int userId) async {
    try {
      await _dio.delete('/users/unfollow/$userId');
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error unfollowing user: $e');
      rethrow;
    }
  }
}
