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
      throw Exception('Kullanıcı arama hatası: ${e.message}');
    }
  }

  Future<UserProfileModel> getUserProfile(String username) async {
    try {
      final response = await _dio.get('/users/profile/$username');
      return UserProfileModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception('Profil getirme hatası: ${e.message}');
    }
  }

  Future<UserModel> getMyProfile() async {
    try {
      final response = await _dio.get('/users/me');
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw Exception('Profil getirme hatası: ${e.message}');
    }
  }

  Future<List<UserModel>> getFollowingUsers() async {
    try {
      final response = await _dio.get('/social/following');
      final List<dynamic> userList = response.data['data']['following'] ?? [];
      return userList.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(
          'Takip edilen kullanıcıları getirme hatası: ${e.message}');
    }
  }

  Future<void> followUser(int userId) async {
    try {
      await _dio.post('/social/follow/$userId');
    } on DioException catch (e) {
      throw Exception('Takip etme hatası: ${e.message}');
    }
  }

  Future<void> unfollowUser(int userId) async {
    try {
      await _dio.delete('/social/unfollow/$userId');
    } on DioException catch (e) {
      throw Exception('Takipten çıkma hatası: ${e.message}');
    }
  }
}
