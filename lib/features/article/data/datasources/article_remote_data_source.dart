import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles();
  Future<ArticleModel> fetchArticleBySlug(String slug);
  Future<List<ArticleModel>> searchArticles(String query); // [NEW]
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio dio;

  ArticleRemoteDataSourceImpl({required this.dio});

  // HÀM LẤY DANH SÁCH
  @override
  Future<List<ArticleModel>> getArticles() async {
    try {
      final response = await dio.get('/api/articles');

      final List<dynamic> contentList = response.data;

      return contentList
          .map((item) => ArticleModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách: $e');
    }
  }

  @override
  Future<ArticleModel> fetchArticleBySlug(String slug) async {
    try {
      // Gọi đúng API chi tiết (ID/Slug)
      final response = await dio.get('/api/articles/$slug');
      return ArticleModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết: $e');
    }
  }

  // [NEW] Search API call
  @override
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      final response = await dio.get(
        '/api/articles/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> contentList = response.data;
      return contentList.map((item) => ArticleModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }
}

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio: dio);
});