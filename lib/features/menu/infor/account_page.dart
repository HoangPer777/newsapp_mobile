import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E),
        elevation: 0,
        title: const Text(
          'Tài khoản',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 12),

          // ==== TIÊU ĐỀ "Tài khoản" ====
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Tài khoản',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),

          // ====== MỤC ======
          _item(
            icon: Icons.person_outline,
            text: "Sửa tài khoản",
            onTap: () => context.push('/account/edit'),
          ),

          _item(
            icon: Icons.star_border,
            text: "myVnE",
          ),

          const SizedBox(height: 16),

          // ==== TIÊU ĐỀ "Hoạt động" ====
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Hoạt động',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
          ),

          _item(icon: Icons.chat_bubble_outline, text: "Ý kiến của bạn"),
          _item(icon: Icons.bookmark_border, text: "Tin đã lưu"),
          _item(icon: Icons.history, text: "Tin đã xem"),

          const SizedBox(height: 16),

          // ==== Đăng xuất ====
          ListTile(
            tileColor: const Color(0xFF1B1C1E),
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return ListTile(
      tileColor: const Color(0xFF1B1C1E),
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
