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

      final todos = (data['todos'] as List<dynamic>? ?? [])
          .map((json) => TodoModel.fromJson(json))
          .toList();

      final routines = (data['routines'] as List<dynamic>? ?? [])
          .map((json) => RoutineModel.fromJson(json))
          .toList();

      state = state.copyWith(
        todos: todos,
        routines: routines,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createTodo(
    String title, {
    String? description,
    bool isPublic = false,
    int? categoryId,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newTodo = await _repository.addTodo(
        title,
        description: description,
        isPublic: isPublic,
        categoryId: categoryId,
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
        return todo.copyWith(isCompleted: isCompleted);
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

  Future<void> copyTodo(int todoId) async {
    try {
      final copiedTodo = await _repository.copyTodo(todoId);
      state = state.copyWith(
        todos: [copiedTodo, ...state.todos],
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> toggleLike(int todoId) async {
    final originalTodos = state.todos;

    // Try to find todo in current state, but don't crash if not found
    final currentTodo = state.todos.firstWhere(
      (todo) => todo.id == todoId,
      orElse: () => TodoModel(
        id: todoId,
        userId: 0,
        title: '',
        isCompleted: false,
        isPublic: false,
        likeCount: 0,
        isLiked: false,
        createdAt: DateTime.now(),
      ),
    );
    final isCurrentlyLiked = currentTodo.isLiked;

    // Optimistic update only if todo exists in state
    if (state.todos.any((todo) => todo.id == todoId)) {
      final updatedTodos = state.todos.map((todo) {
        if (todo.id == todoId) {
          return todo.copyWith(
            isLiked: !isCurrentlyLiked,
            likeCount:
                isCurrentlyLiked ? (todo.likeCount) - 1 : (todo.likeCount) + 1,
          );
        }
        return todo;
      }).toList();

      state = state.copyWith(todos: updatedTodos);
    }

    try {
      if (isCurrentlyLiked) {
        await _repository.unlikeTodo(todoId);
      } else {
        await _repository.likeTodo(todoId);
      }
    } catch (e) {
      // Revert on error only if we did an optimistic update
      if (state.todos.any((todo) => todo.id == todoId)) {
        state = state.copyWith(
          todos: originalTodos,
          errorMessage: e.toString(),
        );
      } else {
        state = state.copyWith(errorMessage: e.toString());
      }
      rethrow;
    }
  }
}

final todoProvider = StateNotifierProvider<TodoProvider, TodoState>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return TodoProvider(repository);
});
