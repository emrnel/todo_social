import '../../../../data/models/user_model.dart';
import 'public_todo_model.dart';

class UserProfileModel {
  final UserModel user;
  final bool isFollowing;
  final int followerCount;
  final int followingCount;
  final List<PublicTodoModel> publicTodos;

  UserProfileModel({
    required this.user,
    required this.isFollowing,
    required this.followerCount,
    required this.followingCount,
    required this.publicTodos,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    // Safe integer parsing
    int parseCount(dynamic value) {
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

    return UserProfileModel(
      user: UserModel.fromJson(json['user']),
      isFollowing: json['isFollowing'] == true,
      followerCount: parseCount(json['followerCount']),
      followingCount: parseCount(json['followingCount']),
      publicTodos: (json['publicTodos'] as List<dynamic>? ?? [])
          .map((todoJson) => PublicTodoModel.fromJson(todoJson))
          .toList(),
    );
  }

  UserProfileModel copyWith({
    UserModel? user,
    bool? isFollowing,
    int? followerCount,
    int? followingCount,
    List<PublicTodoModel>? publicTodos,
  }) {
    return UserProfileModel(
      user: user ?? this.user,
      isFollowing: isFollowing ?? this.isFollowing,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      publicTodos: publicTodos ?? this.publicTodos,
    );
  }
}
