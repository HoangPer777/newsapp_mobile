import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/article/presentation/widgets/article_page.dart';
import '../../features/chatbot/presentation/chat_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/comment/presentation/comment_page.dart';

class AppRouter {
  GoRouter get router => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(path: '/article/:id', builder: (c, s) {
        final id = s.pathParameters['id']!;
        // ✅ Sửa lỗi: Truyền giá trị vào tham số articleSlug
        return ArticlePage(articleSlug: id);
      }),
      GoRoute(path: '/search', builder: (c, s) => const SearchPage()),
      GoRoute(path: '/comments/:articleId', builder: (c, s) {
        final id = s.pathParameters['articleId']!;
        return CommentPage(articleId: id);
      }),
      GoRoute(path: '/chat', builder: (c, s) => const ChatPage()),
    ],
  );
}
