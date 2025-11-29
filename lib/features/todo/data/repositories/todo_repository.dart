import 'package:dio/dio.dart';

import '../models/todo_model.dart';

class TodoRepository {
  final Dio _dio;

  TodoRepository(this._dio);

  Future<List<TodoModel>> getMyTodos() async {
    try {
      final response = await _dio.get('/todos/mytodos');
      final List<dynamic> todoList = response.data['data']['todos'];
      return todoList.map((json) => TodoModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error fetching todos: $e');
      rethrow;
    }
  }

  Future<TodoModel> addTodo(String title, {String? description}) async {
    try {
      final response = await _dio.post(
        '/todos',
        data: {
          'title': title,
          'description': description,
          'isPublic': false, // Defaulting to false as per contract
        },
      );
      return TodoModel.fromJson(response.data['data']['todo']);
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error adding todo: $e');
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
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error updating todo status: $e');
      rethrow;
    }
  }

  Future<void> deleteTodo(int todoId) async {
    try {
      await _dio.delete('/todos/$todoId');
    } on DioException catch (e) {
      // TODO: Proper error handling
      print('Error deleting todo: $e');
      rethrow;
    }
  }
}
