class CommentModel {
  final int id;
  final int userId;
  final int todoId;
  final String text;
  final String username;
  final String? profilePicture;
  final DateTime createdAt;
  final DateTime updatedAt;

  CommentModel({
    required this.id,
    required this.userId,
    required this.todoId,
    required this.text,
    required this.username,
    this.profilePicture,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return CommentModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      todoId: json['todoId'] as int,
      text: json['text'] as String,
      username: user?['username'] as String? ?? 'Unknown',
      profilePicture: user?['profilePicture'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'todoId': todoId,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
