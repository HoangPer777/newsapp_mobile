import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/usecases/create_article_use_case.dart';
import '../../../../core/di/providers.dart';

final addArticleProvider = AsyncNotifierProvider<AddArticleNotifier, void>(() {
  return AddArticleNotifier();
});

class AddArticleNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // Trạng thái ban đầu là rỗng
  }

  Future<void> createArticle(ArticleEntity article) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // Gọi UseCase đã được định nghĩa ở tầng Domain
      final useCase = ref.read(createArticleUseCaseProvider);
      return await useCase.call(article);
    });
  }
}