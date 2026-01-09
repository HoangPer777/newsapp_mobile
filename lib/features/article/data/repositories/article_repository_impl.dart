import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Import các file cần thiết
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';


class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  //1. HÀM LẤY DANH SÁCH
  @override
  Future<List<ArticleEntity>> getArticles({String? sort}) async {
    // Gọi Data Source để lấy List<ArticleModel>
    final models = await remoteDataSource.getArticles(sort: sort);

    // Chuyển đổi (Map) từng Model sang Entity
    return models.map((model) => model.toEntity()).toList();
  }

  //2. HÀM LẤY CHI TIẾT
  @override
  Future<ArticleEntity> getArticleDetail(String slug) async {
    final articleModel = await remoteDataSource.fetchArticleBySlug(slug);
    // Ánh xạ sang Domain Entity
    return articleModel.toEntity();
  }

  @override
  Future<void> createArticle(ArticleEntity article) async {
    try {
      // Chuyển Entity sang Map (JSON) rồi đưa cho DataSource xử lý
      await remoteDataSource.createArticle(article.toJson());
    } catch (e) {
      rethrow;
    }
  }
  // @override
  // Future<void> createArticle(ArticleEntity article) async {
  //   // Chuyển Entity sang Model trước khi gửi cho DataSource
  //   final model = ArticleModel.fromEntity(article);
  //   await remoteDataSource.createArticle(model.toJson());
  // }
  //3. HÀM TÌM KIẾM
  @override
  Future<List<ArticleEntity>> searchArticles(String query) async {
    final models = await remoteDataSource.searchArticles(query);
    return models.map((model) => model.toEntity()).toList();
  }
}

// PROVIDER
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  // Lấy datasource từ provider
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  return ArticleRepositoryImpl(remoteDataSource: remoteDataSource);
});