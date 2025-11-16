// lib/features/article/data/models/article_model.dart

import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article_entity.dart';
import 'author_model.dart';
part 'article_model.g.dart';

@JsonSerializable()
class ArticleModel {
  final int id;
  final String title;
  final String slug;

  // 🎯 Ánh xạ từ DB: content_plain -> contentPlain
  @JsonKey(name: 'contentPlain')
  final String contentPlain;

  // 🎯 Ánh xạ từ DB: published_at -> publishedAt
  @JsonKey(name: 'publishedAt')
  final DateTime publishedAt;

  final AuthorModel author;
  @JsonKey(name: 'imageUrl')
  final String? image; // Dùng String? (nullable) cho an toàn

  ArticleModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.contentPlain,
    required this.publishedAt,
    required this.author,
    this.image,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => _$ArticleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title,
      contentPlain: contentPlain,
      publishedAt: publishedAt,
      author: author.toEntity(),
      image: image ?? '',
    );
  }
}
// Chạy build_runner để tạo article_model.g.dart