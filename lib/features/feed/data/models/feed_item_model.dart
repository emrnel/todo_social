class FeedItemModel {
  final int id;
  final int userId;
  final String username;
  final String title;
  final String? description;
  final bool? isCompleted;
  final int? likeCount;
  final int? commentCount;
  final bool? isLiked;
  final DateTime createdAt;
  final String type; // 'todo' or 'routine'
  final String? recurrenceType; // For routines
  final String? recurrenceValue; // For routines
  final CategoryModel? category;
  final List<String> hashtags;

  FeedItemModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.title,
    this.description,
    this.isCompleted,
    this.likeCount,
    this.commentCount,
    this.isLiked,
    required this.createdAt,
    required this.type,
    this.recurrenceType,
    this.recurrenceValue,
    this.category,
    this.hashtags = const [],
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
      commentCount: json['commentCount'] ?? 0,
      isLiked: json['isLiked'] == true || json['isLiked'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'] ?? 'todo',
      recurrenceType: json['recurrenceType'],
      recurrenceValue: json['recurrenceValue'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      hashtags: json['hashtags'] != null
          ? (json['hashtags'] as List).map((h) => h['tag'] as String).toList()
          : [],
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
    int? commentCount,
    bool? isLiked,
    DateTime? createdAt,
    String? type,
    String? recurrenceType,
    String? recurrenceValue,
    CategoryModel? category,
    List<String>? hashtags,
  }) {
    return FeedItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      username: username ?? this.username,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceValue: recurrenceValue ?? this.recurrenceValue,
      category: category ?? this.category,
      hashtags: hashtags ?? this.hashtags,
    );
  }
}

// Import CategoryModel at the top
class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? color;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      icon: json['icon'],
      color: json['color'],
    );
  }
}
