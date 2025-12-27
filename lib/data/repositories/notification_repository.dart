import 'package:dio/dio.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio;

  NotificationRepository(this._dio);

  Future<Map<String, dynamic>> getMyNotifications({int limit = 20, int offset = 0}) async {
    try {
      final response = await _dio.get(
        '/notifications',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return {
          'notifications': (data['notifications'] as List)
              .map((json) => NotificationModel.fromJson(json))
              .toList(),
          'unreadCount': data['unreadCount'] ?? 0,
        };
      }
      throw Exception('Failed to load notifications');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      await _dio.patch('/notifications/$notificationId/read');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _dio.patch('/notifications/read-all');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      await _dio.delete('/notifications/$notificationId');
    } catch (e) {
      rethrow;
    }
  }
}
