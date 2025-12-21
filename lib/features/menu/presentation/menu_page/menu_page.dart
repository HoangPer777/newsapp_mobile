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

    return Scaffold(
      backgroundColor: const Color(0xFF1B1C1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E),
        elevation: 0,
        title: const Text("Menu", style: TextStyle(color: Colors.white)),
      ),
      body: ListView(
        children: [
          // ================= USER INFO =================
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
              title: Text(
                user?.displayName ?? 'User',
                style: const TextStyle(color: Colors.white, fontSize: 17),
              ),
              subtitle: Text(
                user?.email ?? '',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              trailing:
              const Icon(Icons.chevron_right, color: Colors.grey),
              onTap: () => context.push('/account'),
            ),
          ),

          const SizedBox(height: 10),

          _sectionTitle("Ứng dụng"),
          _item(Icons.settings, "Cài đặt ứng dụng"),
          _item(Icons.watch_later_outlined, "Xem sau"),
          _item(Icons.list_alt_outlined, "Sắp xếp, ẩn chuyên mục"),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
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

  Widget _item(IconData icon, String text, {VoidCallback? onTap}) =>
      ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(text,
            style:
            const TextStyle(color: Colors.white, fontSize: 16)),
        trailing:
        const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      );
}
