
import 'dart:async';

import '../entities/article_entity.dart';

abstract class ArticleRepository {
  // 1. Hàm lấy danh sách bài báo (Cho HomePage)
  Future<List<ArticleEntity>> getArticles();
  // 2. Hàm lấy chi tiết bài báo (Cho ArticlePage)
  Future<ArticleEntity> getArticleDetail(String slug);

}


