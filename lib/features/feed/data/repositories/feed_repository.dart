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
}
