
import 'dart:async';

import '../entities/article_entity.dart';


abstract class ArticleRepository {
  Future<List<ArticleEntity>> getArticles({String? sort});
  // 2. Hàm lấy chi tiết bài báo (Cho ArticlePage)
  Future<ArticleEntity> getArticleDetail(String slug);
// 3. Hàm gửi bài báo mới lên Server
  Future<void> createArticle(ArticleEntity article);

  // 3. Hàm tìm kiếm
  Future<List<ArticleEntity>> searchArticles(String query);

}


