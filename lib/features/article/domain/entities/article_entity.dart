// // lib/features/article/domain/entities/article_entity.dart
//
// import 'author_entity.dart';
//
// class ArticleEntity {
//   final int id;
//   final String title;
//   final String contentPlain;
//   final DateTime publishedAt;
//   final AuthorEntity author;
//   final String image;
//
//   const ArticleEntity({
//     required this.id,
//     required this.title,
//     required this.contentPlain,
//     required this.publishedAt,
//     required this.author,
//     required this.image,
//   });
//
// }

import 'package:flutter/material.dart';
// import 'author_entity.dart'; // KHÔNG CẦN AuthorEntity nữa

@immutable // Đảm bảo Entity không thay đổi (tính bất biến)
class ArticleEntity {
  final int id;
  final String title;
  final String content; // Dùng 'content' thay cho 'contentPlain' (nghiệp vụ)
  final DateTime publishedAt;
  final String category;
  final String authorName; // Dùng tên tác giả (String) thay vì cả object
  final String? imageUrl; // Dùng 'imageUrl' và cho phép null

  const ArticleEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.publishedAt,
    required this.category,
    required this.authorName,
    this.imageUrl, // Không bắt buộc
  });


// Có thể thêm hàm copyWith nếu cần
}