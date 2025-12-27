import 'package:dio/dio.dart';
import '../models/statistics_model.dart';

class StatisticsRepository {
  final Dio _dio;

  StatisticsRepository(this._dio);

  Future<StatisticsModel> getMyStatistics() async {
    try {
      final response = await _dio.get('/statistics/my');
      if (response.statusCode == 200) {
        return StatisticsModel.fromJson(response.data['data']);
      }
      throw Exception('Failed to load statistics');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<LeaderboardUser>> getLeaderboard({
    String type = 'xp',
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/statistics/leaderboard',
        queryParameters: {'type': type, 'limit': limit},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => LeaderboardUser.fromJson(json)).toList();
      }
      throw Exception('Failed to load leaderboard');
    } catch (e) {
      rethrow;
    }
  }
}
