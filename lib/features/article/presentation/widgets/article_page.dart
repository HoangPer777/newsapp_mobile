import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../comment/presentation/comment_page.dart';
import '../../domain/entities/article_entity.dart';
import '../article_style.dart';
import '../notifier/article_detail_notifier.dart';
import '../notifier/article_detail_state.dart';
import '../providers/article_list_provider.dart';

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
  // Ảnh mặc định
  static const String defaultImage = "https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&q=80";

  @override
  void initState() {
    super.initState();
    // Nếu không có dữ liệu truyền sang thì mới gọi API tải lại
    if (widget.article == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(articleDetailNotifierProvider.notifier).loadArticle(widget.articleSlug);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Lấy trạng thái bài viết chi tiết (để hiển thị nội dung chính)
    final state = ref.watch(articleDetailNotifierProvider);

    // 2. LẤY DANH SÁCH TIN KHÁC TỪ PROVIDER
    final relatedState = ref.watch(articleListProvider);

    ArticleEntity? displayArticle = widget.article;
    bool isLoading = false;
    String? errorMsg;

    // Logic ưu tiên dữ liệu mới nhất
    if (state is ArticleDetailLoaded) {
      displayArticle = state.article;
    } else if (widget.article == null && state is ArticleDetailLoading) {
      isLoading = true;
    } else if (state is ArticleDetailError) {
      errorMsg = state.message;
    }

    // XỬ LÝ LỌC TIN LIÊN QUAN
    List<ArticleEntity> relatedArticles = [];

    if (relatedState is AsyncData<List<ArticleEntity>>) {
      // Trường hợp 1: Provider trả về AsyncValue (thường gặp)
      relatedArticles = relatedState.value;
    } else if (relatedState is List<ArticleEntity>) {
      // Trường hợp 2: Provider trả về List trực tiếp
      relatedArticles = relatedState as List<ArticleEntity>;
    } else {
      // Trường hợp 3: Provider trả về State Class (ArticleListLoaded...)
      try {
        final dynamic dynamicState = relatedState;
        if (dynamicState.articles is List<ArticleEntity>) {
          relatedArticles = dynamicState.articles;
        }
      } catch (e) {
      }
    }

    // Lọc: Bỏ bài đang đọc & lấy 5 bài đầu
    if (displayArticle != null && relatedArticles.isNotEmpty) {
      relatedArticles = relatedArticles
          .where((item) => item.id != displayArticle!.id)
          .take(5)
          .toList();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // Dùng CustomScrollView cho hiệu ứng cuộn đẹp
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Bài báo chi tiết'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: _buildBody(context, displayArticle, isLoading, errorMsg),
          ),

          // DANH SÁCH TIN TỨC KHÁC
          // 3. Tiêu đề "TIN TỨC KHÁC"
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

          // 4. Danh sách bài viết (SliverList)
          if (displayArticle != null && relatedArticles.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _ArticleItem(article: relatedArticles[index]);
                },
                childCount: relatedArticles.length,
              ),
            ),

          // Khoảng trắng dưới cùng để không bị nút nổi che mất
          const SliverToBoxAdapter(child: SizedBox(height: 80)),

        ],
      ),
      // Thanh công cụ nổi
      bottomNavigationBar: _buildFloatingNavigationBar(context),
    );
  }

  // --- Widget Nội Dung ---
  Widget _buildBody(BuildContext context, ArticleEntity? article, bool isLoading, String? error) {
    if (isLoading) {
      return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
    }

    if (error != null) {
      return SizedBox(
        height: 400,
        child: Center(child: Text('Lỗi: $error', style: TextStyle(color: Theme.of(context).primaryColor))),
      );
    }

    if (article != null) {
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      final String imageUrl = (article.imageUrl != null && article.imageUrl!.isNotEmpty)
          ? article.imageUrl!
          : defaultImage;

      print('DEBUG LOG: Category là: ${article.category}');
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
                errorBuilder: (context, error, stackTrace) => Image.network(
                  defaultImage,
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 250,
                    color: Colors.grey[900],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            Text(
              (article.category.isEmpty ? 'TIN TỨC' : article.category).toUpperCase(),
              style: articleCategoryStyle,
            ),
            const SizedBox(height: 8),

            // Tiêu đề
            Text(article.title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),

            // Metadata (Tác giả, Ngày)
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                      article.authorName.isNotEmpty ? article.authorName[0] : 'A',
                      style: const TextStyle(color: Colors.white)
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(article.authorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Text(dateFormatter.format(article.publishedAt), style: articleMetadataStyle),
                  ],
                ),
              ],
            ),
            const Divider(height: 30, color: Colors.white12),

            // Nội dung bài viết
            Text(
              article.content,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // --- Widget Thanh Nổi ---
  Widget _buildFloatingNavigationBar(BuildContext context) {
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.95),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back), color: primaryColor, onPressed: () => Navigator.pop(context)),

          // Nút Chatbot AI
          FloatingActionButton.small(
            heroTag: 'chatbot',
            backgroundColor: primaryColor,
            child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
            onPressed: () {},
          ),

          // Nút Comment (Mở BottomSheet)
          IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              color: Colors.white70,
              onPressed: () {
                if (widget.article != null || int.tryParse(widget.articleSlug) != null) {
                  // Xác định ID bài viết
                  final int idBaiViet = widget.article?.id ?? int.parse(widget.articleSlug);

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true, // Để kéo lên cao được
                    useSafeArea: true,        // Tránh bị đè lên thanh status bar
                    backgroundColor: Colors.transparent,
                    builder: (context) => CommentPage(
                      articleId: idBaiViet, // Truyền ID (số) vào đây
                      currentUserId: 1,     // Tạm thời để cứng là 1, sau này lấy từ UserProvider
                    ),
                  );
                }
              }
          ),
          // Nút Bookmark
          IconButton(icon: const Icon(Icons.bookmark_border), color: Colors.white70, onPressed: () {}),
        ],
      ),
    );
  }
}

// WIDGET ITEM BÀI BÁO
class _ArticleItem extends StatelessWidget {
  final ArticleEntity article;

  const _ArticleItem({required this.article});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // Sự kiện bấm vào bài báo -> Mở trang chi tiết mới
      onTap: () {
        // Dùng push để chồng lên trang cũ
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticlePage(
              article: article,
              articleSlug: article.id.toString(),
            ),
          ),
        );
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
                article.imageUrl ?? "https://via.placeholder.com/150",
                width: 110,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 80,
                  color: const Color(0xFF2A2C30),
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Thông tin
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

                  // Metadata (Category - Tác giả - Thời gian)
                  Row(
                    children: [
                      // Tag Category
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFbb1819).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          (article.category.isNotEmpty ? article.category : 'Tin tức').toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFFbb1819),
                              fontSize: 10,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tác giả
                      Expanded(
                        child: Text(
                          article.authorName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ),

                      // Thời gian
                      const Icon(Icons.access_time, size: 12, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM').format(article.publishedAt),
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
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
