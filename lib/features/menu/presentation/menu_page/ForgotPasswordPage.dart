import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/services/auth_service.dart'; // Kiểm tra lại đường dẫn

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isCodeSent = false; // Trạng thái đã gửi mã hay chưa
  bool _isLoading = false;

  void _handleAction() async {
    setState(() => _isLoading = true);
    try {
      if (!_isCodeSent) {
        // BƯỚC 1: Gửi mã
        await AuthService.forgotPassword(_emailController.text.trim());
        setState(() => _isCodeSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mã OTP đã được gửi vào Email của bạn")),
        );
      } else {
        // BƯỚC 2: Reset mật khẩu
        await AuthService.resetPassword(
          _emailController.text.trim(),
          _otpController.text.trim(),
          _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi mật khẩu thành công! Hãy đăng nhập lại")),
        );
        context.go('/login'); // Quay lại trang đăng nhập
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      appBar: AppBar(title: const Text("Quên mật khẩu")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isCodeSent ? "Nhập mã xác nhận" : "Khôi phục mật khẩu",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              _isCodeSent
                  ? "Vui lòng kiểm tra mã OTP trong email của bạn."
                  : "Nhập email của bạn để nhận mã đặt lại mật khẩu.",
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),

            // Ô nhập Email (Vô hiệu hóa khi đã gửi mã)
            _buildTextField(
              controller: _emailController,
              hint: "Email",
              icon: Icons.email_outlined,
              enabled: !_isCodeSent,
            ),

            if (_isCodeSent) ...[
              const SizedBox(height: 16),
              // Ô nhập mã OTP
              _buildTextField(
                controller: _otpController,
                hint: "Mã OTP (6 số)",
                icon: Icons.lock_clock_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              // Ô nhập mật khẩu mới
              _buildTextField(
                controller: _passwordController,
                hint: "Mật khẩu mới",
                icon: Icons.lock_outline,
                isPassword: true,
              ),
            ],

            const SizedBox(height: 32),

            // Nút bấm chính
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBB1819),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(_isCodeSent ? "Xác nhận đổi mật khẩu" : "Gửi mã xác nhận",
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: enabled ? Colors.transparent : Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        enabled: enabled,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: Icon(icon, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}