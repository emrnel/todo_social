import 'package:dio/dio.dart';
import 'package:todo_social/data/models/routine_model.dart';

class RoutineRepository {
  final Dio _dio;

  RoutineRepository(this._dio);

  // Note: Backend doesn't have a separate GET endpoint for routines
  // Routines are fetched together with todos via /todos/mytodos
  // This method is kept for future use if needed
  Future<List<RoutineModel>> getMyRoutines() async {
    // Return empty list since routines come from getMyTodos
    return [];
  }

  Future<RoutineModel> addRoutine(
    String title, {
    String? description,
    bool isPublic = false,
    required String recurrenceType,
    String? recurrenceValue,
  }) async {
    try {
      final response = await _dio.post(
        '/routines',
        data: {
          'title': title,
          'description': description,
          'isPublic': isPublic,
          'recurrenceType': recurrenceType,
          'recurrenceValue': recurrenceValue,
        },
      );
      return RoutineModel.fromJson(response.data['data']['routine']);
    } on DioException catch (_) {
      rethrow;
    }
  }

  Future<void> deleteRoutine(int routineId) async {
    try {
      await _dio.delete('/routines/$routineId');
    } on DioException catch (_) {
      rethrow;
    }
  }
}
