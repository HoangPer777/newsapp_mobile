// // lib/features/article/data/repositories/article_repository_impl.dart
//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../domain/entities/article_entity.dart';
// import '../../domain/repositories/article_repository.dart';
// import '../datasources/article_remote_data_source.dart';
//
// class ArticleRepositoryImpl implements ArticleRepository {
//   final ArticleRemoteDataSource remoteDataSource;
//
//   ArticleRepositoryImpl({required this.remoteDataSource});
//
//   @override
//   Future<ArticleEntity> getArticleDetail(String slug) async {
//     final articleModel = await remoteDataSource.fetchArticleBySlug(slug);
//     // Ánh xạ sang Domain Entity
//     return articleModel.toEntity();
//   }
//
//   @override
//   Future<List<ArticleEntity>> getArticles() {
//     // TODO: implement getArticles
//     throw UnimplementedError();
//   }
//
// }
//
// // Provider
// final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
//   final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
//   return ArticleRepositoryImpl(remoteDataSource: remoteDataSource);
// });


import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Import các file cần thiết
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  // --- 1. TRIỂN KHAI HÀM LẤY DANH SÁCH (Đã sửa) ---
  @override
  Future<List<ArticleEntity>> getArticles() async {
    // Gọi Data Source để lấy List<ArticleModel>
    final models = await remoteDataSource.getArticles();

    // Chuyển đổi (Map) từng Model sang Entity
    return models.map((model) => model.toEntity()).toList();
  }

  // --- 2. TRIỂN KHAI HÀM LẤY CHI TIẾT (Giữ nguyên) ---
  @override
  Future<ArticleEntity> getArticleDetail(String slug) async {
    final articleModel = await remoteDataSource.fetchArticleBySlug(slug);
    // Ánh xạ sang Domain Entity
    return articleModel.toEntity();
  }
}

// --- PROVIDER THỦ CÔNG (Giữ nguyên) ---
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  // Lấy datasource từ provider thủ công
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  return ArticleRepositoryImpl(remoteDataSource: remoteDataSource);
});