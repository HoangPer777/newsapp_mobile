import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E),
        elevation: 0,
        title: const Text("Menu", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          // ============================
          // PHẦN USER INFO
          // ============================
          Container(
            color: const Color(0xFF2A2B2E),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.pink,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: const Text(
                "User",
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
              subtitle: const Text(
                "Tin đã lưu • Ý kiến • Sửa tài khoản",
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => context.push('/account'),
            ),
          ),

          const SizedBox(height: 10),

          // ============================
          // NHÓM: ỨNG DỤNG
          // ============================
          _sectionTitle("Ứng dụng"),
          _item(Icons.settings, "Cài đặt ứng dụng"),
          _item(Icons.watch_later_outlined, "Xem sau"),
          _item(Icons.list_alt_outlined, "Sắp xếp, ẩn chuyên mục"),

          const SizedBox(height: 10),

          // ============================
          // NHÓM: KHU VỰC
          // ============================
          _sectionTitle("Khu vực"),
          _item(Icons.location_on_outlined, "Hà Nội"),
          _item(Icons.location_city_outlined, "TP Hồ Chí Minh"),

          const SizedBox(height: 10),

          // ============================
          // NHÓM: CHUYÊN MỤC
          // ============================
          _sectionTitle("Chuyên mục"),
          _item(Icons.home_outlined, "Trang chủ", onTap: () => context.go('/')),
          _item(Icons.fiber_new, "Mới nhất"),
          _item(Icons.flash_on_outlined, "Đọc nhanh"),
        ],
      ),
    );
  }

  // ============================
  // WIDGET: TITLE NHÓM
  // ============================
  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6, top: 10),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ============================
  // WIDGET: ITEM MENU
  // ============================
  Widget _item(IconData icon, String text, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 22),
      title: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
