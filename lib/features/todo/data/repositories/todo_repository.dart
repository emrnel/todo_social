import 'package:dio/dio.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/data/models/routine_model.dart';

class TodoRepository {
  final Dio _dio;

  TodoRepository(this._dio);

  /// Get todos and routines - Backend returns both arrays
  Future<Map<String, dynamic>> getMyTodos() async {
    try {
      final response = await _dio.get('/todos/mytodos');
      final data = response.data['data'];

      // Backend returns separate todos and routines arrays
      return {
        'todos': data['todos'] ?? [],
        'routines': data['routines'] ?? [],
      };
    } on DioException catch (e) {
      throw Exception('Görevleri getirme hatası: ${e.message}');
    }
  }

  /// Legacy method name for backward compatibility
  Future<Map<String, dynamic>> getMyTodosAndRoutines() async {
    return getMyTodos();
  }

  Future<TodoModel> addTodo(String title,
      {String? description, bool isPublic = false}) async {
    try {
      final response = await _dio.post(
        '/todos',
        data: {
          'title': title,
          'description': description,
          'isPublic': isPublic,
        },
      );
      return TodoModel.fromJson(response.data['data']['todo']);
    } on DioException catch (e) {
      throw Exception('Görev ekleme hatası: ${e.message}');
    }
  }

  Future<TodoModel> updateTodo(int todoId,
      {bool? isCompleted,
      String? title,
      String? description,
      bool? isPublic}) async {
    try {
      final Map<String, dynamic> data = {};
      if (isCompleted != null) data['isCompleted'] = isCompleted;
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (isPublic != null) data['isPublic'] = isPublic;

      final response = await _dio.patch(
        '/todos/$todoId',
        data: data,
      );
      return TodoModel.fromJson(response.data['data']['todo']);
    } on DioException catch (e) {
      throw Exception('Görev güncelleme hatası: ${e.message}');
    }
  }

  /// Legacy method name for backward compatibility
  Future<TodoModel> updateTodoStatus(int todoId, bool isCompleted) async {
    return updateTodo(todoId, isCompleted: isCompleted);
  }

  Future<void> deleteTodo(int todoId) async {
    try {
      await _dio.delete('/todos/$todoId');
    } on DioException catch (e) {
      throw Exception('Görev silme hatası: ${e.message}');
    }
  }
}
