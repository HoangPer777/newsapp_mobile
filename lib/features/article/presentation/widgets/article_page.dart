// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
//
// // Import các style Dark Mode mới
// import '../article_style.dart';
// import '../notifier/article_detail_notifier.dart';
// import '../notifier/article_detail_state.dart';
//
// // ⚠️ Giả định:
// // 1. Model `article` của bạn trong state 'ArticleDetailLoaded'
// //    có một trường String là `image` (chứa URL của ảnh).
// // 2. Các style 'articleBodyStyle', 'primaryRed', 'articleMetadataStyle'
// //    đã được định nghĩa trong file 'article_style.dart'.
//
// class ArticlePage extends ConsumerWidget {
//   final String articleSlug;
//
//   const ArticlePage({Key? key, required this.articleSlug}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Lấy trạng thái
//     final state = ref.watch(articleDetailNotifierProvider);
//
//     // Kích hoạt loadArticle sau khi build
//     if (state is ArticleDetailInitial) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(articleDetailNotifierProvider.notifier).loadArticle(articleSlug);
//       });
//     }
//
//     return Scaffold(
//       // 2. AppBar đã được định nghĩa trong Theme (Dark Mode)
//       // Dùng SliverAppBar để có hiệu ứng đẹp hơn
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             title: const Text('Bài báo chi tiết'),
//           ),
//           // 3. Body
//           SliverToBoxAdapter(
//             child: _buildBody(context, state),
//           ),
//         ],
//       ),
//
//       // 4. Thanh Nút Nổi (Floating Bar)
//       bottomNavigationBar: _buildFloatingNavigationBar(context),
//     );
//   }
//
//   // --- HÀM XÂY DỰNG THANH NÚT NỔI (Đã cập nhật logic comment) ---
//   Widget _buildFloatingNavigationBar(BuildContext context) {
//     // Lấy màu nền Surface từ Dark Theme
//     final surfaceColor = Theme.of(context).colorScheme.surface;
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return Container(
//       // Container làm nền cho thanh nổi, dùng màu Surface để tạo độ sâu
//       decoration: BoxDecoration(color: surfaceColor, boxShadow: const [
//         BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2)
//       ]),
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
//       height: 70, // Đặt chiều cao cố định để chứa các nút
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: <Widget>[
//           // Nút 1: Quay lại/Thoát (Icon Button)
//           IconButton(
//             icon: Icon(Icons.close, color: primaryColor, size: 30),
//             onPressed: () => Navigator.pop(context),
//           ),
//
//           // Nút 2: Comment (FloatingActionButton.small)
//           _buildFloatingButton(Icons.chat_bubble_outline, 'comment', () {
//             // ⭐ MỚI: Logic Comment - Mở Bottom Sheet
//             showModalBottomSheet(
//               context: context,
//               isScrollControlled: true, // Cho phép bottom sheet tùy chỉnh chiều cao
//               backgroundColor: Colors.transparent,
//               builder: (context) => _CommentsBottomSheet(),
//             );
//           }),
//
//           // // Nút 3: Share (FloatingActionButton.small)
//           // _buildFloatingButton(Icons.share, 'share', () {
//           //   // Logic Share
//           // }),
//           //
//           // // Nút 4: Tùy chọn khác (Icon Button)
//           // IconButton(
//           //   icon: Icon(Icons.more_horiz, color: primaryColor, size: 30),
//           //   onPressed: () {
//           //     // Logic More options
//           //   },
//           // ⭐ ĐÃ SỬA 1: Nút 3: Chatbot AI (FloatingActionButton.small)
//           _buildFloatingButton(Icons.smart_toy_outlined, 'chatbot', () {
//             // Logic mở Chatbot AI
//             // Ví dụ: Navigator.push(context, MaterialPageRoute(builder: (_) => ChatbotPage()));
//           }),
//
//           // ⭐ ĐÃ SỬA 2: Nút 4: Lưu bài viết (Icon Button)
//           IconButton(
//             // Đổi icon thành bookmark (lưu)
//             icon: Icon(Icons.bookmark_border, color: primaryColor, size: 30),
//             onPressed: () {
//               // Logic Lưu bài viết
//               // Ví dụ: ref.read(bookmarksProvider.notifier).toggleBookmark(article.id);
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Widget riêng để tạo hiệu ứng FloatingActionButton
//   Widget _buildFloatingButton(IconData icon, String tag, VoidCallback onPressed) {
//     return FloatingActionButton.small(
//       heroTag: tag, // Cần heroTag khác nhau cho mỗi FAB
//       child: Icon(icon, size: 24),
//       onPressed: onPressed,
//     );
//   }
//
//   // --- PHƯƠNG THỨC XÂY DỰNG BODY (Đã thêm hình ảnh) ---
//   Widget _buildBody(BuildContext context, ArticleDetailState state) {
//     if (state is ArticleDetailLoading) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     if (state is ArticleDetailError) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Text('LỖI TẢI DỮ LIỆU.\nChi tiết: ${state.message}',
//               textAlign: TextAlign.center,
//               style: articleBodyStyle.copyWith(color: primaryRed)),
//         ),
//       );
//     }
//
//     if (state is ArticleDetailLoaded) {
//       final article = state.article;
//       final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
//
//       return SingleChildScrollView(
//         // Đã bỏ SingleChildScrollView vì dùng CustomScrollView bên ngoài
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // Tiêu đề (Sử dụng Dark Mode style)
//             Text(
//               article.title,
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//             const SizedBox(height: 12),
//
//             // Tác giả và Ngày xuất bản (Sử dụng Dark Mode style)
//             Row(
//               children: [
//                 const Icon(Icons.person, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(
//                   'Tác giả: ${article.author}', // Dùng trường author đã map
//                   style: articleMetadataStyle,
//                 ),
//                 const SizedBox(width: 16),
//                 const Icon(Icons.access_time, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(
//                   dateFormatter.format(article.publishedAt.toLocal()),
//                   style: articleMetadataStyle,
//                 ),
//               ],
//             ),
//             const Divider(height: 30, color: Colors.white12),
//
//             // ⭐HÌNH ẢNH BÀI BÁO
//             // Giả sử model 'article' của bạn có trường 'image'
//             if (article.image != null && article.image.isNotEmpty) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   article.image,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   // Hiển thị loading
//                   loadingBuilder: (context, child, loadingProgress) {
//                     if (loadingProgress == null) return child;
//                     return Container(
//                       height: 200,
//                       color: Colors.grey[800],
//                       child: const Center(child: CircularProgressIndicator()),
//                     );
//                   },
//                   // Hiển thị lỗi
//                   errorBuilder: (context, error, stackTrace) {
//                     return Container(
//                       height: 200,
//                       color: Colors.grey[800],
//                       child: const Icon(Icons.image_not_supported,
//                           color: Colors.grey),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//
//             // Nội dung (Sử dụng Dark Mode style)
//             Text(
//               article.contentPlain,
//               style: Theme.of(context).textTheme.bodyLarge,
//               textAlign: TextAlign.justify,
//             ),
//
//             // Thêm khoảng đệm cuối
//             const SizedBox(height: 40),
//           ],
//         ),
//       );
//     }
//
//     return const Center(
//         child:
//         Text("Đang tải dữ liệu...", style: TextStyle(color: Colors.white70)));
//   }
// }
//
// // ⭐  WIDGET CHO PHẦN BÌNH LUẬN (BOTTOM SHEET)
// class _CommentsBottomSheet extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     // Dữ liệu giả (bạn sẽ thay thế bằng API hoặc provider)
//     final comments = [
//       {'author': 'Minh Anh', 'content': 'Bài viết rất hay!'},
//       {'author': 'Bao Truong', 'content': 'Cảm ơn thông tin hữu ích.'},
//       {'author': 'Hoang Phuc', 'content': 'Cần thêm chi tiết về Virtual Threads.'},
//     ];
//
//     return DraggableScrollableSheet(
//       initialChildSize: 0.7, // Bắt đầu ở 70%
//       minChildSize: 0.5,
//       maxChildSize: 0.95, // Gần đầy màn hình
//       builder: (context, scrollController) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Color(0xFF191A1D), // Nền tối
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//           ),
//           child: Column(
//             children: [
//               // Thanh kéo (handle)
//               Container(
//                 width: 40,
//                 height: 5,
//                 margin: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[700],
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               // Tiêu đề
//               Text(
//                 'Bình luận (${comments.length})',
//                 style: Theme.of(context).textTheme.headlineSmall,
//               ),
//               const Divider(color: Colors.white24),
//
//               // Danh sách bình luận
//               Expanded(
//                 child: ListView.separated(
//                   controller: scrollController, // Gắn controller để kéo
//                   padding: const EdgeInsets.all(16),
//                   itemCount: comments.length,
//                   itemBuilder: (context, index) {
//                     final comment = comments[index];
//                     return Container(
//                       padding:
//                       const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF1E2023),
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             comment['author']!,
//                             style: TextStyle(
//                               color: Theme.of(context).primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(comment['content']!, style: articleBodyStyle),
//                         ],
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, index) => const SizedBox(height: 12),
//                 ),
//               ),
//
//               // Ô nhập bình luận (cố định ở đáy)
//               Container(
//                 padding: const EdgeInsets.all(16).copyWith(top: 8),
//                 decoration: const BoxDecoration(
//                   color: Color(0xFF111214), // Nền input
//                   border: Border(top: BorderSide(color: Color(0xFF2A2C30))),
//                 ),
//                 child: TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Viết bình luận của bạn...',
//                     fillColor: const Color(0xFF2A2C30),
//                     filled: true,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: Icon(Icons.send, color: Theme.of(context).primaryColor),
//                       onPressed: () { /* Logic gửi comment */ },
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
//
// // Import các file cần thiết
// import '../../domain/entities/article_entity.dart'; // Sử dụng ArticleEntity
// import '../article_style.dart'; // File chứa style Dark Mode & màu #bb1819
// import '../notifier/article_detail_notifier.dart';
// import '../notifier/article_detail_state.dart';
//
// class ArticlePage extends ConsumerWidget {
//   // 1. Thêm tham số 'article' (Optional) để nhận dữ liệu từ danh sách
//   final ArticleEntity? article;
//   // ⚠️ Quan trọng: Giả định Router truyền vào ID dạng String (ví dụ: '13')
//   final String articleSlug;
//
//   const ArticlePage({
//     Key? key,
//     this.article,   // <-- THÊM DÒNG NÀY
//     required this.articleSlug
//   }) : super(key: key);
//
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // 1. Lấy trạng thái
//     final state = ref.watch(articleDetailNotifierProvider);
//
//     // Kích hoạt loadArticle sau khi build
//     if (state is ArticleDetailInitial) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         // Chỉ gọi loadArticle nếu trạng thái vẫn là Initial
//         ref.read(articleDetailNotifierProvider.notifier).loadArticle(articleSlug);
//       });
//     }
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       // ⚠️ Đã bỏ CustomScrollView ở đây để tránh lỗi logic cuộn
//
//       body: CustomScrollView(
//         slivers: [
//           // AppBar tĩnh (không ẩn hiện)
//           SliverAppBar(
//             pinned: true,
//             title: const Text('Bài báo chi tiết'),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//
//           // 3. Body: Chứa nội dung chính
//           SliverToBoxAdapter(
//             child: _buildBody(context, state),
//           ),
//         ],
//       ),
//
//       // 4. Thanh Nút Nổi (Floating Bar)
//       bottomNavigationBar: _buildFloatingNavigationBar(context, ref),
//     );
//   }
//
//   // --- HÀM XÂY DỰNG THANH NÚT NỔI ---
//   Widget _buildFloatingNavigationBar(BuildContext context, WidgetRef ref) {
//     final surfaceColor = Theme.of(context).colorScheme.surface;
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return Container(
//       // Tạo hiệu ứng "viên thuốc nổi"
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       height: 60,
//       decoration: BoxDecoration(
//         color: surfaceColor.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 15,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           // Nút 1: Quay lại/Thoát
//           IconButton(
//             icon: const Icon(Icons.arrow_back),
//             color: primaryColor,
//             onPressed: () => Navigator.pop(context),
//           ),
//
//           // Nút 2: Chatbot AI (Nổi bật - FloatingActionButton)
//           FloatingActionButton.small(
//             heroTag: 'chatbot',
//             child: const Icon(Icons.smart_toy_outlined),
//             onPressed: () {
//               // Logic mở Chatbot AI
//             },
//           ),
//
//           // Nút 3: Comment (Icon Button)
//           IconButton(
//             icon: const Icon(Icons.chat_bubble_outline),
//             color: Colors.white70,
//             onPressed: () {
//               showModalBottomSheet(
//                 context: context,
//                 isScrollControlled: true,
//                 backgroundColor: Colors.transparent,
//                 builder: (context) => _CommentsBottomSheet(), // Gọi Comments Sheet
//               );
//             },
//           ),
//
//           // Nút 4: Lưu bài viết (Bookmark)
//           IconButton(
//             icon: const Icon(Icons.bookmark_border),
//             color: Colors.white70,
//             onPressed: () {
//               // Logic Lưu bài viết
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --- WIDGET NỘI DUNG CHÍNH ---
//   Widget _buildBody(BuildContext context, ArticleDetailState state) {
//     if (state is ArticleDetailLoading) {
//       return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
//     }
//     if (state is ArticleDetailError) {
//       return SizedBox(
//         height: 400,
//         child: Center(
//           child: Text('LỖI TẢI DỮ LIỆU.\nChi tiết: ${state.message}',
//               textAlign: TextAlign.center,
//               // Sử dụng primaryRed từ file style
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor)),
//         ),
//       );
//     }
//
//     if (state is ArticleDetailLoaded) {
//       final ArticleEntity article = state.article; // Lấy Entity
//
//       final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
//
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: <Widget>[
//             // 🎯 SỬA LỖI: Dùng article.imageUrl (Nếu Entity có)
//             if (article.imageUrl != null && article.imageUrl!.isNotEmpty) ...[
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(12),
//                 child: Image.network(
//                   article.imageUrl!, // Dùng imageUrl
//                   width: double.infinity,
//                   height: 250,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     height: 250,
//                     color: Colors.grey[900],
//                     child: const Icon(Icons.image_not_supported, color: Colors.grey),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],
//
//             // Tiêu đề
//             Text(article.title, style: Theme.of(context).textTheme.headlineMedium),
//             const SizedBox(height: 12),
//
//             // Tác giả và Ngày xuất bản
//             Row(
//               children: [
//                 const Icon(Icons.person, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 // 🎯 SỬA LỖI: Dùng article.authorName
//                 Text('Tác giả: ${article.authorName}', style: articleMetadataStyle),
//                 const SizedBox(width: 16),
//                 const Icon(Icons.access_time, size: 16, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Text(dateFormatter.format(article.publishedAt.toLocal()), style: articleMetadataStyle),
//               ],
//             ),
//             const Divider(height: 30, color: Colors.white12),
//
//             // Nội dung (🎯 Dùng article.content)
//             Text(
//               article.content,
//               style: Theme.of(context).textTheme.bodyLarge,
//               textAlign: TextAlign.justify,
//             ),
//             const SizedBox(height: 100),
//           ],
//         ),
//       );
//     }
//
//     return const SizedBox.shrink();
//   }
// }
//
// // --- WIDGET CHO PHẦN BÌNH LUẬN (BOTTOM SHEET) ---
// // Chuyển thành StatefulWidget để xử lý bàn phím an toàn
// class _CommentsBottomSheet extends StatefulWidget {
//   @override
//   State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
// }
//
// class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
//   // Dữ liệu giả
//   final comments = [
//     {'author': 'Minh Anh', 'content': 'Bài viết rất hay và chi tiết!'},
//     {'author': 'Bao Truong', 'content': 'Cảm ơn admin đã chia sẻ.'},
//     {'author': 'Hoang Phuc', 'content': 'Phú Quốc đẹp thật sự.'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     // Lấy màu nền từ theme
//     final inputBgColor = Theme.of(context).colorScheme.surface;
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return DraggableScrollableSheet(
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.9,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: inputBgColor, // Nền tối
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               // Thanh nắm kéo (handle)
//               Center(
//                 child: Container(
//                   width: 40,
//                   height: 4,
//                   margin: const EdgeInsets.symmetric(vertical: 12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[700],
//                     borderRadius: BorderRadius.circular(2),
//                   ),
//                 ),
//               ),
//
//               // Tiêu đề
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Text(
//                   'Bình luận (${comments.length})',
//                   style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
//                 ),
//               ),
//               const Divider(height: 1, color: Colors.white10),
//
//               // Danh sách bình luận
//               Expanded(
//                 child: ListView.separated(
//                   controller: scrollController,
//                   padding: const EdgeInsets.all(16),
//                   itemCount: comments.length,
//                   itemBuilder: (context, index) {
//                     final c = comments[index];
//                     return Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         CircleAvatar(
//                           radius: 16,
//                           backgroundColor: primaryColor,
//                           child: Text(c['author']![0], style: const TextStyle(color: Colors.white)),
//                         ),
//                         const SizedBox(width: 12),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(c['author']!, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
//                               const SizedBox(height: 4),
//                               Text(c['content']!, style: const TextStyle(color: Colors.white, fontSize: 14)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   },
//                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                 ),
//               ),
//
//               // Ô nhập liệu (Input field)
//               Container(
//                 // Điều chỉnh padding bottom để bàn phím không che mất input
//                 padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).scaffoldBackgroundColor,
//                   border: const Border(top: BorderSide(color: Colors.white10)),
//                 ),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         style: const TextStyle(color: Colors.white),
//                         decoration: InputDecoration(
//                           hintText: 'Viết bình luận...',
//                           hintStyle: TextStyle(color: Colors.grey[600]),
//                           filled: true,
//                           fillColor: Colors.grey[800],
//                           contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                           border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     CircleAvatar(
//                       backgroundColor: primaryColor,
//                       child: IconButton(
//                         icon: const Icon(Icons.send, size: 18, color: Colors.white),
//                         onPressed: () {},
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
//
// import '../../domain/entities/article_entity.dart';
// import '../article_style.dart';
// import '../notifier/article_detail_notifier.dart';
// import '../notifier/article_detail_state.dart';
//
// class ArticlePage extends ConsumerStatefulWidget {
//   final String articleSlug;
//   final ArticleEntity? article;
//
//   const ArticlePage({
//     Key? key,
//     this.article,
//     required this.articleSlug,
//   }) : super(key: key);
//
//   @override
//   ConsumerState<ArticlePage> createState() => _ArticlePageState();
// }
//
// class _ArticlePageState extends ConsumerState<ArticlePage> {
//   // Ảnh mặc định (Placeholder) khi bài báo không có ảnh
//   static const String defaultImage = "https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&q=80";
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.article == null) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(articleDetailNotifierProvider.notifier).loadArticle(widget.articleSlug);
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(articleDetailNotifierProvider);
//
//     ArticleEntity? displayArticle = widget.article;
//     bool isLoading = false;
//     String? errorMsg;
//
//     if (state is ArticleDetailLoaded) {
//       displayArticle = state.article;
//     } else if (widget.article == null && state is ArticleDetailLoading) {
//       isLoading = true;
//     } else if (state is ArticleDetailError) {
//       errorMsg = state.message;
//     }
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             title: const Text('Bài báo chi tiết'),
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: _buildBody(context, displayArticle, isLoading, errorMsg),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildFloatingNavigationBar(context),
//     );
//   }
//
//   Widget _buildBody(BuildContext context, ArticleEntity? article, bool isLoading, String? error) {
//     if (isLoading) {
//       return const SizedBox(height: 400, child: Center(child: CircularProgressIndicator()));
//     }
//
//     if (error != null) {
//       return SizedBox(
//         height: 400,
//         child: Center(child: Text('Lỗi: $error', style: TextStyle(color: Theme.of(context).primaryColor))),
//       );
//     }
//
//     if (article != null) {
//       final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');
//
//       // Logic chọn ảnh: Ưu tiên ảnh thật -> Nếu null dùng ảnh mặc định
//       final String imageUrl = (article.imageUrl != null && article.imageUrl!.isNotEmpty)
//           ? article.imageUrl!
//           : defaultImage;
//
//       return Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- PHẦN ẢNH BÀI BÁO (ĐÃ SỬA ĐỂ LUÔN HIỆN) ---
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 imageUrl,
//                 width: double.infinity,
//                 height: 250,
//                 fit: BoxFit.cover,
//                 // Xử lý khi link ảnh bị lỗi (404) -> Hiện ảnh mặc định
//                 errorBuilder: (context, error, stackTrace) => Image.network(
//                   defaultImage,
//                   width: double.infinity,
//                   height: 250,
//                   fit: BoxFit.cover,
//                 ),
//                 // Hiển thị loading khi đang tải ảnh
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) return child;
//                   return Container(
//                     height: 250,
//                     color: Colors.grey[900],
//                     child: const Center(child: CircularProgressIndicator()),
//                   );
//                 },
//               ),
//             ),
//             const SizedBox(height: 20),
//
//             // Category & Title
//             Text('TIN TỨC'.toUpperCase(), style: articleCategoryStyle),
//             const SizedBox(height: 8),
//             Text(article.title, style: Theme.of(context).textTheme.headlineMedium),
//             const SizedBox(height: 16),
//
//             //*(Cách này vừa sửa lỗi style, vừa hiển thị đúng Category thật từ bài báo thay vì chữ cứng 'TIN TỨC').*
//             // Info (Tác giả & Ngày)
//             Row(
//               children: [
//                 CircleAvatar(
//                   radius: 16,
//                   backgroundColor: Theme.of(context).primaryColor,
//                   child: Text(
//                       article.authorName.isNotEmpty ? article.authorName[0] : 'A',
//                       style: const TextStyle(color: Colors.white)
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(article.authorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                     Text(dateFormatter.format(article.publishedAt), style: articleMetadataStyle),
//                   ],
//                 ),
//               ],
//             ),
//             const Divider(height: 30, color: Colors.white12),
//
//             // Nội dung
//             Text(
//               article.content,
//               style: Theme.of(context).textTheme.bodyLarge,
//               textAlign: TextAlign.justify,
//             ),
//             const SizedBox(height: 100),
//           ],
//         ),
//       );
//     }
//     return const SizedBox.shrink();
//   }
//
//   // Widget Thanh Nổi
//   Widget _buildFloatingNavigationBar(BuildContext context) {
//     final surfaceColor = Theme.of(context).colorScheme.surface;
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       height: 60,
//       decoration: BoxDecoration(
//         color: surfaceColor.withOpacity(0.95),
//         borderRadius: BorderRadius.circular(30),
//         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           IconButton(icon: const Icon(Icons.arrow_back), color: primaryColor, onPressed: () => Navigator.pop(context)),
//           FloatingActionButton.small(
//             heroTag: 'chatbot',
//             backgroundColor: primaryColor,
//             child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
//             onPressed: () {},
//           ),
//           IconButton(
//               icon: const Icon(Icons.chat_bubble_outline),
//               color: Colors.white70,
//               onPressed: () {
//                 showModalBottomSheet(
//                   context: context,
//                   isScrollControlled: true,
//                   backgroundColor: Colors.transparent,
//                   builder: (context) => const _CommentsBottomSheet(),
//                 );
//               }
//           ),
//           IconButton(icon: const Icon(Icons.bookmark_border), color: Colors.white70, onPressed: () {}),
//         ],
//       ),
//     );
//   }
// }
//
// // Bottom Sheet Comment
// class _CommentsBottomSheet extends StatefulWidget {
//   const _CommentsBottomSheet();
//   @override
//   State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
// }
//
// class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
//   final comments = [
//     {'author': 'Minh Anh', 'content': 'Bài viết rất hay!'},
//     {'author': 'Bao Truong', 'content': 'Cảm ơn admin.'},
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final inputBgColor = Theme.of(context).colorScheme.surface;
//     final primaryColor = Theme.of(context).primaryColor;
//
//     return DraggableScrollableSheet(
//       initialChildSize: 0.6,
//       minChildSize: 0.4,
//       maxChildSize: 0.9,
//       builder: (context, scrollController) {
//         return Container(
//           decoration: BoxDecoration(
//             color: inputBgColor,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               Container(width: 40, height: 4, margin: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 12),
//                 child: Text('Bình luận', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//               ),
//               const Divider(height: 1, color: Colors.white10),
//               Expanded(
//                 child: ListView.builder(
//                   controller: scrollController,
//                   itemCount: comments.length,
//                   itemBuilder: (context, index) => ListTile(
//                     leading: CircleAvatar(backgroundColor: primaryColor, child: Text(comments[index]['author']![0], style: const TextStyle(color: Colors.white))),
//                     title: Text(comments[index]['author']!, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
//                     subtitle: Text(comments[index]['content']!, style: const TextStyle(color: Colors.white)),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

//chính
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Import các file cần thiết
import '../../domain/entities/article_entity.dart';
import '../article_style.dart'; // File style
import '../notifier/article_detail_notifier.dart';
import '../notifier/article_detail_state.dart';
import '../providers/article_list_provider.dart';

class ArticlePage extends ConsumerStatefulWidget {
  final String articleSlug;
  final ArticleEntity? article; // Nhận dữ liệu truyền sang

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

    // 2. 👇 LẤY DANH SÁCH TIN KHÁC TỪ PROVIDER CỦA BẠN
    // (Biến này chứa toàn bộ danh sách bài viết giống trang chủ)
    final relatedState = ref.watch(articleListProvider);

    ArticleEntity? displayArticle = widget.article;
    bool isLoading = false;
    String? errorMsg;

    // Logic ưu tiên dữ liệu mới nhất từ Provider
    if (state is ArticleDetailLoaded) {
      displayArticle = state.article;
    } else if (widget.article == null && state is ArticleDetailLoading) {
      isLoading = true;
    } else if (state is ArticleDetailError) {
      errorMsg = state.message;
    }

    // ============================================================
    // 👇 XỬ LÝ LỌC TIN LIÊN QUAN (MỚI THÊM)
    // ============================================================
    List<ArticleEntity> relatedArticles = [];

    // Kiểm tra kiểu dữ liệu trả về từ relatedState (AsyncValue hay State Class)
    if (relatedState is AsyncData<List<ArticleEntity>>) {
      // Trường hợp 1: Provider trả về AsyncValue (thường gặp)
      relatedArticles = relatedState.value;
    } else if (relatedState is List<ArticleEntity>) {
      // Trường hợp 2: Provider trả về List trực tiếp
      relatedArticles = relatedState as List<ArticleEntity>;
    } else {
      // Trường hợp 3: Provider trả về State Class (ArticleListLoaded...)
      // Dùng dynamic để tránh lỗi import nếu chưa có file state,
      // nhưng tốt nhất bạn nên import file article_list_state.dart và check:
      // if (relatedState is ArticleListLoaded) relatedArticles = relatedState.articles;
      try {
        final dynamic dynamicState = relatedState;
        if (dynamicState.articles is List<ArticleEntity>) {
          relatedArticles = dynamicState.articles;
        }
      } catch (e) {
        // Bỏ qua nếu không parse được
      }
    }

    // Lọc: Bỏ bài đang đọc & lấy 5 bài đầu
    if (displayArticle != null && relatedArticles.isNotEmpty) {
      relatedArticles = relatedArticles
          .where((item) => item.id != displayArticle!.id)
          .take(5)
          .toList();
    }
    // ============================================================

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
// ===============================================
          // 👇 PHẦN MỚI THÊM: DANH SÁCH TIN TỨC KHÁC
          // ===============================================

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

      // ✅ SỬA LỖI 1: Dùng 'imageUrl' thay vì 'image'
      // Logic chọn ảnh an toàn
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

            // Category (Màu đỏ)
            // Text('TIN TỨC', style: articleCategoryStyle),
            // const SizedBox(height: 8),
            // Category
            // Text(
            //   // Gọi thuộc tính .category, dùng toUpperCase() để viết hoa giống mẫu "TIN TỨC"
            //   (article.category ?? '').toUpperCase(),
            //   style: articleCategoryStyle,
            // ),
            Text(
              (article.category.isEmpty ? 'TIN TỨC' : article.category).toUpperCase(),
              style: articleCategoryStyle,
            ),
            const SizedBox(height: 8),
            // Category
            // Text(
            //   (article['category'] ?? '').toString().toUpperCase(),
            //   style: articleCategoryStyle,
            // ),
            // const SizedBox(height: 8),

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
            // ✅ SỬA LỖI 2: Dùng 'content' thay vì 'contentPlain'
            Text(
              article.content,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
            // const SizedBox(height: 100),
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const _CommentsBottomSheet(),
                );
              }
          ),

          // Nút Bookmark
          IconButton(icon: const Icon(Icons.bookmark_border), color: Colors.white70, onPressed: () {}),
        ],
      ),
    );
  }
}

