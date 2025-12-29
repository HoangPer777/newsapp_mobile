import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/di/providers.dart';
import '../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles();
  Future<ArticleModel> fetchArticleBySlug(String slug);

  Future<void> createArticle(Map<String, dynamic> articleData);
}


class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio dio;
// Khởi tạo storage để đọc Token
  final _storage = const FlutterSecureStorage();

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

  // HÀM THÊM BÀI BÁO (ADMIN)
  @override
  Future<void> createArticle(Map<String, dynamic> articleData) async {
    try {
      // 1. Lấy token từ bộ nhớ bảo mật
      String? token = await _storage.read(key: 'access_token');

      // 2. Gửi request POST kèm Header Authorization
      await dio.post(
        '/api/articles',
        data: articleData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token', // Bắt buộc phải có để Spring Security xác thực
          },
        ),
      );
    } catch (e) {
      throw Exception('Lỗi khi đăng bài báo: $e');
    }
  }
}

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio: dio);
});