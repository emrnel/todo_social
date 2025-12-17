import 'package:dio/dio.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/data/models/routine_model.dart';

class TodoRepository {
  final Dio _dio;

  TodoRepository(this._dio);

  // Backend returns both todos and routines in getMyTodos
  Future<Map<String, dynamic>> getMyTodosAndRoutines() async {
    try {
      final response = await _dio.get('/todos/mytodos');
      final data = response.data['data'];

      final List<dynamic> todoList = data['todos'] ?? [];
      final List<dynamic> routineList = data['routines'] ?? [];

      return {
        'todos': todoList.map((json) => TodoModel.fromJson(json)).toList(),
        'routines':
            routineList.map((json) => RoutineModel.fromJson(json)).toList(),
      };
    } on DioException catch (_) {
      rethrow;
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
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<TodoModel> updateTodoStatus(int todoId, bool isCompleted) async {
    try {
      final response = await _dio.patch(
        '/todos/$todoId',
        data: {'isCompleted': isCompleted},
      );
      return TodoModel.fromJson(response.data['data']['todo']);
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<void> deleteTodo(int todoId) async {
    try {
      await _dio.delete('/todos/$todoId');
    } on DioException catch (_) {
      rethrow;
    }
  }
}
