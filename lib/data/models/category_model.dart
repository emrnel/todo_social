class CategoryModel {
  final int id;
  final String name;
  final String? icon;
  final String? color;
  final String? description;

  CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.color,
    this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      color: json['color'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'description': description,
    };
  }
}
