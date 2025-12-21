class FeedItemModel {
  final int id;
  final int userId;
  final String username;
  final String title;
  final String? description;
  final bool? isCompleted;
  final int? likeCount;
  final bool? isLiked;
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
    this.likeCount,
    this.isLiked,
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
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] == true || json['isLiked'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'] ?? 'todo',
      recurrenceType: json['recurrenceType'],
      recurrenceValue: json['recurrenceValue'],
    );
  }

  FeedItemModel copyWith({
    int? id,
    int? userId,
    String? username,
    String? title,
    String? description,
    bool? isCompleted,
    int? likeCount,
    bool? isLiked,
    DateTime? createdAt,
    String? type,
    String? recurrenceType,
    String? recurrenceValue,
  }) {
    return FeedItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceValue: recurrenceValue ?? this.recurrenceValue,
    );
  }
}
