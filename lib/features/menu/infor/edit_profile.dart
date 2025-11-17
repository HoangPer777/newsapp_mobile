import 'package:flutter/material.dart';

class EditAccountPage extends StatelessWidget {
  const EditAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền màu đen
      appBar: AppBar(
        title: Text(
          'Sửa tài khoản',
          style: TextStyle(color: Colors.white70), // chữ trắng mờ
        ),
        backgroundColor: Colors.black, // AppBar cùng nền đen
        elevation: 0, // bỏ bóng nếu muốn
        iconTheme: const IconThemeData(color: Colors.white70), // icon back màu trắng70
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.white24,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // nền nút đen
                  ),
                  child: const Text(
                    "Thay ảnh đại diện",
                    style: TextStyle(color: Colors.white70), // chữ trắng mờ
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text("Tài khoản", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          _infoTile(label: "Email", value: "xxxxxx@gmail.com"),
          _infoTile(label: "Mật khẩu", value: "*********"),
          _infoTile(label: "Số điện thoại", value: "Chưa có"),
          const SizedBox(height: 20),
          const Text("Thông tin cá nhân", style: TextStyle(color: Colors.white70)),
          _infoTile(label: "Họ và tên", value: "xxxx"),
          _infoTile(label: "Giới tính", value: "xxx"),
          _infoTile(label: "Địa điểm", value: "Chưa có"),
          const SizedBox(height: 30),
          TextButton(
            onPressed: () {},
            child: const Text(
              "Xóa tài khoản",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({required String label, required String value}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      subtitle: Text(value, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.edit, color: Colors.white70),
      onTap: () {},
    );
  }
}
