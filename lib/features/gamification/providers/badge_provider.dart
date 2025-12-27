import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/data/repositories/badge_repository.dart';
import 'package:todo_social/data/models/badge_model.dart';

final badgeRepositoryProvider = Provider<BadgeRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BadgeRepository(dio);
});

final allBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final repository = ref.watch(badgeRepositoryProvider);
  return repository.getAllBadges();
});

final myBadgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final repository = ref.watch(badgeRepositoryProvider);
  return repository.getMyBadges();
});

final userBadgesProvider = FutureProvider.family<List<BadgeModel>, int>((ref, userId) async {
  final repository = ref.watch(badgeRepositoryProvider);
  return repository.getUserBadges(userId);
});
