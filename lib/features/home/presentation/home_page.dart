import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// --- 1. IMPORT CÁC FILE CẦN THIẾT ---
import '../../../core/di/providers.dart';
import '../data/home_api.dart';
// Import Provider lấy danh sách bài báo
import '../../article/presentation/providers/article_list_provider.dart';
// Import Trang chi tiết để điều hướng
import '../../article/presentation/widgets/article_page.dart';
// Import Entity để dùng dữ liệu
import '../../article/domain/entities/article_entity.dart';

/// Health ping
final healthProvider = FutureProvider<String>((ref) async {
  final dio = ref.read(dioProvider);
  return HomeApi(dio).health();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            // --- 2. SỬA PHẦN BODY ĐỂ HIỂN THỊ TIN TỨC ---
            body: TabBarView(
              children: [
                // Tab 1: Trang chủ -> Hiển thị danh sách tin tức thật
                const _NewsTab(),

                // Các tab còn lại: Giữ nguyên placeholder hoặc tái sử dụng _NewsTab
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
          bottomNavigationBar: _BottomNav(
            onTap: (i) {
              // 0: Home, 1: Search, 2: Chat, 3: Video, 4: Menu
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

// --- 3. WIDGET TAB HIỂN THỊ DANH SÁCH TIN (MỚI) ---
class _NewsTab extends ConsumerWidget {
  const _NewsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lắng nghe Article List Provider
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

        // Sử dụng ListView.builder để hiển thị danh sách
        // Dùng padding bottom để không bị che bởi BottomNav nếu cần
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

// --- 4. WIDGET ITEM BÀI BÁO (MỚI) ---
class _ArticleItem extends StatelessWidget {
  final ArticleEntity article;

  const _ArticleItem({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Sự kiện bấm vào bài báo
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            // Truyền trực tiếp Entity sang trang chi tiết
            builder: (context) => ArticlePage(
              article: article,
              articleSlug: article.id.toString(), // <-- NÊN SỬA THÀNH CÁI NÀY
              // articleSlug: '',
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh Thumbnail (Bên trái)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                article.imageUrl ?? "https://via.placeholder.com/150",
                width: 110,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 80,
                  color: const Color(0xFF2A2C30),
                  child:
                      const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin (Bên phải)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Metadata (Tác giả - Thời gian)
                  Row(
                    children: [
                      // Icon category hoặc tác giả
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFbb1819).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        // child: const Text(
                        //   'Tin tức', // Hoặc article.category nếu có
                        //   style: TextStyle(color: Color(0xFFbb1819), fontSize: 10, fontWeight: FontWeight.bold),
                        // ),
                        child: Text(
                          // Logic: Nếu có category thì hiện và viết hoa, nếu rỗng thì hiện 'TIN TỨC'
                          (article.category.isNotEmpty
                                  ? article.category
                                  : 'Tin tức')
                              .toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFFbb1819),
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          article.authorName,
                          overflow: TextOverflow.ellipsis,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ),
                      const Icon(Icons.access_time,
                          size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM').format(article.publishedAt),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
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

class _TopAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      titleSpacing: 12,
      leadingWidth: 44,
      leading: const _CircleIcon(icon: Icons.text_fields), // Aa
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          _VnxNews(),
          const SizedBox(width: 8),
          const Text(
            'Báo tiếng Việt cập nhật nhanh nhất',
            style: TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => context.push('/notification'), // 🆕 chuyển sang trang thông báo
            child: const _CircleIcon(icon: Icons.notifications_none),
          ),
        ),
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
          decoration: const BoxDecoration(
            color: Color(0xFF191A1D),
            border: Border(
              top: BorderSide(color: Color(0xFF2A2C30)),
              bottom: BorderSide(color: Color(0xFF2A2C30)),
            ),
          ),
          child: TabBar(
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            labelPadding: const EdgeInsets.symmetric(horizontal: 16),
            indicatorColor: const Color(0xFFbb1819),
            indicatorSize: TabBarIndicatorSize.label,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/images/logo_VNXnews.png',
            height: 26,
            width: 26,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Vnx news',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
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
      decoration: BoxDecoration(
        color: const Color(0xFF1E2023),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF2A2C30)),
      ),
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
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: Colors.white70),
          selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFbb1819)),
          label: 'Trang chủ',
        ),
        NavigationDestination(
          icon: Icon(Icons.search, color: Colors.white70),
          selectedIcon: Icon(Icons.search, color: Color(0xFFbb1819)),
          label: 'A.I Search',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat, color: Colors.white70),
          selectedIcon: Icon(Icons.chat, color: Color(0xFFbb1819)),
          label: 'Bot',
        ),
        NavigationDestination(
          icon: Icon(Icons.ondemand_video, color: Colors.white70),
          selectedIcon: Icon(Icons.ondemand_video, color: Color(0xFFbb1819)),
          label: 'Video',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_open_outlined, color: Colors.white70),
          selectedIcon:
              Icon(Icons.menu_open_outlined, color: Color(0xFFbb1819)),
          label: 'Menu',
        ),
      ],
    );
  }
}

class _TabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _TabHeaderDelegate({required this.child});
  final Widget child;

  @override
  double get minExtent => 44;

  @override
  double get maxExtent => 44;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TabHeaderDelegate oldDelegate) => false;
}
