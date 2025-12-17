import 'package:dio/dio.dart';
import 'package:todo_social/data/models/user_model.dart';
import 'package:todo_social/features/user/data/models/user_profile_model.dart';

class SocialRepository {
  final Dio _dio;

  SocialRepository(this._dio);

  Future<List<UserModel>> searchUsers(String query) async {
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
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<UserProfileModel> getUserProfile(int userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      return UserProfileModel.fromJson(response.data['data']);
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<void> followUser(int userId) async {
    try {
      await _dio.post('/social/follow/$userId');
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<void> unfollowUser(int userId) async {
    try {
      await _dio.delete('/social/unfollow/$userId');
    } on DioException catch (_) {
      rethrow;
    }
  }
}
