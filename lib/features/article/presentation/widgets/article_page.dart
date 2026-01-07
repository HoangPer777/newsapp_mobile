import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../comment/presentation/comment_page.dart';
import '../../domain/entities/article_entity.dart';
import '../article_style.dart';
import '../notifier/article_detail_notifier.dart';
import '../notifier/article_detail_state.dart';
import '../providers/article_list_provider.dart';
import 'package:newsapp_mobile/features/chatbot/presentation/widgets/chatbot_widget.dart';

class ArticlePage extends ConsumerStatefulWidget {
  final String articleSlug;
  final ArticleEntity? article;

  const ArticlePage({
    Key? key,
    this.article,
    required this.articleSlug,
  }) : super(key: key);

  @override
  ConsumerState<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends ConsumerState<ArticlePage> {
  // Ảnh mặc định nếu bài báo không có ảnh
  static const String defaultImage = "https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&q=80";

  @override
  void initState() {
    super.initState();
    // Nếu không có dữ liệu truyền sang thì mới gọi API tải chi tiết
    if (widget.article == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(articleDetailNotifierProvider.notifier).loadArticle(widget.articleSlug);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy trạng thái chi tiết bài viết
    final state = ref.watch(articleDetailNotifierProvider);

    // 2. Lấy danh sách tin tức khác để hiển thị ở dưới
    final relatedState = ref.watch(articleListProvider('newest'));

    ArticleEntity? displayArticle = widget.article;
    bool isLoading = false;
    String? errorMsg;

    // Logic cập nhật dữ liệu từ Notifier
    if (state is ArticleDetailLoaded) {
      displayArticle = state.article;
    } else if (widget.article == null && state is ArticleDetailLoading) {
      isLoading = true;
    } else if (state is ArticleDetailError) {
      errorMsg = state.message;
    }

    // XỬ LÝ LỌC TIN LIÊN QUAN
    List<ArticleEntity> relatedArticles = [];
    relatedState.when(
      data: (articles) => relatedArticles = articles,
      error: (_, __) => relatedArticles = [],
      loading: () => relatedArticles = [],
    );

    // Lọc: Bỏ bài đang đọc & lấy tối đa 5 bài
    if (displayArticle != null && relatedArticles.isNotEmpty) {
      relatedArticles = relatedArticles
          .where((item) => item.id != null && item.id != displayArticle?.id)
          .take(5)
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Chi tiết bài báo'),
            backgroundColor: const Color(0xFF111214),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildBody(context, displayArticle, isLoading, errorMsg),
          ),

          // TIÊU ĐỀ TIN TỨC KHÁC
          if (displayArticle != null && relatedArticles.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(color: Colors.white24, thickness: 1),
                    const SizedBox(height: 15),
                    Text(
                      "TIN TỨC KHÁC",
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // DANH SÁCH TIN TỨC KHÁC (SliverList)
          if (displayArticle != null && relatedArticles.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _ArticleItem(article: relatedArticles[index]),
                childCount: relatedArticles.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      // Thanh điều hướng nổi ở dưới
      bottomNavigationBar: displayArticle != null
          ? _buildFloatingNavigationBar(context, displayArticle)
          : null,
    );
  }

  // --- Widget Nội Dung Chính ---
  Widget _buildBody(BuildContext context, ArticleEntity? article, bool isLoading, String? error) {
    if (isLoading) {
      return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return SizedBox(
        height: 400,
        child: Center(child: Text('Lỗi: $error', style: const TextStyle(color: Colors.red))),
      );
    }

    if (article != null) {
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      // Xử lý Null Safety cho từng trường
      final String title = article.title;
      final String content = article.content;
      final String category = (article.category == null || article.category!.isEmpty) ? 'TIN TỨC' : article.category!;
      final String author = article.authorName ?? 'Admin';
      final String imageUrl = (article.imageUrl != null && article.imageUrl!.isNotEmpty) ? article.imageUrl! : defaultImage;
      final String publishedDate = article.publishedAt != null ? dateFormatter.format(article.publishedAt!) : 'Vừa xong';

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh Header
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.network(defaultImage, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),

            // Chuyên mục
            Text(category.toUpperCase(), style: articleCategoryStyle),
            const SizedBox(height: 8),

            // Tiêu đề
            Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Metadata (Tác giả, Ngày)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    author.isNotEmpty ? author[0].toUpperCase() : 'A',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(author, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(publishedDate, style: articleMetadataStyle),
                  ],
                ),
              ],
            ),
            const Divider(height: 30, color: Colors.white12),

            // Nội dung bài viết
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.6),
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // --- Thanh Công Cụ Nổi ---
  Widget _buildFloatingNavigationBar(BuildContext context, ArticleEntity article) {
    final surfaceColor = const Color(0xFF1E1E1E);
    final primaryColor = const Color(0xFFBB1819);
    final int articleId = article.id ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),

          // Nút Chatbot AI
          FloatingActionButton.small(
            heroTag: 'chatbot_detail',
            backgroundColor: primaryColor,
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ChatbotWidget(articleId: articleId),
              );
            },
          ),

          // Nút Comment
          IconButton(
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  useSafeArea: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => CommentPage(
                    articleId: articleId,
                    currentUserId: 1, // Han thay bằng Provider User thực tế nhé
                  ),
                );
              }
          ),

          // Nút Bookmark
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.white70),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// WIDGET ITEM BÀI BÁO LIÊN QUAN
class _ArticleItem extends StatelessWidget {
  final ArticleEntity article;
  const _ArticleItem({required this.article});

  @override
  Widget build(BuildContext context) {
    final String author = article.authorName ?? 'Admin';
    final String category = (article.category == null || article.category!.isEmpty) ? 'Tin tức' : article.category!;
    final String dateStr = article.publishedAt != null ? DateFormat('dd/MM').format(article.publishedAt!) : '--/--';
    final String imageUrl = (article.imageUrl != null && article.imageUrl!.isNotEmpty) ? article.imageUrl! : "https://via.placeholder.com/150";

    return InkWell(
      onTap: () {
        // Mở trang bài báo mới
        context.push('/article/${article.id ?? article.title}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                imageUrl,
                width: 110,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(width: 110, height: 80, color: Colors.grey[900], child: const Icon(Icons.image_not_supported)),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin bài viết
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFBB1819).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(category.toUpperCase(), style: const TextStyle(color: Color(0xFFBB1819), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(author, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.grey, fontSize: 11))),
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 11)),
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