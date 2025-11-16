// lib/features/article/domain/entities/author_entity.dart

class AuthorEntity {
  final int id;
  final String displayName;

  const AuthorEntity({
    required this.id,
    required this.displayName,
  });
}