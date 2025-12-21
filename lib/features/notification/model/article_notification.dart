class ArticleNotification {
  final String title;
  final String message;
  final DateTime createdAt;

  ArticleNotification({
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory ArticleNotification.fromJson(Map<String, dynamic> json) {
    return ArticleNotification(
      title: json['category'],
      message: json['title'], // hoặc json['summary']
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
