import 'package:dio/dio.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/data/models/routine_model.dart';

class TodoRepository {
  final Dio _dio;

  TodoRepository(this._dio);

  Future<Map<String, dynamic>> getMyTodos() async {
    try {
      final response = await _dio.get('/todos/mytodos');
      final data = response.data['data'];

      return {
        'todos': data['todos'] ?? [],
        'routines': data['routines'] ?? [],
      };
    } on DioException catch (e) {
      throw Exception('Görevleri getirme hatası: ${e.message}');
    }
  }

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

  Future<Map<String, dynamic>> likeTodo(int todoId) async {
    try {
      final response = await _dio.post('/todos/$todoId/like');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception('Beğeni hatası: ${e.message}');
    }
  }

  Future<Map<String, dynamic>> unlikeTodo(int todoId) async {
    try {
      final response = await _dio.delete('/todos/$todoId/like');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception('Beğeni kaldırma hatası: ${e.message}');
    }
  }

  Future<TodoModel> copyTodo(int todoId) async {
    try {
      final response = await _dio.post('/todos/$todoId/copy');
      return TodoModel.fromJson(response.data['data']['todo']);
    } on DioException catch (e) {
      throw Exception('Kopyalama hatası: ${e.message}');
    }
  }
}
