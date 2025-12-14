import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/get_article_detail_usecase.dart';
import 'article_detail_state.dart';

class ArticleDetailNotifier extends StateNotifier<ArticleDetailState> {
  final GetArticleDetailUseCase getArticleDetail;

  ArticleDetailNotifier({required this.getArticleDetail})
      : super(ArticleDetailInitial());

  Future<void> loadArticle(String slug) async {
    if (state is ArticleDetailLoading) return;

    try {
      state = ArticleDetailLoading();
      final article = await getArticleDetail(slug);
      state = ArticleDetailLoaded(article: article);
    } catch (e) {
      state = ArticleDetailError(message: e.toString());
    }
  }
}

// Provider
final articleDetailNotifierProvider = StateNotifierProvider.autoDispose<ArticleDetailNotifier, ArticleDetailState>((ref) {
  final useCase = ref.watch(getArticleDetailUseCaseProvider);
  return ArticleDetailNotifier(getArticleDetail: useCase);
});


