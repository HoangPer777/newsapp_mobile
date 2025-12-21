import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../entities/article_entity.dart';
import '../repositories/article_repository.dart';
import '../../data/repositories/article_repository_impl.dart'; // Import provider

class GetArticleDetailUseCase {
  final ArticleRepository repository;

  GetArticleDetailUseCase(this.repository);

  Future<ArticleEntity> call(String slug) {
    return repository.getArticleDetail(slug);
  }
}

// Provider
final getArticleDetailUseCaseProvider = Provider<GetArticleDetailUseCase>((ref) {
  final repository = ref.watch(articleRepositoryProvider);
  return GetArticleDetailUseCase(repository);
});