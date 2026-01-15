import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// Đảm bảo đúng đường dẫn các file trong dự án của bạn
import '../../../../core/config/env.dart';
import '../../data/models/user.dart';
import '../../domain/services/auth_service.dart';
import '../providers/auth_provider.dart';

class EditAccountPage extends ConsumerStatefulWidget {
  const EditAccountPage({super.key});

  @override
  ConsumerState<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends ConsumerState<EditAccountPage> {
  final Color _bgApp = const Color(0xFF18191B);
  final Color _bgInput = const Color(0xFF2B2C30);
  final Color _textWhite = Colors.white;
  final Color _textGrey = const Color(0xFF9E9E9E);
  final Color _dividerColor = Colors.white10;

  // --- THÊM BIẾN PHỤC VỤ UPLOAD ---
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // --- THÊM HÀM LOGIC UPLOAD ---
  Future<void> _pickAndUploadImage() async {
    final auth = ref.read(authProvider);
    if (auth.token == null || auth.user == null) return;

    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() => _isUploading = true);
      try {
        // 1. Gọi API upload
        String newAvatarPath = await AuthService.uploadAvatar(
          auth.token!,
          auth.user!.id,
          image.path,
        );

        // 2. Cập nhật Model (Giữ nguyên các trường khác, chỉ đổi avatarUrl)
        final currentUser = auth.user!;
        final updatedUser = UserModel(
          id: currentUser.id,
          email: currentUser.email,
          displayName: currentUser.displayName,
          phone: currentUser.phone,
          gender: currentUser.gender,
          location: currentUser.location,
          avatarUrl: newAvatarPath,
        );

        // 3. Cập nhật Provider
        ref.read(authProvider.notifier).updateUser(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cập nhật ảnh đại diện thành công")),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi: ${e.toString()}"), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // --- LOGIC HIỂN THỊ URL ẢNH ---
    final String? fullAvatarUrl = (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
        ? (user.avatarUrl!.startsWith('http') ? user.avatarUrl : '${Env.apiBase}${user.avatarUrl}')
        : null;

    return Scaffold(
      backgroundColor: _bgApp,
      appBar: AppBar(
        backgroundColor: _bgApp,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text("Sửa tài khoản",
            style: TextStyle(color: Colors.white, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _dividerColor, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),

            // ============ CẬP NHẬT GIAO DIỆN AVATAR ============
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 45,
                  backgroundColor: const Color(0xFFA62D50),
                  backgroundImage: fullAvatarUrl != null ? NetworkImage(fullAvatarUrl) : null,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : (fullAvatarUrl == null
                      ? Text((user.displayName ?? "U").substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 40, color: Colors.white))
                      : null),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploading ? null : _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, color: Colors.black54, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _isUploading ? null : _pickAndUploadImage,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: _bgInput, borderRadius: BorderRadius.circular(4)),
                child: const Text(
                  "Thay ảnh đại diện",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),

            const SizedBox(height: 30),

            _buildSectionHeader("Tài khoản"),
            _buildItem(
              icon: Icons.email_outlined,
              label: "Email",
              value: user.email,
              isEditable: false,
            ),
            _buildItem(
              icon: Icons.lock_outline,
              label: "Mật khẩu",
              value: "••••••••",
              isEditable: true,
              onTap: () => _showChangePasswordModal(context, user.id),
            ),
            _buildItem(
              icon: Icons.phone_outlined,
              label: "Số điện thoại",
              value: user.phone ?? "Chưa có",
              isEditable: true,
              onTap: () => _showEditDialog(
                title: "Số điện thoại",
                currentValue: user.phone,
                onSave: (val) => _updateUserOnServer(phoneNumber: val),
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionHeader("Thông tin cá nhân"),
            _buildItem(
              icon: Icons.badge_outlined,
              label: "Họ và tên",
              value: user.displayName ?? "Chưa có",
              isEditable: true,
              onTap: () => _showEditDialog(
                title: "Họ và tên",
                currentValue: user.displayName,
                onSave: (val) => _updateUserOnServer(displayName: val),
              ),
            ),
            _buildItem(
              icon: Icons.wc,
              label: "Giới tính",
              value: user.gender ?? "Khác",
              isEditable: true,
              onTap: () => _showGenderSelectionDialog(
                currentValue: user.gender,
                onSave: (val) => _updateUserOnServer(gender: val),
              ),
            ),
            _buildItem(
              icon: Icons.location_on_outlined,
              label: "Địa điểm",
              value: user.location ?? "Chưa có",
              isEditable: true,
              onTap: () => _showEditDialog(
                title: "Địa điểm",
                currentValue: user.location,
                onSave: (val) => _updateUserOnServer(address: val),
              ),
            ),

            const SizedBox(height: 30),
            Text("VnExpress cam kết bảo mật thông tin của bạn.",
                style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Xóa tài khoản", style: TextStyle(color: Colors.red)),
              onTap: () {},
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _updateUserOnServer({String? displayName, String? phoneNumber, String? gender, String? address}) async {
    final authState = ref.read(authProvider);
    final user = authState.user;
    if (authState.token == null || user == null) return;
    try {
      final updatedUser = await AuthService.updateUser(authState.token!, user.id, {
        "displayName": displayName ?? user.displayName,
        "phoneNumber": phoneNumber ?? user.phone,
        "gender": gender ?? user.gender,
        "address": address ?? user.location,
      });
      ref.read(authProvider.notifier).updateUser(updatedUser);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lỗi: ${e.toString()}")));
    }
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 16),
      child: Text(title, style: TextStyle(color: _textGrey, fontSize: 14)),
    );
  }

  Widget _buildItem({required IconData icon, required String label, required String value, required bool isEditable, VoidCallback? onTap}) {
    return Column(
      children: [
        InkWell(
          onTap: isEditable ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: _textGrey, size: 24),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(value, style: const TextStyle(color: Colors.white70, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (isEditable) Icon(Icons.edit, color: Colors.grey[700], size: 18),
              ],
            ),
          ),
        ),
        Divider(height: 1, color: _dividerColor, indent: 56),
      ],
    );
  }

  void _showEditDialog({required String title, String? currentValue, required Function(String) onSave}) {
    final controller = TextEditingController(text: currentValue ?? "");
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _bgInput,
        title: Text("Sửa $title", style: TextStyle(color: _textWhite)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: _textWhite),
          autofocus: true,
          decoration: InputDecoration(enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: _textGrey))),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
          TextButton(onPressed: () { onSave(controller.text); Navigator.pop(ctx); }, child: const Text("Lưu")),
        ],
      ),
    );
  }

  void _showGenderSelectionDialog({String? currentValue, required Function(String) onSave}) {
    String selectedGender = (currentValue == "Nữ") ? "Nữ" : "Nam";
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSt) => AlertDialog(
          backgroundColor: _bgInput,
          title: const Text("Chọn giới tính"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(title: const Text("Nam"), value: "Nam", groupValue: selectedGender, onChanged: (v) => setSt(() => selectedGender = v.toString())),
              RadioListTile(title: const Text("Nữ"), value: "Nữ", groupValue: selectedGender, onChanged: (v) => setSt(() => selectedGender = v.toString())),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Hủy")),
            TextButton(onPressed: () { onSave(selectedGender); Navigator.pop(ctx); }, child: const Text("Lưu")),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordModal(BuildContext context, int userId) {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _bgApp,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Đổi mật khẩu",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(ctx),
                  )
                ],
              ),
              const SizedBox(height: 8),
              Text("Xác nhận bằng mật khẩu",
                  style: TextStyle(color: Colors.grey[500], fontSize: 14)),
              const SizedBox(height: 20),

              _buildPasswordInput(oldPassCtrl, "Mật khẩu cũ"),
              const SizedBox(height: 12),

              Text("Mật khẩu mới",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13)),
              const SizedBox(height: 8),
              _buildPasswordInput(newPassCtrl, "Mật khẩu mới"),
              const SizedBox(height: 12),
              _buildPasswordInput(confirmPassCtrl, "Xác nhận mật khẩu mới"),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3E3F43),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () async {
                    if (newPassCtrl.text != confirmPassCtrl.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mật khẩu mới không khớp")));
                      return;
                    }
                    if (oldPassCtrl.text.isEmpty || newPassCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Vui lòng nhập đầy đủ")));
                      return;
                    }

                    try {
                      await AuthService.changePassword(
                        ref.read(authProvider).token!,
                        userId,
                        oldPassCtrl.text,
                        newPassCtrl.text,
                      );
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đổi mật khẩu thành công")));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Lỗi: ${e.toString()}")));
                      }
                    }
                  },
                  child: const Text("Đổi mật khẩu",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                ),
              ),
              Center(
                child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text("Quên mật khẩu",
                        style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.underline))),
              )
            ],
          ),
        );
      },
    );
  }
  Widget _buildPasswordInput(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: _bgInput,
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon:
        const Icon(Icons.visibility_off_outlined, color: Colors.grey),
      ),
    );
  }
}