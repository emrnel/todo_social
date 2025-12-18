import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/data/models/todo_model.dart';
import 'package:todo_social/data/models/routine_model.dart';
import 'package:todo_social/features/todo/data/repositories/todo_repository.dart';
import 'package:todo_social/core/api/api_service.dart';

final todoRepositoryProvider = Provider((ref) {
  final dio = ref.watch(apiServiceProvider);
  return TodoRepository(dio);
});

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

class TodoProvider extends StateNotifier<TodoState> {
  final TodoRepository _repository;

  TodoProvider(this._repository) : super(TodoState());

  Future<void> fetchMyTodos() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final data = await _repository.getMyTodos();

      print('DEBUG: Backend response: $data');

      // Parse todos and routines from backend response
      final todos = (data['todos'] as List<dynamic>? ?? []).map((json) {
        print('DEBUG: Parsing todo: $json');
        return TodoModel.fromJson(json);
      }).toList();

      final routines = (data['routines'] as List<dynamic>? ?? []).map((json) {
        print('DEBUG: Parsing routine: $json');
        return RoutineModel.fromJson(json);
      }).toList();

      print(
          'DEBUG: Parsed ${todos.length} todos and ${routines.length} routines');

      state = state.copyWith(
        todos: todos,
        routines: routines,
        isLoading: false,
      );
    } catch (e, stackTrace) {
      print('DEBUG: Error fetching todos: $e');
      print('DEBUG: Stack trace: $stackTrace');
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createTodo(
    String title, {
    String? description,
    bool isPublic = false,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newTodo = await _repository.addTodo(
        title,
        description: description,
        isPublic: isPublic,
      );
      state = state.copyWith(
        todos: [newTodo, ...state.todos],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> addTodo(
    String title, {
    String? description,
    bool isPublic = false,
  }) async {
    return createTodo(title, description: description, isPublic: isPublic);
  }

  Future<void> toggleTodo(int todoId, bool isCompleted) async {
    final originalTodos = state.todos;

    // Optimistic update
    final updatedTodos = state.todos.map((todo) {
      if (todo.id == todoId) {
        return TodoModel(
          id: todo.id,
          userId: todo.userId,
          title: todo.title,
          description: todo.description,
          isCompleted: isCompleted,
          isPublic: todo.isPublic,
          createdAt: todo.createdAt,
          updatedAt: todo.updatedAt,
        );
      }
      return todo;
    }).toList();

    state = state.copyWith(todos: updatedTodos);

    try {
      await _repository.updateTodo(todoId, isCompleted: isCompleted);
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        todos: originalTodos,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> removeTodo(int todoId) async {
    final originalTodos = state.todos;

    // Optimistically remove
    state = state.copyWith(
      todos: originalTodos.where((todo) => todo.id != todoId).toList(),
    );

    try {
      await _repository.deleteTodo(todoId);
    } catch (e) {
      // Revert on error
      state = state.copyWith(
        todos: originalTodos,
        errorMessage: e.toString(),
      );
    }
  }
}

final todoProvider = StateNotifierProvider<TodoProvider, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoProvider(repository);
});
