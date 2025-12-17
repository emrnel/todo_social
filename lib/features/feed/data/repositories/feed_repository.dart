import 'package:dio/dio.dart';
import '../models/feed_item_model.dart';

class FeedRepository {
  final Dio _dio;

  FeedRepository(this._dio);

  Future<List<FeedItemModel>> getFeed() async {
    try {
      final response = await _dio.get('/feed');
      final List<dynamic> feedList = response.data['data']['feed'];
      return feedList.map((json) => FeedItemModel.fromJson(json)).toList();
    } on DioException catch (_) {
      // TODO: Proper error handling
      // print('Error fetching feed: $e');
      rethrow;
    }
  }
}
