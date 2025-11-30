class FeedItemModel {
  final int id;
  final int userId;
  final String username;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isPublic;
  final DateTime createdAt;

  FeedItemModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.isPublic,
    required this.createdAt,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['id'],
      userId: json['userId'],
      username: json['username'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
