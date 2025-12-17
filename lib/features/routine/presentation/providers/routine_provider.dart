import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_social/data/models/routine_model.dart';
import 'package:todo_social/features/routine/data/repositories/routine_repository.dart';
import 'package:todo_social/core/api/api_service.dart';

final routineRepositoryProvider = Provider((ref) {
  final dio = ref.watch(apiServiceProvider);
  return RoutineRepository(dio);
});

class RoutineState {
  final List<RoutineModel> routines;
  final bool isLoading;
  final String? errorMessage;

  RoutineState({
    this.routines = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RoutineState copyWith({
    List<RoutineModel>? routines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RoutineState(
      routines: routines ?? this.routines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class RoutineProvider extends StateNotifier<RoutineState> {
  final RoutineRepository _repository;

  RoutineProvider(this._repository) : super(RoutineState());

  Future<void> fetchMyRoutines() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final routines = await _repository.getMyRoutines();
      state = state.copyWith(routines: routines, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> createRoutine(
    String title, {
    String? description,
    bool isPublic = false,
    required String recurrenceType,
    String? recurrenceValue,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final newRoutine = await _repository.addRoutine(
        title,
        description: description,
        isPublic: isPublic,
        recurrenceType: recurrenceType,
        recurrenceValue: recurrenceValue,
      );
      state = state.copyWith(
        routines: [...state.routines, newRoutine],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> removeRoutine(int routineId) async {
    try {
      await _repository.deleteRoutine(routineId);
      final updatedList =
          state.routines.where((r) => r.id != routineId).toList();
      state = state.copyWith(routines: updatedList);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final routineProvider =
    StateNotifierProvider<RoutineProvider, RoutineState>((ref) {
  final repository = ref.watch(routineRepositoryProvider);
  return RoutineProvider(repository);
});
