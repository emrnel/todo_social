class FeedItemModel {
  final int id;
  final int userId;
  final String username;
  final String title;
  final String? description;
  final bool? isCompleted;
  final DateTime createdAt;
  final String type; // 'todo' or 'routine'
  final String? recurrenceType; // For routines
  final String? recurrenceValue; // For routines

  FeedItemModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    this.description,
    this.isCompleted,
    required this.createdAt,
    required this.type,
    this.recurrenceType,
    this.recurrenceValue,
  });

  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int
          ? json['userId']
          : int.parse(json['userId'].toString()),
      username: json['username'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      isCompleted: json['isCompleted'] == true || json['isCompleted'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'] ?? 'todo',
      recurrenceType: json['recurrenceType'],
      recurrenceValue: json['recurrenceValue'],
    );
  }
}
