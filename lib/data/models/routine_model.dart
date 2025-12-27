class RoutineModel {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final bool isPublic;
  final String recurrenceType; // 'daily', 'weekly', 'custom'
  final String? recurrenceValue; // Örn: "[\"mon\",\"wed\"]"
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isCompletedToday;

  RoutineModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isPublic,
    required this.recurrenceType,
    this.recurrenceValue,
    this.createdAt,
    this.updatedAt,
    this.isCompletedToday = false,
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    return RoutineModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['userId'] is int
          ? json['userId']
          : int.parse(json['userId'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      isPublic: json['isPublic'] == true || json['isPublic'] == 1,
      recurrenceType: json['recurrenceType'] ?? 'daily',
      recurrenceValue: json['recurrenceValue'],
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      isCompletedToday: json['isCompletedToday'] == true || json['isCompletedToday'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'isPublic': isPublic,
      'recurrenceType': recurrenceType,
      'recurrenceValue': recurrenceValue,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isCompletedToday': isCompletedToday,
    };
  }
}
