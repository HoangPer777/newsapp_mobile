// lib/features/article/data/datasources/article_remote_data_source.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../models/article_model.dart';
import '../../../../core/api/dio_client.dart';

abstract class ArticleRemoteDataSource {
  Future<ArticleModel> fetchArticleBySlug(String slug);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio dio;

  ArticleRemoteDataSourceImpl({required this.dio});

  @override
  Future<ArticleModel> fetchArticleBySlug(String slug) async {
  try {
    // Gọi API thực tế
    // Thay thế '/articles/$slug'
    final response = await dio.get('/articles/13'); // Gọi danh sách thay vì chi tiết
    // final response = await dio.get('/articles/$slug');

    if (response.statusCode == 200 && response.data != null) {
      return ArticleModel.fromJson(response.data as Map<String, dynamic>);
    }
    // Xử lý các trường hợp lỗi khác
    throw Exception('Lỗi API ${response.statusCode}');

  } on DioException catch (e) {
    // Xử lý lỗi kết nối, 404, timeout
    throw Exception('Lỗi kết nối hoặc API: ${e.message}');
  }
  // Dữ liệu Mock nếu API không có:

  // await Future.delayed(const Duration(seconds: 1));
  // final mockJson = {
  //   "id": 1, "title": "Bài viết Flutter bằng Riverpod", "content_plain": "Nội dung chi tiết được tải từ API...",
  //   "published_at": "2025-11-16T08:00:00.000Z",
  //   "author": {"id": 10, "display_name": "Dev Riverpod"}
  // };
  // return ArticleModel.fromJson(mockJson);
//   @override
//   Future<ArticleModel> fetchArticleBySlug(String slug) async {
//     try {
// // Tạm thời chỉ dùng Mock để loại trừ lỗi mạng
//       await Future.delayed(const Duration(seconds: 1));
//       final mockJson = {
//         "id": 1,
//         "title": "Bài viết Mock Data Thành Công",
//         "content_plain": "Nội dung này được tải sau 1 giây (đã loại trừ lỗi mạng).",
//         "published_at": "2020-01-01T00:00:00.000Z",
//         // Đảm bảo định dạng chuẩn ISO 8601
//         "author": {"id": 10, "display_name": "Dev Riverpod"}
//       };
//
//       // Nếu lỗi xảy ra ở đây, nó sẽ bị catch
//       return ArticleModel.fromJson(mockJson);
//     } catch (e, stack) {
//       // 🎯 Dùng print hoặc log để xem lỗi Mapping chính xác là gì!
//       print("MAPPING ERROR: $e");
//       print("STACK: $stack");
//       // Ném lỗi lên để Notifier xử lý và chuyển sang trạng thái Error
//       throw Exception("Lỗi xử lý dữ liệu (Mapping): $e");
//     }
  }
}

// Provider
final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio: dio);
});

