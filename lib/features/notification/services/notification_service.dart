import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/article_notification.dart';

class NotificationService {
  static const String baseUrl =
      'http://10.0.2.2:8080/api/articles/notifications/new';
  // ⚠ Android emulator dùng 10.0.2.2 thay localhost

  static Future<List<ArticleNotification>> fetchNotifications() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((e) => ArticleNotification.fromJson(e))
          .toList();
    } else {
      throw Exception('Không thể tải thông báo');
    }
  }
}
