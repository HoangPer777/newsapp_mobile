import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';

class MenuPage extends ConsumerWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    // Màu nền chính (Dark theme)
    const backgroundColor = Color(0xFF18191B);
    const itemColor = Colors.white;
    const subTextColor = Colors.grey;
    const dividerColor = Colors.white10; // Màu đường kẻ mờ

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false, // Tắt nút back mặc định
        title: Row(
          children: [
            // Logo chữ E màu hồng
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFA62D50), // Màu hồng đỏ của logo
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Text(
                "E",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif', // Font có chân cho giống
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Menu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          // ================= USER INFO =================
          InkWell(
            onTap: () {
              if (user == null) {
                context.push('/login');
              } else {
                context.push('/account');
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFA62D50),
                    child: Text(
                      (user?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Đăng nhập',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null
                              ? "Tin đã lưu, Ý kiến, Sửa tài khoản..."
                              : "Đăng nhập để sử dụng đầy đủ tính năng",
                          style: const TextStyle(
                            color: subTextColor,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: subTextColor),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: dividerColor),

          // ================= SYSTEM GROUP =================
          _MenuItem(
            icon: Icons.settings_outlined,
            text: "Cài đặt ứng dụng",
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.language, // Icon quả địa cầu
            text: "Phiên bản",
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.playlist_add_check, // Icon sắp xếp
            text: "Sắp xếp, ẩn chuyên mục",
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.access_time,
            text: "Xem sau",
            onTap: () {},
          ),
          _MenuItem(
            icon: Icons.widgets_outlined,
            text: "Tiện ích",
            onTap: () {},
          ),

          const SizedBox(height: 16),

          // ================= REGION (Tin theo khu vực) =================
          _SectionHeader(text: "Tin theo khu vực"),
          const Divider(height: 1, color: dividerColor),
          _MenuItem(text: "Hà Nội", onTap: () {}, hasIcon: false),
          _MenuItem(text: "TP Hồ Chí Minh", onTap: () {}, hasIcon: false),

          const SizedBox(height: 16),

          // ================= CATEGORIES (Chuyên mục) =================
          _SectionHeader(text: "Chuyên mục"),
          const Divider(height: 1, color: dividerColor),

          _MenuItem(text: "Trang chủ", onTap: () {}, hasIcon: false),
          _MenuItem(text: "Mới nhất", onTap: () {}, hasIcon: false),
          _MenuItem(text: "Đọc nhanh", onTap: () {}, hasIcon: false),
          _MenuItem(text: "myVnE", onTap: () {}, hasIcon: false),
          _MenuItem(text: "Xem nhiều", onTap: () {}, hasIcon: false),
          _MenuItem(text: "Bình luận nhiều", onTap: () {}, hasIcon: false),

          // Mục có nút "Mở rộng"
          _MenuItem(
            text: "Thời sự",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Thế giới",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Kinh doanh",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Khoa học công nghệ",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Góc nhìn",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Bất động sản",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Sức khỏe",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),
          _MenuItem(
            text: "Thể thao",
            onTap: () {},
            hasIcon: false,
            isExpandable: true,
          ),

          const SizedBox(height: 40), // Padding bottom
        ],
      ),
    );
  }
}

// Widget tiêu đề Section (Tin theo khu vực, Chuyên mục)
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

// Widget từng dòng menu item
class _MenuItem extends StatelessWidget {
  final String text;
  final IconData? icon;
  final bool hasIcon;
  final bool isExpandable;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.text,
    this.icon,
    this.hasIcon = true,
    this.isExpandable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Hiển thị Icon nếu có
                if (hasIcon && icon != null) ...[
                  Icon(icon, color: Colors.grey[400], size: 22),
                  const SizedBox(width: 16),
                ],

                // Text chính
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w500, // Regular/Medium
                    ),
                  ),
                ),

                // Trailing Widget (Nút mở rộng hoặc Mũi tên đơn giản)
                if (isExpandable)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Mở rộng",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.format_align_right, color: Colors.grey[500], size: 20), // Icon tượng trưng cho expand
                      const SizedBox(width: 8),
                      Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
                    ],
                  )
                else
                  Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
              ],
            ),
          ),
        ),
        // Đường kẻ ngăn cách mờ bên dưới mỗi item
        const Divider(height: 1, color: Colors.white10, indent: 16),
      ],
    );
  }
}