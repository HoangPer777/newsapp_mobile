import 'package:flutter/material.dart';
import '../../article/presentation/widgets/article_page.dart';
import '../model/article_notification.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<ArticleNotification>> _future;

  @override
  void initState() {
    super.initState();
    _future = NotificationService.fetchNotifications();
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    return '${diff.inDays} ngày trước';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111214),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF111214),
      body: FutureBuilder<List<ArticleNotification>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Lỗi tải thông báo',
                style: TextStyle(color: Colors.redAccent),
              ),
            );
          }

          final notifications = snapshot.data!;

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (_, __) =>
            const Divider(color: Colors.white24),
            itemBuilder: (context, index) {
              final n = notifications[index];
              return ListTile(
                leading: const Icon(
                  Icons.notifications,
                  color: Color(0xFFbb1819),
                ),
                title: Text(
                  n.title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  n.message,
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: Text(
                  timeAgo(n.createdAt),
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticlePage(
                        articleSlug: n.articleId.toString(), // Chuyển ID sang String cho slug
                        article: null, // Truyền null để ép ArticlePage gọi API load chi tiết
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

}
