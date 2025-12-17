import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/features/todo/data/repositories/todo_repository.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/data/models/routine_model.dart';
import 'package:todo_social/core/api/api_service.dart';

// 1. Define the State class
class TodoState {
  final List<TodoModel> todos;
  final List<RoutineModel> routines;
  final bool isLoading;
  final String? errorMessage;

  TodoState({
    this.todos = const [],
    this.routines = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  TodoState copyWith({
    List<TodoModel>? todos,
    List<RoutineModel>? routines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      routines: routines ?? this.routines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// 2. Define the Notifier
class TodoNotifier extends StateNotifier<TodoState> {
  final TodoRepository _repository;

  TodoNotifier(this._repository) : super(TodoState());

  Future<void> fetchMyTodos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.getMyTodosAndRoutines();
      state = state.copyWith(
        todos: result['todos'] as List<TodoModel>,
        routines: result['routines'] as List<RoutineModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createTodo(String title,
      {String? description, bool isPublic = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newTodo = await _repository.addTodo(title,
          description: description, isPublic: isPublic);
      state = state.copyWith(
        todos: [newTodo, ...state.todos],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> toggleTodo(int todoId, bool newStatus) async {
    final originalTodos = state.todos;

    // Optimistically update the UI
    state = state.copyWith(
      todos: originalTodos.map((todo) {
        if (todo.id == todoId) {
          return todo.copyWith(isCompleted: newStatus);
        }
        return todo;
      }).toList(),
    );

    try {
      // Make the API call
      await _repository.updateTodoStatus(todoId, newStatus);
    } catch (e) {
      // If the API call fails, revert to the original state
      state = state.copyWith(todos: originalTodos, errorMessage: e.toString());
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
      state = state.copyWith(todos: originalTodos, errorMessage: e.toString());
    }
  }
}

// 3. Define the Repository Provider
final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  final dio = ref.watch(apiServiceProvider);
  return TodoRepository(dio);
});

// 4. Define the StateNotifier Provider
final todoProvider = StateNotifierProvider<TodoNotifier, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoNotifier(repository);
});
