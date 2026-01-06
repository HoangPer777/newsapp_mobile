import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/article_entity.dart';
import '../repositories/article_repository.dart';
import '../../data/repositories/article_repository_impl.dart';

class CreateArticleUseCase {
  final ArticleRepository repository;

  CreateArticleUseCase(this.repository);

  // Khác với GetDetail (cần slug), Create cần nguyên một đối tượng ArticleEntity
  Future<void> call(ArticleEntity article) {
    return repository.createArticle(article);
  }
}

// Provider dành riêng cho việc Tạo bài báo
final createArticleUseCaseProvider = Provider<CreateArticleUseCase>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return CreateArticleUseCase(repository);
});