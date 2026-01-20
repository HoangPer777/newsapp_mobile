import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/env.dart';
import '../model/article_notification.dart';

class NotificationService {
  static final String baseUrl =
      '${Env.apiBase}/api/articles/notifications/new';

  static Future<List<ArticleNotification>> fetchNotifications() async {
    print('Fetching notifications from: $baseUrl');
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data
          .map((e) => ArticleNotification.fromJson(e))
          .toList();
    } else {
      throw Exception(
          'Không thể tải thông báo. Status: ${response.statusCode}. Body: ${response.body}');
    }
  }
}
