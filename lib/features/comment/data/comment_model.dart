class Comment {
  final int id;
  final String content;
  final String authorName;
  final String createdAt;

  Comment({
    required this.id,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["id"],
      content: json["content"],
      authorName: json["user"]["displayName"] ?? "Ẩn danh",
      createdAt: json["createdAt"],
    );
  }
}
