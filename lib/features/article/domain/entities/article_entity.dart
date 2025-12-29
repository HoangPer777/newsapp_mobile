import 'package:flutter/material.dart';

@immutable
class ArticleEntity {
  final int? id;
  final String title;
  final String content;
  final DateTime? publishedAt;
  final String? category;
  final String? authorName;
  final String? imageUrl;

  const ArticleEntity({
    this.id,
    required this.title,
    required this.content,
    this.publishedAt,
    this.category,
    this.authorName,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'slug': title.toLowerCase().replaceAll(' ', '-'),
      'category': category,
      'authorName': authorName,
    };
  }

}