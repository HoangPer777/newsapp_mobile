class ArticleNotification {
  final int articleId; // Thêm trường này
  final String title;
  final String message;
  final DateTime createdAt;

  ArticleNotification({
    required this.articleId,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory ArticleNotification.fromJson(Map<String, dynamic> json) {
    return ArticleNotification(
      // Giả sử API trả về trường 'id' hoặc 'articleId'
      articleId: json['id'] ?? 0,
      title: json['category'] ?? 'Thông báo',
      message: json['title'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}