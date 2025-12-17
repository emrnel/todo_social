import 'package:dio/dio.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/data/models/routine_model.dart';

class TodoRepository {
  final Dio _dio;

  TodoRepository(this._dio);

  /// Get todos and routines - Backend returns unified tasks array
  Future<Map<String, dynamic>> getMyTodosAndRoutines() async {
    try {
      final response = await _dio.get('/todos/mytodos');
      final data = response.data['data'];

      // Backend now returns 'tasks' array with type field
      // but also includes separate todos/routines for compatibility
      final List<TodoModel> todos = [];
      final List<RoutineModel> routines = [];

      // Parse the unified tasks array if available
      if (data['tasks'] != null) {
        for (var taskJson in data['tasks']) {
          if (taskJson['type'] == 'todo') {
            todos.add(TodoModel.fromJson(taskJson));
          } else if (taskJson['type'] == 'routine') {
            routines.add(RoutineModel.fromJson(taskJson));
          }
        }
      } else {
        // Fallback to separate arrays (backward compatibility)
        final List<dynamic> todoList = data['todos'] ?? [];
        final List<dynamic> routineList = data['routines'] ?? [];

        for (var json in todoList) {
          todos.add(TodoModel.fromJson(json));
        }
        for (var json in routineList) {
          routines.add(RoutineModel.fromJson(json));
        }
      }

      return {
        'todos': todos,
        'routines': routines,
      };
    } on DioException catch (e) {
      throw Exception('Görevleri getirme hatası: ${e.message}');
    }
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

  Future<TodoModel> updateTodoStatus(int todoId, bool isCompleted) async {
    try {
      final response = await _dio.patch(
        '/todos/$todoId',
        data: {'isCompleted': isCompleted},
      );
      return TodoModel.fromJson(response.data['data']['todo']);
    } on DioException catch (e) {
      throw Exception('Görev güncelleme hatası: ${e.message}');
    }
  }

  Future<void> deleteTodo(int todoId) async {
    try {
      await _dio.delete('/todos/$todoId');
    } on DioException catch (e) {
      throw Exception('Görev silme hatası: ${e.message}');
    }
  }
}
