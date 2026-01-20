import '../repositories/article_repository.dart';
import '../entities/article_entity.dart';

class ArticleService {
  final ArticleRepository articleRepository;

  ArticleService({required this.articleRepository});

  Future<List<ArticleEntity>> getAllArticles() {
    return articleRepository.getArticles();
  }
}
