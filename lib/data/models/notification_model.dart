class NotificationModel {
  final int id;
  final int userId;
  final int? actorId;
  final String type;
  final int? todoId;
  final int? commentId;
  final int? badgeId;
  final String? message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? actor;
  final Map<String, dynamic>? todo;
  final Map<String, dynamic>? badge;

  NotificationModel({
    required this.id,
    required this.userId,
    this.actorId,
    required this.type,
    this.todoId,
    this.commentId,
    this.badgeId,
    this.message,
    required this.isRead,
    required this.createdAt,
    this.actor,
    this.todo,
    this.badge,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      actorId: json['actorId'],
      type: json['type'],
      todoId: json['todoId'],
      commentId: json['commentId'],
      badgeId: json['badgeId'],
      message: json['message'],
      isRead: json['isRead'] == true || json['isRead'] == 1,
      createdAt: DateTime.parse(json['createdAt']),
      actor: json['actor'],
      todo: json['todo'],
      badge: json['badge'],
    );
  }

  String getNotificationText() {
    if (actor != null && actor!['username'] != null) {
      return '${actor!['username']} $message';
    }
    return message ?? 'Yeni bildirim';
  }

  String getNotificationIcon() {
    switch (type) {
      case 'like':
        return '❤️';
      case 'comment':
        return '💬';
      case 'follow':
        return '👥';
      case 'badge_earned':
        return '🏆';
      case 'todo_copied':
        return '📋';
      default:
        return '🔔';
    }
  }
}
