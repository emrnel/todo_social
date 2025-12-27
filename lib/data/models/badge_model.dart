class BadgeModel {
  final int id;
  final String name;
  final String description;
  final String? icon;
  final String condition;
  final int threshold;
  final String? tier;
  final DateTime? earnedAt;

  BadgeModel({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    required this.condition,
    required this.threshold,
    this.tier,
    this.earnedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    // Handle both badge data and user_badge data
    final badgeData = json['badge'] ?? json;

    return BadgeModel(
      id: badgeData['id'],
      name: badgeData['name'],
      description: badgeData['description'] ?? '',
      icon: badgeData['icon'],
      condition: badgeData['condition'] ?? '',
      threshold: badgeData['threshold'] ?? 0,
      tier: badgeData['tier'],
      earnedAt: json['earnedAt'] != null
          ? DateTime.parse(json['earnedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'condition': condition,
      'threshold': threshold,
      'tier': tier,
      'earnedAt': earnedAt?.toIso8601String(),
    };
  }
}
