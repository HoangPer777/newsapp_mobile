// lib/features/article/domain/repositories/article_repository.dart

import '../entities/article_entity.dart';

abstract class ArticleRepository {
  Future<ArticleEntity> getArticleDetail(String slug);
}


