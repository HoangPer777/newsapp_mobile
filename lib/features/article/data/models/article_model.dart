import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/article_entity.dart';
import 'author_model.dart';
part 'article_model.g.dart';

@JsonSerializable()
class ArticleModel {
  final int id;
  final String? title;
  final String? slug;

  final String? content;

  @JsonKey(name: 'category')
  final String? category;

  @JsonKey(name: 'publishedAt')
  final DateTime? publishedAt;

  final AuthorModel? author;
  @JsonKey(name: 'imageUrl')
  final String? image;

  ArticleModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.content,
    required this.category,
    required this.publishedAt,
    required this.author,
    this.image,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) => _$ArticleModelFromJson(json);

  Map<String, dynamic> toJson() => _$ArticleModelToJson(this);

  ArticleEntity toEntity() {
    return ArticleEntity(
      id: id,
      title: title ?? 'Không có tiêu đề',
      content: content ?? '',
      publishedAt: publishedAt ?? DateTime.now(),
      category: category ?? '',
      authorName: author?.displayName ?? 'Unknown',
      imageUrl: image,
    );
  }
}
