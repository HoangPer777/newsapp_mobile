// lib/features/article/data/repositories/article_repository_impl.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';

// (⚠️ XÓA (DELETE) cái 'import' ... 'article_pagination.dart' tào lao đi)

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ArticleEntity> getArticleDetail(String slug) async {
    final articleModel = await remoteDataSource.fetchArticleBySlug(slug);
    // Ánh xạ sang Domain Entity
    return articleModel.toEntity();
  }

}

// Provider (Giữ nguyên)
final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  return ArticleRepositoryImpl(remoteDataSource: remoteDataSource);
});