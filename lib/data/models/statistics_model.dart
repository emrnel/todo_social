class StatisticsModel {
  final UserStats user;
  final Stats stats;
  final List<CategoryBreakdown> categoryBreakdown;

  StatisticsModel({
    required this.user,
    required this.stats,
    required this.categoryBreakdown,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      user: UserStats.fromJson(json['user']),
      stats: Stats.fromJson(json['stats']),
      categoryBreakdown: (json['categoryBreakdown'] as List<dynamic>? ?? [])
          .map((e) => CategoryBreakdown.fromJson(e))
          .toList(),
    );
  }
}

class UserStats {
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int todosCompletedCount;
  final int followersCount;
  final int followingCount;

  UserStats({
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.todosCompletedCount,
    required this.followersCount,
    required this.followingCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      xp: _toInt(json['xp']) ?? 0,
      level: _toInt(json['level']) ?? 1,
      currentStreak: _toInt(json['currentStreak']) ?? 0,
      longestStreak: _toInt(json['longestStreak']) ?? 0,
      todosCompletedCount: _toInt(json['todosCompletedCount']) ?? 0,
      followersCount: _toInt(json['followersCount']) ?? 0,
      followingCount: _toInt(json['followingCount']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  int getXpForCurrentLevel() {
    // Level formula: level = floor(sqrt(xp / 100)) + 1
    // Reverse: xp for level start = (level - 1)^2 * 100
    return (level - 1) * (level - 1) * 100;
  }

  int getXpForNextLevel() {
    return level * level * 100;
  }

  double getXpProgress() {
    final currentLevelXp = getXpForCurrentLevel();
    final nextLevelXp = getXpForNextLevel();
    final levelXpRange = nextLevelXp - currentLevelXp;
    final currentProgress = xp - currentLevelXp;
    return currentProgress / levelXpRange;
  }
}

class Stats {
  final int totalTodos;
  final int publicTodosCount;
  final int completedTodos;
  final double completionRate;
  final int likesReceived;
  final int commentsReceived;
  final int weeklyCompletedTodos;
  final int monthlyCompletedTodos;
  final String? mostProductiveDay;

  Stats({
    required this.totalTodos,
    required this.publicTodosCount,
    required this.completedTodos,
    required this.completionRate,
    required this.likesReceived,
    required this.commentsReceived,
    required this.weeklyCompletedTodos,
    required this.monthlyCompletedTodos,
    this.mostProductiveDay,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalTodos: _toInt(json['totalTodos']) ?? 0,
      publicTodosCount: _toInt(json['publicTodosCount']) ?? 0,
      completedTodos: _toInt(json['completedTodos']) ?? 0,
      completionRate: _toDouble(json['completionRate']) ?? 0.0,
      likesReceived: _toInt(json['likesReceived']) ?? 0,
      commentsReceived: _toInt(json['commentsReceived']) ?? 0,
      weeklyCompletedTodos: _toInt(json['weeklyCompletedTodos']) ?? 0,
      monthlyCompletedTodos: _toInt(json['monthlyCompletedTodos']) ?? 0,
      mostProductiveDay: json['mostProductiveDay'],
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class CategoryBreakdown {
  final int? categoryId;
  final int count;

  CategoryBreakdown({
    this.categoryId,
    required this.count,
  });

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      categoryId: _toInt(json['categoryId']),
      count: _toInt(json['count']) ?? 0,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }
}

class LeaderboardUser {
  final int id;
  final String username;
  final String? profilePicture;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final int todosCompletedCount;
  final int followersCount;

  LeaderboardUser({
    required this.id,
    required this.username,
    this.profilePicture,
    required this.xp,
    required this.level,
    required this.currentStreak,
    required this.longestStreak,
    required this.todosCompletedCount,
    required this.followersCount,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['id'],
      username: json['username'],
      profilePicture: json['profilePicture'],
      xp: json['xp'] ?? 0,
      level: json['level'] ?? 1,
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      todosCompletedCount: json['todosCompletedCount'] ?? 0,
      followersCount: json['followersCount'] ?? 0,
    );
  }
}
