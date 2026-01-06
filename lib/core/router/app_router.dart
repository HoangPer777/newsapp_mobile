import 'package:go_router/go_router.dart';
import 'package:flutter/widgets.dart';
import '../../features/article/presentation/widgets/add_article_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/article/presentation/widgets/article_page.dart';
import '../../features/chatbot/presentation/chat_page.dart';
import '../../features/search/presentation/search_page.dart';
import '../../features/comment/presentation/comment_page.dart';
import '../../features/menu/presentation/menu_page/menu_page.dart';
import '../../features/menu/presentation/menu_page/account_page.dart';
import '../../features/menu/presentation/menu_page/edit_profile.dart';
import '../../features/notification/presentation/notification_page.dart';
class AppRouter {
  GoRouter get router => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomePage()),
      GoRoute(path: '/login', builder: (c, s) => const LoginPage()),
      GoRoute(
        path: '/add-article',
        builder: (context, state) => const AddArticlePage(),
      ),
      GoRoute(path: '/register', builder: (c, s) => const RegisterPage()),
      GoRoute(path: '/article/:id', builder: (c, s) {
        final id = s.pathParameters['id']!;
        // Sửa lỗi: Truyền giá trị vào tham số articleSlug
        return ArticlePage(articleSlug: id);
      }),
      GoRoute(path: '/search', builder: (c, s) => const SearchPage()),
      GoRoute(path: '/comments/:articleId', builder: (c, s) {
        final idString = s.pathParameters['articleId']!;
        final int id = int.tryParse(idString) ?? 0;
        return CommentPage(articleId: id);
      }),
      GoRoute(path: '/chat', builder: (c, s) => const ChatPage()),
      GoRoute(
          path: '/notification',
          builder: (c, s) => const NotificationPage()),
      GoRoute(
        path: '/menu',
        builder: (_, __) => const MenuPage(),
      ),
      GoRoute(path: '/account', builder: (c, s) => const AccountPage()),
      GoRoute(path: '/account/edit', builder: (c, s) => const EditAccountPage()),
    ],
  );
}
