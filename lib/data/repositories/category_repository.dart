import 'package:dio/dio.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final Dio _dio;

  CategoryRepository(this._dio);

  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _dio.get('/categories');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      rethrow;
    }
  }
}
