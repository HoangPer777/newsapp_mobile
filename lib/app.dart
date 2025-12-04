// import 'package:flutter/material.dart';
// import 'core/router/app_router.dart';
//
// class NewsApp extends StatelessWidget {
//   const NewsApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final router = AppRouter().router;
//     return MaterialApp.router(
//       title: 'NewsApp',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
//       routerConfig: router,
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // 1. Import Riverpod
import 'package:go_router/go_router.dart'; // 2. Import GoRouter
import 'core/router/app_router.dart'; // Router của bạn
import 'features/article/presentation/article_style.dart'; // Import theme dark mode

// 3. Tạo một Provider để "cung cấp" AppRouter
// Điều này đảm bảo router chỉ được tạo MỘT LẦN
final goRouterProvider = Provider<GoRouter>((ref) {
  return AppRouter().router;
});

// 4. Biến NewsApp thành "ConsumerWidget"
class NewsApp extends ConsumerWidget { // <-- Thay vì StatelessWidget
  const NewsApp({super.key});

  @override
  // 5. Thêm "WidgetRef ref" vào hàm build
  Widget build(BuildContext context, WidgetRef ref) {
    // 6. Đọc router từ provider, thay vì tạo mới
    final router = ref.watch(goRouterProvider);

    // Giữ nguyên phần còn lại
    return MaterialApp.router(
      title: 'Vnx News',
      debugShowCheckedModeBanner: false,
      theme: newsAppDarkTheme, // Sử dụng theme dark mode
      routerConfig: router,
    );
  }
}