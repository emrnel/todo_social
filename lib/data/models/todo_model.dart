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
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
    );
  }
}

class HashtagModel {
  final int id;
  final String tag;

  HashtagModel({
    required this.id,
    required this.tag,
  });

  factory HashtagModel.fromJson(Map<String, dynamic> json) {
    return HashtagModel(
      id: json['id'],
      tag: json['tag'],
    );
  }
}

class TodoModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isPublic;
  final int likeCount;
  final bool isLiked;
  final int commentCount;
  final int copyCount;
  final Map<String, dynamic>? originalAuthor;
  final CategoryModel? category;
  final List<HashtagModel> hashtags;
  final DateTime? completedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.isPublic,
    this.likeCount = 0,
    this.isLiked = false,
    this.commentCount = 0,
    this.copyCount = 0,
    this.originalAuthor,
    this.category,
    this.hashtags = const [],
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'] == true || json['isCompleted'] == 1,
      isPublic: json['isPublic'] == true || json['isPublic'] == 1,
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] == true || json['isLiked'] == 1,
      commentCount: json['commentCount'] ?? 0,
      copyCount: json['copyCount'] ?? 0,
      originalAuthor: json['originalAuthor'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      hashtags: (json['hashtags'] as List<dynamic>? ?? [])
          .map((h) => HashtagModel.fromJson(h))
          .toList(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  TodoModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isPublic,
    int? likeCount,
    bool? isLiked,
    int? commentCount,
    int? copyCount,
    Map<String, dynamic>? originalAuthor,
    CategoryModel? category,
    List<HashtagModel>? hashtags,
    DateTime? completedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isPublic: isPublic ?? this.isPublic,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      commentCount: commentCount ?? this.commentCount,
      copyCount: copyCount ?? this.copyCount,
      originalAuthor: originalAuthor ?? this.originalAuthor,
      category: category ?? this.category,
      hashtags: hashtags ?? this.hashtags,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isPublic': isPublic,
      'likeCount': likeCount,
      'isLiked': isLiked,
      'commentCount': commentCount,
      'copyCount': copyCount,
      'originalAuthor': originalAuthor,
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
