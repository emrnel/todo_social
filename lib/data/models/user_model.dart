class UserModel {
  final int id;
  final String username;
  final String? email;
  final String? bio;
  final String? profilePicture;
  final String? bannerPicture;
  final String theme;
  final String themeColor;
  final int xp;
  final int level;
  final int currentStreak;
  final int longestStreak;
  final String? lastActivityDate;
  final int todosCompletedCount;
  final int followersCount;
  final int followingCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.username,
    this.email,
    this.bio,
    this.profilePicture,
    this.bannerPicture,
    this.theme = 'light',
    this.themeColor = 'blue',
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.lastActivityDate,
    this.todosCompletedCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: _toInt(json['id']) ?? 0,
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      profilePicture: json['profilePicture'],
      bannerPicture: json['bannerPicture'],
      theme: json['theme'] ?? 'light',
      themeColor: json['themeColor'] ?? 'blue',
      xp: _toInt(json['xp']) ?? 0,
      level: _toInt(json['level']) ?? 1,
      currentStreak: _toInt(json['currentStreak']) ?? 0,
      longestStreak: _toInt(json['longestStreak']) ?? 0,
      lastActivityDate: json['lastActivityDate'],
      todosCompletedCount: _toInt(json['todosCompletedCount']) ?? 0,
      followersCount: _toInt(json['followersCount']) ?? 0,
      followingCount: _toInt(json['followingCount']) ?? 0,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'profilePicture': profilePicture,
      'bannerPicture': bannerPicture,
      'theme': theme,
      'themeColor': themeColor,
      'xp': xp,
      'level': level,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'lastActivityDate': lastActivityDate,
      'todosCompletedCount': todosCompletedCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    int? id,
    String? username,
    String? email,
    String? bio,
    String? profilePicture,
    String? bannerPicture,
    String? theme,
    String? themeColor,
    int? xp,
    int? level,
    int? currentStreak,
    int? longestStreak,
    String? lastActivityDate,
    int? todosCompletedCount,
    int? followersCount,
    int? followingCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      bannerPicture: bannerPicture ?? this.bannerPicture,
      theme: theme ?? this.theme,
      themeColor: themeColor ?? this.themeColor,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActivityDate: lastActivityDate ?? this.lastActivityDate,
      todosCompletedCount: todosCompletedCount ?? this.todosCompletedCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
