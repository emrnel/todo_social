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
    return UserProfileModel(
      user: UserModel.fromJson(json['user']),
      isFollowing: json['isFollowing'],
      followerCount: json['followerCount'],
      followingCount: json['followingCount'],
      publicTodos: (json['publicTodos'] as List)
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
