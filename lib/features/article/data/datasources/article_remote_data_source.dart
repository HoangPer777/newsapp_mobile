import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/di/providers.dart';
import '../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles();
  Future<ArticleModel> fetchArticleBySlug(String slug);
  Future<void> createArticle(Map<String, dynamic> articleData);
  Future<List<ArticleModel>> searchArticles(String query);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio dio;
  final _storage = const FlutterSecureStorage();

  ArticleRemoteDataSourceImpl({required this.dio});

  // HÀM LẤY DANH SÁCH
  @override
  Future<List<ArticleModel>> getArticles() async {
    try {
      final response = await dio.get('/api/articles');
      // Lưu ý: Cần đảm bảo API trả về List trực tiếp.
      // Nếu API trả về { data: [] } thì phải sửa thành response.data['data']
      final List<dynamic> contentList = response.data;

      return contentList
          .map((item) => ArticleModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách: $e');
    }
  }

  // HÀM LẤY CHI TIẾT
  @override
  Future<ArticleModel> fetchArticleBySlug(String slug) async {
    try {
      final response = await dio.get('/api/articles/$slug');
      return ArticleModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Lỗi lấy chi tiết: $e');
    }
  }

  // HÀM TÌM KIẾM
  @override
  Future<List<ArticleModel>> searchArticles(String query) async {
    try {
      final response = await dio.get(
        '/api/articles/search',
        queryParameters: {'q': query},
      );
      final List<dynamic> contentList = response.data;
      return contentList
          .map((item) => ArticleModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Lỗi tìm kiếm: $e');
    }
  }

  // HÀM THÊM BÀI BÁO
  @override
  Future<void> createArticle(Map<String, dynamic> articleData) async {
    try {
      // Lấy token thủ công
      String? token = await _storage.read(key: 'access_token');

      await dio.post(
        '/api/articles',
        data: articleData,
        options: Options(
          headers: {
            // Nếu token null thì để chuỗi rỗng hoặc xử lý lỗi
            'Authorization': 'Bearer ${token ?? ""}',
          },
        ),
      );
    } catch (e) {
      throw Exception('Lỗi khi đăng bài báo: $e');
    }
  }
}

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  // Lấy Dio đã được cấu hình từ core/di/providers.dart
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio: dio);
});