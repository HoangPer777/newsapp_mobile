// lib/features/article/domain/entities/article_entity.dart

import 'author_entity.dart';

class ArticleEntity {
  final int id;
  final String title;
  final String contentPlain;
  final DateTime publishedAt;
  final AuthorEntity author;
  final String image;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.contentPlain,
    required this.publishedAt,
    required this.author,
    required this.image,
  });

}