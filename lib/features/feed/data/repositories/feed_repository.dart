import 'package:dio/dio.dart';
import '../models/feed_item_model.dart';

class FeedRepository {
  final Dio _dio;

  FeedRepository(this._dio);

  Future<List<FeedItemModel>> getFeed() async {
    try {
      final response = await _dio.get('/social/feed');
      final List<dynamic> feedList = response.data['data']['feed'];
      return feedList.map((json) => FeedItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception('Feed getirme hatası: ${e.message}');
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
}
