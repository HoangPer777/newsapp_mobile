import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    // Màu sắc theo giao diện Dark Mode
    const backgroundColor = Color(0xFF18191B);
    const dividerColor = Colors.white10; // Màu đường kẻ mờ
    const iconColor = Colors.grey;
    const textColor = Colors.white;
    const subTextColor = Colors.grey;

    if (user == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
            'Tài khoản',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: dividerColor),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // ============ SECTION: TÀI KHOẢN ============
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Tài khoản',
              style: TextStyle(fontSize: 15, color: subTextColor),
            ),
          ),
          const Divider(height: 1, color: dividerColor),
          _buildItem(
            icon: Icons.perm_identity, // Icon người nét mảnh
            text: "Sửa tài khoản",
            onTap: () => context.push('/account/edit'),
          ),
          _buildItem(
            icon: Icons.star_border, // Icon ngôi sao
            text: "myVnE",
          ),

          const SizedBox(height: 24),

          // ============ SECTION: HOẠT ĐỘNG ============
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Hoạt động',
              style: TextStyle(fontSize: 15, color: subTextColor),
            ),
          ),
          const Divider(height: 1, color: dividerColor),
          _buildItem(
            icon: Icons.chat_bubble_outline, // Bong bóng chat hình chữ nhật
            text: "Ý kiến của bạn",
          ),
          _buildItem(
            icon: Icons.bookmark_border, // Icon bookmark
            text: "Tin đã lưu",
          ),
          _buildItem(
            icon: Icons.history, // Icon đồng hồ/lịch sử
            text: "Tin đã xem",
          ),

          const SizedBox(height: 24),

          // ============ SECTION: ĐĂNG XUẤT ============
          const Divider(height: 1, color: dividerColor),
          _buildItem(
            icon: Icons.logout, // Icon cánh cửa kèm mũi tên
            text: "Đăng xuất",
            // Trong ảnh gốc mục Đăng xuất màu giống các mục khác
            // Nếu muốn màu đỏ như cũ thì đổi color ở đây
            onTap: () {
              ref.read(authProvider.notifier).logout();
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }

  // Widget hiển thị từng dòng item kèm đường kẻ dưới
  Widget _buildItem({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          tileColor: const Color(0xFF18191B),
          leading: Icon(icon, color: Colors.grey[400], size: 26),
          title: Text(
              text,
              style: const TextStyle(color: Colors.white, fontSize: 16)
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
          onTap: onTap,
        ),
        // Đường kẻ ngăn cách phía dưới mỗi item
        const Divider(height: 1, color: Colors.white10, indent: 16),
      ],
    );
  }
}