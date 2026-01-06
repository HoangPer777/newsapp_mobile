// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleModel _$ArticleModelFromJson(Map<String, dynamic> json) => ArticleModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      slug: json['slug'] as String?,
      content: json['content'] as String?,
      category: json['category'] as String?,
      publishedAt: json['publishedAt'] == null
          ? null
          : DateTime.parse(json['publishedAt'] as String),
      author: json['author'] == null
          ? null
          : AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      image: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ArticleModelToJson(ArticleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'content': instance.content,
      'category': instance.category,
      'publishedAt': instance.publishedAt?.toIso8601String(),
      'author': instance.author?.toJson(),
      'imageUrl': instance.image,
    };
