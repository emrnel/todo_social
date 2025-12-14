class TodoModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isCompleted;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? type;
  final String? recurrenceType;

  TodoModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    this.type,
    this.recurrenceType,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      isPublic: json['isPublic'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      type: json['type'],
      recurrenceType: json['recurrenceType'],
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
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'type': type,
      'recurrenceType': recurrenceType,
    };
  }

  TodoModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    bool? isCompleted,
    bool? isPublic,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? type,
    String? recurrenceType,
  }) {
    return TodoModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
      recurrenceType: recurrenceType ?? this.recurrenceType,
    );
  }
}
