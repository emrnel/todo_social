import 'package:dio/dio.dart';

class CommentRepository {
  final Dio _dio;

  CommentRepository(this._dio);

  Future<List<Map<String, dynamic>>> getComments(int todoId) async {
    try {
      final response = await _dio.get('/comments/todo/$todoId');
      if (response.statusCode == 200) {
        final List<dynamic> comments = response.data as List;
        return comments.map((e) => e as Map<String, dynamic>).toList();
      }
      throw Exception('Failed to load comments');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createComment({
    required int todoId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '/comments',
        data: {
          'todoId': todoId,
          'text': text,
        },
      );
      if (response.statusCode == 201) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to create comment');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteComment(int commentId) async {
    try {
      final response = await _dio.delete('/comments/$commentId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete comment');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateComment({
    required int commentId,
    required String text,
  }) async {
    try {
      final response = await _dio.patch(
        '/comments/$commentId',
        data: {'text': text},
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Failed to update comment');
    } catch (e) {
      rethrow;
    }
  }
}
