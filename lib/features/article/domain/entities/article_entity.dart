import 'package:flutter/material.dart';

@immutable
class ArticleEntity {
  final int id;
  final String title;
  final String content;
  final DateTime publishedAt;
  final String category;
  final String authorName;
  final String? imageUrl;

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.category,
    required this.authorName,
    this.imageUrl,
  });

}