// =================================================================
// 👇 WIDGET ITEM BÀI BÁO (ĐƯỢC THÊM VÀO ĐỂ TÁI SỬ DỤNG)
// =================================================================
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

// --- Bottom Sheet Comment (StatefulWidget để xử lý bàn phím tốt hơn) ---
class _CommentsBottomSheet extends StatefulWidget {
  const _CommentsBottomSheet();
  @override
  State<_CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<_CommentsBottomSheet> {
  // Dữ liệu giả định cho phần bình luận
  final comments = [
    {'author': 'Minh Anh', 'content': 'Bài viết rất hay!'},
    {'author': 'Bao Truong', 'content': 'Cảm ơn admin đã chia sẻ.'},
    {'author': 'Hoang Phuc', 'content': 'Thông tin rất hữu ích.'},
  ];

  @override
  Widget build(BuildContext context) {
    final inputBgColor = Theme.of(context).colorScheme.surface;
    final primaryColor = Theme.of(context).primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: inputBgColor, // Nền tối
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Thanh kéo (Handle)
              Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))
              ),

              // Tiêu đề
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('Bình luận (${comments.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const Divider(height: 1, color: Colors.white10),

              // Danh sách bình luận
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: comments.length,
                  itemBuilder: (context, index) => ListTile(
                    leading: CircleAvatar(
                        backgroundColor: primaryColor,
                        child: Text(comments[index]['author']![0], style: const TextStyle(color: Colors.white))
                    ),
                    title: Text(comments[index]['author']!, style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(comments[index]['content']!, style: const TextStyle(color: Colors.white70)),
                  ),
                ),
              ),

              // Ô nhập liệu (Input field)
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: const Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Viết bình luận...',
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.send, size: 18, color: Colors.white),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}