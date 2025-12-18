class PublicTodoModel {
  final int id;
  final String title;
  final String? description;
  final bool isCompleted;
  final DateTime createdAt;

  PublicTodoModel({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
  });

  factory PublicTodoModel.fromJson(Map<String, dynamic> json) {
    return PublicTodoModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      description: json['description'],
      isCompleted: json['isCompleted'] == true || json['isCompleted'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
