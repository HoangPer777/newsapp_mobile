// lib/features/article/presentation/notifier/article_detail_state.dart

import '../../domain/entities/article_entity.dart';

abstract class ArticleDetailState {
  const ArticleDetailState();
}

class ArticleDetailInitial extends ArticleDetailState {}

class ArticleDetailLoading extends ArticleDetailState {}

class ArticleDetailLoaded extends ArticleDetailState {
  final ArticleEntity article;

  const ArticleDetailLoaded({required this.article});
}

class ArticleDetailError extends ArticleDetailState {
  final String message;

  const ArticleDetailError({required this.message});
}