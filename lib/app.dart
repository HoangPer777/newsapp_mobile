import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/router/app_router.dart';
import 'features/article/presentation/article_style.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter().router;
});

class NewsApp extends ConsumerWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Vnx News',
      debugShowCheckedModeBanner: false,
      theme: newsAppDarkTheme,
      routerConfig: router,
    );
  }
}