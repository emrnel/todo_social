import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/core/api/api_service.dart';
import 'package:todo_social/data/repositories/notification_repository.dart';
import 'package:todo_social/data/models/notification_model.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationRepository(dio);
});

class NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;

  NotificationState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
  });

  NotificationState copyWith({
    List<NotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;

  NotificationNotifier(this._repository) : super(NotificationState()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.getMyNotifications();
      state = state.copyWith(
        notifications: result['notifications'] as List<NotificationModel>,
        unreadCount: result['unreadCount'] as int,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _repository.markAsRead(notificationId);
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          if (n.id == notificationId) {
            return NotificationModel(
              id: n.id,
              userId: n.userId,
              actorId: n.actorId,
              type: n.type,
              todoId: n.todoId,
              commentId: n.commentId,
              badgeId: n.badgeId,
              message: n.message,
              isRead: true,
              createdAt: n.createdAt,
              actor: n.actor,
              todo: n.todo,
              badge: n.badge,
            );
          }
          return n;
        }).toList(),
        unreadCount: state.unreadCount > 0 ? state.unreadCount - 1 : 0,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();
      state = state.copyWith(
        notifications: state.notifications.map((n) {
          return NotificationModel(
            id: n.id,
            userId: n.userId,
            actorId: n.actorId,
            type: n.type,
            todoId: n.todoId,
            commentId: n.commentId,
            badgeId: n.badgeId,
            message: n.message,
            isRead: true,
            createdAt: n.createdAt,
            actor: n.actor,
            todo: n.todo,
            badge: n.badge,
          );
        }).toList(),
        unreadCount: 0,
      );
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _repository.deleteNotification(notificationId);
      final notification = state.notifications.firstWhere((n) => n.id == notificationId);
      state = state.copyWith(
        notifications: state.notifications.where((n) => n.id != notificationId).toList(),
        unreadCount: !notification.isRead && state.unreadCount > 0
            ? state.unreadCount - 1
            : state.unreadCount,
      );
    } catch (e) {
      // Handle error
    }
  }
}

final notificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository);
});
