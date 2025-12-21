class PublicTodoModel {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final int likeCount;
  final bool isLiked;
  final Map<String, dynamic>? originalAuthor;
  final DateTime createdAt;

  PublicTodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    this.likeCount = 0,
    this.isLiked = false,
    this.originalAuthor,
    required this.createdAt,
  });

  factory PublicTodoModel.fromJson(Map<String, dynamic> json) {
    return PublicTodoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      isCompleted: json['isCompleted'] == true || json['isCompleted'] == 1,
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLiked'] == true || json['isLiked'] == 1,
      originalAuthor: json['originalAuthor'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  PublicTodoModel copyWith({
    int? id,
    String? title,
    String? description,
    bool? isCompleted,
    int? likeCount,
    bool? isLiked,
    Map<String, dynamic>? originalAuthor,
    DateTime? createdAt,
  }) {
    return PublicTodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      likeCount: likeCount ?? this.likeCount,
      isLiked: isLiked ?? this.isLiked,
      originalAuthor: originalAuthor ?? this.originalAuthor,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
