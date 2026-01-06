import 'package:flutter/material.dart';
import '../data/comment_model.dart';
import '../data/comment_service.dart';
import 'package:go_router/go_router.dart';

class CommentPage extends StatefulWidget {
  final int articleId;
  final int? currentUserId;

  const CommentPage({
    super.key,
    required this.articleId,
    this.currentUserId,
  });

  @override
  State<CommentPage> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentPage> {
  final commentService = CommentService();
  final TextEditingController _controller = TextEditingController();

  List<Comment> comments = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadComments();
  }

  Future<void> loadComments() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final data = await commentService.getComments(widget.articleId);
      // Map dữ liệu JSON sang Model
      if (mounted) {
        setState(() {
          comments = data.map<Comment>((e) => Comment.fromJson(e)).toList(); //bl mới nhất lên đầu
        });
      }
    } catch (e) {
      debugPrint("Error load comments: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> sendComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // 1. Ẩn bàn phím trước cho gọn
    FocusManager.instance.primaryFocus?.unfocus();

    try {
      // 2. Gọi API
      await commentService.addComment(
        widget.articleId,
        text,
      );

      // --- NẾU CHẠY ĐẾN ĐÂY LÀ THÀNH CÔNG ---
      _controller.clear();
      await loadComments(); // Load lại danh sách

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã gửi bình luận!"), backgroundColor: Colors.green),
        );
      }

    } catch (e) {
    // --- HỨNG LỖI TẠI ĐÂY ---
    if (!mounted) return;

    // Kiểm tra các từ khóa liên quan đến quyền truy cập
    final errStr = e.toString().toLowerCase();
    if (errStr.contains("unauthorized") || errStr.contains("401") || errStr.contains("403")) {

      // --- DÙNG DIALOG THAY VÌ SNACKBAR ĐỂ CHẮC CHẮN HIỆN ---
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Yêu cầu đăng nhập"),
          content: const Text("Bạn chưa đăng nhập. Vui lòng đăng nhập để bình luận."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Đóng hộp thoại
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFbb1819)),
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                context.push('/login'); // Chuyển trang Login
              },
              child: const Text("Đăng nhập ngay"),
            ),
          ],
        ),
      );
      // -----------------------------------------------------

    } else {
      // Lỗi khác thì vẫn hiện SnackBar bình thường
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Không thể gửi: $e"), backgroundColor: Colors.red),
      );
    }
    }
  }
  //   // Kiểm tra login sơ bộ ở UI
  //   if (widget.currentUserId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Bạn cần đăng nhập để bình luận")),
  //     );
  //     return;
  //   }
  //
  //   // Gọi service
  //   final ok = await commentService.addComment(
  //     widget.articleId,
  //     text,
  //   );
  //
  //   if (ok) {
  //     _controller.clear();
  //     // Ẩn bàn phím
  //     FocusManager.instance.primaryFocus?.unfocus();
  //     // Load lại danh sách để hiện comment mới
  //     await loadComments();
  //   } else {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Lỗi gửi bình luận (Hết phiên đăng nhập?)")),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Thanh nắm kéo (Handle)
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(2)),
              ),

              // Tiêu đề
              Text(
                'Bình luận (${comments.length})',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Divider(color: Colors.white10),

              // Danh sách bình luận
              Expanded(
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : comments.isEmpty
                    ? const Center(child: Text("Chưa có bình luận nào", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                  controller: scrollController,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final c = comments[index];
                    // Lấy chữ cái đầu của tên
                    final firstLetter = c.authorName.isNotEmpty ? c.authorName[0].toUpperCase() : "?";

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor,
                        child: Text(
                          firstLetter,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(
                        c.authorName,
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        c.content,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  },
                ),
              ),

              // Ô nhập liệu
              Container(
                padding: EdgeInsets.fromLTRB(
                    16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 12),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.white10)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Viết bình luận...",
                          hintStyle: TextStyle(color: Colors.grey[600]),
                          filled: true,
                          fillColor: Colors.grey[800],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.send, size: 18),
                        onPressed: sendComment,
                        color: Colors.white,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}