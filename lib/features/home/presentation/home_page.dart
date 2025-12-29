import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- IMPORT CÁC FILE CẦN THIẾT ---
import '../../../core/di/providers.dart';
import '../data/home_api.dart';
import '../../article/presentation/providers/article_list_provider.dart';
import '../../article/presentation/widgets/article_page.dart';
import '../../article/domain/entities/article_entity.dart';

/// Provider để kiểm tra quyền Admin từ bộ nhớ máy
final userRoleProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'role');
});

/// Health ping (Giữ nguyên của Han)
final healthProvider = FutureProvider<String>((ref) async {
  final dio = ref.read(dioProvider);
  return HomeApi(dio).health();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe quyền của người dùng (ADMIN/USER)
    final userRoleAsync = ref.watch(userRoleProvider);

    final categories = const [
      'Trang chủ',
      'Mới nhất',
      'Đọc nhanh',
      'Xem nhiều',
      'Kinh doanh',
      'Thế giới',
    ];

    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFbb1819),
      brightness: Brightness.dark,
    );

    return Theme(
      data: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFF111214),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF111214)),
      ),
      child: DefaultTabController(
        length: categories.length,
        child: Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerScrolled) => [
              _TopAppBar(),
              _CategoryTabs(categories: categories),
            ],
            body: TabBarView(
              children: [
                const _NewsTab(),
                ...List.generate(
                  categories.length - 1,
                      (_) => const Center(
                    child: Text('Đang cập nhật...',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
              ],
            ),
          ),

          // --- PHẦN MỚI: NÚT THÊM BÀI CHỈ HIỆN KHI LÀ ADMIN ---
          floatingActionButton: userRoleAsync.when(
            data: (role) => role == 'ADMIN'
                ? FloatingActionButton(
              backgroundColor: const Color(0xFFbb1819),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () => context.push('/add-article'),
            )
                : null,
            loading: () => null,
            error: (_, __) => null,
          ),

          bottomNavigationBar: _BottomNav(
            onTap: (i) {
              if (i == 1) context.push('/search');
              if (i == 2) context.push('/chat');
              if (i == 4) context.push('/menu');
            },
          ),
        ),
      ),
    );
  }
}

// --- WIDGET HIỂN THỊ DANH SÁCH TIN ---
class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncArticles = ref.watch(articleListProvider);

    return asyncArticles.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Lỗi tải tin: $err',
              style: const TextStyle(color: Colors.red)),
        ),
      ),
      data: (articles) {
        if (articles.isEmpty) {
          return const Center(
              child: Text("Chưa có bài báo nào",
                  style: TextStyle(color: Colors.white70)));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: articles.length,
          separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0xFF2A2C30)),
          itemBuilder: (context, index) {
            return _ArticleItem(article: articles[index]);
          },
        );
      },
    );
  }
}

// --- WIDGET ITEM BÀI BÁO (Xử lý Null Safety) ---
class _ArticleItem extends StatelessWidget {
  final ArticleEntity article;
  const _ArticleItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final String categoryName = (article.category == null || article.category!.isEmpty) ? 'Tin tức' : article.category!;
    final String authorName = article.authorName ?? 'Admin';
    final String publishedDate = article.publishedAt != null ? DateFormat('dd/MM').format(article.publishedAt!) : '--/--';

    return InkWell(
      onTap: () => context.push('/article/${article.id ?? article.title}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imageUrl ?? "https://via.placeholder.com/150",
                width: 110, height: 80, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 110, height: 80, color: const Color(0xFF2A2C30), child: const Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(article.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFbb1819).withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                        child: Text(categoryName.toUpperCase(), style: const TextStyle(color: Color(0xFFbb1819), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(authorName, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11))),
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(publishedDate, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// --- APP BAR VÀ CÁC WIDGET PHỤ GIAO DIỆN (Gốc của Han) ---

class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      titleSpacing: 12,
      leadingWidth: 44,
      leading: const _CircleIcon(icon: Icons.text_fields),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _VnxNews(),
          const SizedBox(width: 8),
          const Text('Báo tiếng Việt cập nhật nhanh nhất', style: TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
      actions: [
        IconButton(icon: const Icon(Icons.login, color: Colors.white70), onPressed: () => context.push('/login')),
        const Padding(padding: EdgeInsets.only(right: 8), child: _CircleIcon(icon: Icons.notifications_none)),
      ],
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.categories});
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _TabHeaderDelegate(
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFF191A1D), border: Border(top: BorderSide(color: Color(0xFF2A2C30)), bottom: BorderSide(color: Color(0xFF2A2C30)))),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            indicatorColor: const Color(0xFFbb1819),
            labelColor: const Color(0xFFbb1819),
            unselectedLabelColor: Colors.white70,
            tabs: categories.map((e) => Tab(text: e)).toList(),
          ),
        ),
      ),
    );
  }
}

class _VnxNews extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo_VNXnews.png', height: 26),
        const SizedBox(width: 6),
        const Text('Vnx news', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: const Color(0xFF1E2023), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF2A2C30))),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onTap});
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      backgroundColor: const Color(0xFF111214),
      indicatorColor: const Color(0xFFbb1819),
      selectedIndex: 0,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Trang chủ'),
        NavigationDestination(icon: Icon(Icons.search), label: 'A.I Search'),
        NavigationDestination(icon: Icon(Icons.chat), label: 'Bot'),
        NavigationDestination(icon: Icon(Icons.ondemand_video), label: 'Video'),
        NavigationDestination(icon: Icon(Icons.menu_open_outlined), label: 'Menu'),
      ],
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabHeaderDelegate({required this.child});
  final Widget child;
  @override double get minExtent => 44;
  @override double get maxExtent => 44;
  @override Widget build(context, shrink, overlap) => child;
  @override bool shouldRebuild(old) => false;
}