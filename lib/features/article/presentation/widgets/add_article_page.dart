import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/add_article_provider.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/article_list_provider.dart';

class AddArticlePage extends ConsumerStatefulWidget {
  const AddArticlePage({super.key});

  @override
  ConsumerState<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends ConsumerState<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _authorController = TextEditingController();
  final _categoryController = TextEditingController();

  void _onPublish() async {
    if (_formKey.currentState!.validate()) {
      final article = ArticleEntity(
        title: _titleController.text,
        content: _contentController.text,
        imageUrl: _imageUrlController.text,
        authorName: _authorController.text,
        category: _categoryController.text.trim(),
        // category: "Thời sự", // Han có thể thêm dropdown chọn category sau
      );

      await ref.read(addArticleProvider.notifier).createArticle(article);

      final state = ref.read(addArticleProvider);
      if (!state.hasError && mounted) {
        // THÊM DÒNG NÀY: Làm mới danh sách bài báo ở trang chủ
        ref.invalidate(articleListProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng bài báo thành công!'), backgroundColor: Colors.green),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe lỗi để hiển thị SnackBar
    ref.listen<AsyncValue<void>>(addArticleProvider, (_, next) {
      next.whenOrNull(error: (err, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $err'), backgroundColor: Colors.red),
        );
      });
    });

    final isLoading = ref.watch(addArticleProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF111214), // Màu tối đồng bộ
      appBar: AppBar(
        backgroundColor: const Color(0xFF111214),
        title: const Text('Thêm bài viết', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildFieldLabel('Tiêu đề'),
              _buildTextField(_titleController, 'Nhập tiêu đề bài báo...'),

              const SizedBox(height: 20),
              Row(
                children: [
                  // Ô nhập Tác giả
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Tác giả'),
                        _buildTextField(_authorController, 'Tên tác giả...'),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Ô nhập Chuyên mục
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Chuyên mục'),
                        _buildTextField(_categoryController, 'VD: Thời sự, Kinh doanh...'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildFieldLabel('URL Hình ảnh'),
              _buildTextField(_imageUrlController, 'Dán link ảnh tại đây...'),
              const SizedBox(height: 20),
              _buildFieldLabel('Nội dung'),
              _buildTextField(_contentController, 'Nhập nội dung chi tiết...', maxLines: 8),
              const SizedBox(height: 40),
              _buildSubmitButton(isLoading),
            ],
          ),
        ),
      ),
    );
  }

  // Các Widget bổ trợ (Label, Input, Button) giống style Han đã dùng ở trang Login
  Widget _buildFieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
  );

  Widget _buildTextField(TextEditingController controller, String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (v) => (v == null || v.isEmpty) ? 'Không được bỏ trống' : null,
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onPublish,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBB1819), // Màu đỏ đặc trưng
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('ĐĂNG BÀI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}