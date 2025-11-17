// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArticleModel _$ArticleModelFromJson(Map<String, dynamic> json) => ArticleModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      slug: json['slug'] as String,
      contentPlain: json['contentPlain'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      author: AuthorModel.fromJson(json['author'] as Map<String, dynamic>),
      image: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ArticleModelToJson(ArticleModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'slug': instance.slug,
      'contentPlain': instance.contentPlain,
      'publishedAt': instance.publishedAt.toIso8601String(),
      'author': instance.author,
      'imageUrl': instance.image,
    };
