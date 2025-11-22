import 'user_model.dart';
import 'todo_model.dart';

class UserProfileModel {
  final UserModel user;
  final bool isFollowing;
  final int followerCount;
  final int followingCount;
  final List<TodoModel> publicTodos;

  UserProfileModel({
    required this.user,
    required this.isFollowing,
    required this.followerCount,
    required this.followingCount,
    required this.publicTodos,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      user: UserModel.fromJson(json['user']),
      isFollowing: json['isFollowing'] ?? false,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      publicTodos: json['publicTodos'] != null
          ? (json['publicTodos'] as List)
              .map((i) => TodoModel.fromJson(i))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'isFollowing': isFollowing,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'publicTodos': publicTodos.map((todo) => todo.toJson()).toList(),
    };
  }
}