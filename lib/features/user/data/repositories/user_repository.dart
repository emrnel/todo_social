import 'package:dio/dio.dart';

import '../../../../data/models/user_model.dart';
import '../models/user_profile_model.dart';

class UserRepository {
  final Dio _dio;

  UserRepository(this._dio);

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

  Future<Map<String, dynamic>> getMyProfile() async {
    try {
      final response = await _dio.get('/users/me');
      final data = response.data['data'];

      return {
        'user': UserModel.fromJson(data['user']),
        'followerCount': _parseCount(data['followerCount']),
        'followingCount': _parseCount(data['followingCount']),
      };
    } on DioException catch (e) {
      throw Exception('Profil getirme hatası: ${e.message}');
    }
  }

  Future<UserModel> updateProfile({String? bio, String? profilePicture}) async {
    try {
      final Map<String, dynamic> data = {};
      if (bio != null) data['bio'] = bio;
      if (profilePicture != null) data['profilePicture'] = profilePicture;

      final response = await _dio.patch('/users/me', data: data);
      return UserModel.fromJson(response.data['data']['user']);
    } on DioException catch (e) {
      throw Exception('Profil güncelleme hatası: ${e.message}');
    }
  }

  int _parseCount(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      try {
        return int.parse(value);
      } catch (e) {
        return 0;
      }
    }
    return 0;
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
