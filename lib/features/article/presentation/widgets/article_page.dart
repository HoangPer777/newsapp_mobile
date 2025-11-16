import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Import các style Dark Mode mới
import '../article_style.dart';
import '../notifier/article_detail_notifier.dart';
import '../notifier/article_detail_state.dart';

// ⚠️ Giả định:
// 1. Model `article` của bạn trong state 'ArticleDetailLoaded'
//    có một trường String là `image` (chứa URL của ảnh).
// 2. Các style 'articleBodyStyle', 'primaryRed', 'articleMetadataStyle'
//    đã được định nghĩa trong file 'article_style.dart'.

class ArticlePage extends ConsumerWidget {
  final String articleSlug;

  const ArticlePage({Key? key, required this.articleSlug}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Lấy trạng thái
    final state = ref.watch(articleDetailNotifierProvider);

    // Kích hoạt loadArticle sau khi build
    if (state is ArticleDetailInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(articleDetailNotifierProvider.notifier).loadArticle(articleSlug);
      });
    }

    return Scaffold(
      // 2. AppBar đã được định nghĩa trong Theme (Dark Mode)
      // Dùng SliverAppBar để có hiệu ứng đẹp hơn
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: const Text('Bài báo chi tiết'),
          ),
          // 3. Body
          SliverToBoxAdapter(
            child: _buildBody(context, state),
          ),
        ],
      ),

      // 4. Thanh Nút Nổi (Floating Bar)
      bottomNavigationBar: _buildFloatingNavigationBar(context),
    );
  }

  // --- HÀM XÂY DỰNG THANH NÚT NỔI (Đã cập nhật logic comment) ---
  Widget _buildFloatingNavigationBar(BuildContext context) {
    // Lấy màu nền Surface từ Dark Theme
    final surfaceColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      // Container làm nền cho thanh nổi, dùng màu Surface để tạo độ sâu
      decoration: BoxDecoration(color: surfaceColor, boxShadow: const [
        BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
      ]),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      height: 70, // Đặt chiều cao cố định để chứa các nút
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          // Nút 1: Quay lại/Thoát (Icon Button)
          IconButton(
            icon: Icon(Icons.close, color: primaryColor, size: 30),
            onPressed: () => Navigator.pop(context),
          ),

          // Nút 2: Comment (FloatingActionButton.small)
          _buildFloatingButton(Icons.chat_bubble_outline, 'comment', () {
            // ⭐ MỚI: Logic Comment - Mở Bottom Sheet
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Cho phép bottom sheet tùy chỉnh chiều cao
              backgroundColor: Colors.transparent,
              builder: (context) => _CommentsBottomSheet(),
            );
          }),

          // // Nút 3: Share (FloatingActionButton.small)
          // _buildFloatingButton(Icons.share, 'share', () {
          //   // Logic Share
          // }),
          //
          // // Nút 4: Tùy chọn khác (Icon Button)
          // IconButton(
          //   icon: Icon(Icons.more_horiz, color: primaryColor, size: 30),
          //   onPressed: () {
          //     // Logic More options
          //   },
          // ⭐ ĐÃ SỬA 1: Nút 3: Chatbot AI (FloatingActionButton.small)
          _buildFloatingButton(Icons.smart_toy_outlined, 'chatbot', () {
            // Logic mở Chatbot AI
            // Ví dụ: Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotPage()));
          }),

          // ⭐ ĐÃ SỬA 2: Nút 4: Lưu bài viết (Icon Button)
          IconButton(
            // Đổi icon thành bookmark (lưu)
            icon: Icon(Icons.bookmark_border, color: primaryColor, size: 30),
            onPressed: () {
              // Logic Lưu bài viết
              // Ví dụ: ref.read(bookmarksProvider.notifier).toggleBookmark(article.id);
            },
          ),
        ],
      ),
    );
  }

  // Widget riêng để tạo hiệu ứng FloatingActionButton
  Widget _buildFloatingButton(IconData icon, String tag, VoidCallback onPressed) {
    return FloatingActionButton.small(
      heroTag: tag, // Cần heroTag khác nhau cho mỗi FAB
      child: Icon(icon, size: 24),
      onPressed: onPressed,
    );
  }

  // --- PHƯƠNG THỨC XÂY DỰNG BODY (Đã thêm hình ảnh) ---
  Widget _buildBody(BuildContext context, ArticleDetailState state) {
    if (state is ArticleDetailLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ArticleDetailError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('LỖI TẢI DỮ LIỆU.\nChi tiết: ${state.message}',
              textAlign: TextAlign.center,
              style: articleBodyStyle.copyWith(color: primaryRed)),
        ),
      );
    }

    if (state is ArticleDetailLoaded) {
      final article = state.article;
      final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

      return SingleChildScrollView(
        // Đã bỏ SingleChildScrollView vì dùng CustomScrollView bên ngoài
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Tiêu đề (Sử dụng Dark Mode style)
            Text(
              article.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            // Tác giả và Ngày xuất bản (Sử dụng Dark Mode style)
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Tác giả: ${article.author}', // Dùng trường author đã map
                  style: articleMetadataStyle,
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  dateFormatter.format(article.publishedAt.toLocal()),
                  style: articleMetadataStyle,
                ),
              ],
            ),
            const Divider(height: 30, color: Colors.white12),

            // ⭐ MỚI: HÌNH ẢNH BÀI BÁO
            // Giả sử model 'article' của bạn có trường 'image'
            if (article.image != null && article.image.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  article.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Hiển thị loading
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  // Hiển thị lỗi
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Nội dung (Sử dụng Dark Mode style)
            Text(
              article.contentPlain,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),

            // Thêm khoảng đệm cuối
            const SizedBox(height: 40),
          ],
        ),
      );
    }

    return const Center(
        child:
        Text("Đang tải dữ liệu...", style: TextStyle(color: Colors.white70)));
  }
}

// ⭐ MỚI: WIDGET CHO PHẦN BÌNH LUẬN (BOTTOM SHEET)
// (Bạn có thể tách ra file riêng nếu muốn)
class _CommentsBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả (bạn sẽ thay thế bằng API hoặc provider)
    final comments = [
      {'author': 'Minh Anh', 'content': 'Bài viết rất hay!'},
      {'author': 'Bao Truong', 'content': 'Cảm ơn thông tin hữu ích.'},
      {'author': 'Hoang Phuc', 'content': 'Cần thêm chi tiết về Virtual Threads.'},
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Bắt đầu ở 70%
      minChildSize: 0.5,
      maxChildSize: 0.95, // Gần đầy màn hình
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF191A1D), // Nền tối
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Thanh kéo (handle)
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Tiêu đề
              Text(
                'Bình luận (${comments.length})',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const Divider(color: Colors.white24),

              // Danh sách bình luận
              Expanded(
                child: ListView.separated(
                  controller: scrollController, // Gắn controller để kéo
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Container(
                      padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E2023),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment['author']!,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(comment['content']!, style: articleBodyStyle),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                ),
              ),

              // Ô nhập bình luận (cố định ở đáy)
              Container(
                padding: const EdgeInsets.all(16).copyWith(top: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF111214), // Nền input
                  border: Border(top: BorderSide(color: Color(0xFF2A2C30))),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Viết bình luận của bạn...',
                    fillColor: const Color(0xFF2A2C30),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
                      onPressed: () { /* Logic gửi comment */ },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}