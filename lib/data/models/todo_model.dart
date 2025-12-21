class TodoModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isPublic;
  final int likeCount;
  final bool isLiked;
  final Map<String, dynamic>? originalAuthor;
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
    this.originalAuthor,
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
      originalAuthor: json['originalAuthor'],
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
    Map<String, dynamic>? originalAuthor,
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
      originalAuthor: originalAuthor ?? this.originalAuthor,
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
      'originalAuthor': originalAuthor,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
