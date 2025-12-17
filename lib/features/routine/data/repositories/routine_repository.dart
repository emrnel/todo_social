import 'package:dio/dio.dart';
import 'package:todo_social/data/models/routine_model.dart';

class RoutineRepository {
  final Dio _dio;

  RoutineRepository(this._dio);

  Future<List<RoutineModel>> getMyRoutines() async {
    try {
      final response = await _dio.get('/routines/myroutines');
      final List<dynamic> routineList = response.data['data']['routines'] ?? [];
      return routineList.map((json) => RoutineModel.fromJson(json)).toList();
    } on DioException catch (_) {
      rethrow;
    }
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
