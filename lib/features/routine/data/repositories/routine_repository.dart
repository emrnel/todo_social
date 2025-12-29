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
    } on DioException catch (e) {
      throw Exception('Rutinleri getirme hatası: ${e.message}');
    }
  }

  Future<RoutineModel> addRoutine(
    String title, {
    String? description,
    bool isPublic = false,
    required String recurrenceType,
    dynamic recurrenceValue,
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
    } on DioException catch (e) {
      throw Exception('Rutin ekleme hatası: ${e.message}');
    }
  }

  Future<RoutineModel> updateRoutine(
    int routineId, {
    String? title,
    String? description,
    bool? isPublic,
    String? recurrenceType,
    dynamic recurrenceValue,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (description != null) data['description'] = description;
      if (isPublic != null) data['isPublic'] = isPublic;
      if (recurrenceType != null) data['recurrenceType'] = recurrenceType;
      if (recurrenceValue != null) data['recurrenceValue'] = recurrenceValue;

      final response = await _dio.patch('/routines/$routineId', data: data);
      return RoutineModel.fromJson(response.data['data']['routine']);
    } on DioException catch (e) {
      throw Exception('Rutin güncelleme hatası: ${e.message}');
    }
  }

  Future<void> deleteRoutine(int routineId) async {
    try {
      await _dio.delete('/routines/$routineId');
    } on DioException catch (e) {
      throw Exception('Rutin silme hatası: ${e.message}');
    }
  }

  Future<RoutineModel> completeRoutine(int routineId) async {
    try {
      final response = await _dio.post('/routines/$routineId/complete');
      return RoutineModel.fromJson(response.data['data']['routine']);
    } on DioException catch (e) {
      throw Exception('Rutin tamamlama hatası: ${e.message}');
    }
  }

  Future<RoutineModel> copyRoutine(int routineId) async {
    try {
      final response = await _dio.post('/routines/$routineId/copy');
      return RoutineModel.fromJson(response.data['data']['routine']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final message = e.response?.data['message'] ?? 'Bu rutini zaten kopyaladınız';
        throw Exception(message);
      }
      if (e.response?.data != null && e.response!.data['message'] != null) {
        throw Exception(e.response!.data['message']);
      }
      throw Exception('Kopyalama hatası: ${e.message}');
    }
  }
}
