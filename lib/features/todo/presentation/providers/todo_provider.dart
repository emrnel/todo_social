import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_service.dart';
import '../../data/repositories/todo_repository.dart';
import '../../data/models/todo_model.dart';

// 1. Define the State class
class TodoState {
  final List<TodoModel> todos;
  final bool isLoading;

  TodoState({this.todos = const [], this.isLoading = false});

  TodoState copyWith({
    List<TodoModel>? todos,
    bool? isLoading,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 2. Define the Notifier
class TodoNotifier extends StateNotifier<TodoState> {
  final TodoRepository _repository;

  TodoNotifier(this._repository) : super(TodoState());

  Future<void> fetchMyTodos() async {
    state = state.copyWith(isLoading: true);
    try {
      final todos = await _repository.getMyTodos();
      state = state.copyWith(todos: todos, isLoading: false);
    } catch (e) {
      // TODO: Handle error state in UI
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> createTodo(String title, {String? description}) async {
    state = state.copyWith(isLoading: true);
    try {
      final newTodo = await _repository.addTodo(title, description: description);
      state = state.copyWith(
        todos: [newTodo, ...state.todos],
        isLoading: false,
      );
    } catch (e) {
      // TODO: Handle error state in UI
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> toggleTodo(int todoId) async {
    final originalTodos = state.todos;

    // Optimistically update the UI
    state = state.copyWith(
      todos: originalTodos.map((todo) {
        if (todo.id == todoId) {
          return todo.copyWith(isCompleted: !todo.isCompleted);
        }
        return todo;
      }).toList(),
    );

    try {
      final todoToToggle = originalTodos.firstWhere((t) => t.id == todoId);
      final newStatus = !todoToToggle.isCompleted;
      // Make the API call
      await _repository.updateTodoStatus(todoId, newStatus);
    } catch (e) {
      // If the API call fails, revert to the original state
      state = state.copyWith(todos: originalTodos);
      // TODO: Show an error message to the user
    }
  }

  Future<void> removeTodo(int todoId) async {
    final originalTodos = state.todos;

    // Optimistically update the UI
    state = state.copyWith(
      todos: originalTodos.where((todo) => todo.id != todoId).toList(),
    );

    try {
      // Make the API call
      await _repository.deleteTodo(todoId);
    } catch (e) {
      // If the API call fails, revert to the original state
      state = state.copyWith(todos: originalTodos);
      // TODO: Show an error message to the user
    }
  }
}

// 3. Define the Repository Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return TodoRepository(dio);
});

// 4. Define the StateNotifierProvider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoNotifier(repository);
});
