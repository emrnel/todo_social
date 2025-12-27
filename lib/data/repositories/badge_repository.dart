import 'package:dio/dio.dart';
import '../models/badge_model.dart';

class BadgeRepository {
  final Dio _dio;

  BadgeRepository(this._dio);

  Future<List<BadgeModel>> getAllBadges() async {
    try {
      final response = await _dio.get('/badges');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BadgeModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load badges');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BadgeModel>> getMyBadges() async {
    try {
      final response = await _dio.get('/badges/my');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BadgeModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load my badges');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BadgeModel>> getUserBadges(int userId) async {
    try {
      final response = await _dio.get('/badges/user/$userId');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => BadgeModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load user badges');
    } catch (e) {
      rethrow;
    }
  }
}
