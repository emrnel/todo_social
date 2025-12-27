import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/data/repositories/statistics_repository.dart';
import 'package:todo_social/data/models/statistics_model.dart';

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return StatisticsRepository(dio);
});

final myStatisticsProvider = FutureProvider<StatisticsModel>((ref) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getMyStatistics();
});

final leaderboardProvider = FutureProvider.family<List<LeaderboardUser>, String>((ref, type) async {
  final repository = ref.watch(statisticsRepositoryProvider);
  return repository.getLeaderboard(type: type);
});
