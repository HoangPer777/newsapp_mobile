import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/author_entity.dart';
part 'author_model.g.dart';

@JsonSerializable()
class AuthorModel {
  final int id;

  final String displayName;

  final String? email;

  @JsonKey(name: 'passwordHash')
  final String? passwordHash;

  @JsonKey(name: 'createdAt')
  final DateTime? createdAt;

  AuthorModel({
    required this.id,
    required this.displayName,
    this.email,
    this.passwordHash,
    this.createdAt
  });

  factory AuthorModel.fromJson(Map<String, dynamic> json) => _$AuthorModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorModelToJson(this);

  AuthorEntity toEntity() {
    // Chỉ truyền các trường cần thiết vào Entity
    return AuthorEntity(id: id, displayName: displayName);

  }
}