import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Cần thiết để dùng ref
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/di/providers.dart';
import '../data/auth_repository.dart';

class LoginPage extends ConsumerStatefulWidget { // Đổi để dùng được Riverpod
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();
  final _authRepository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // PHẦN XỬ LÝ LOGIC MỚI
  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _authRepository.login(
          _emailController.text.trim(), // Thêm trim() để tránh lỗi cách trắng
          _passwordController.text,
        );

        // QUAN TRỌNG: Cập nhật lại Role để hiện dấu cộng (+)
        ref.invalidate(userRoleProvider);

        if (mounted) {
          context.go('/');
        }
      } on DioException catch (e) {
        String errorMessage = 'Đăng nhập thất bại';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _handleSocialLogin(String provider) {
    print('Login with $provider');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111214),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        leadingWidth: 56,
        title: _buildLogo(),
        centerTitle: true,
        actions: [const SizedBox(width: 56)],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Center(child: _buildTitleWithLink()),
                const SizedBox(height: 40),
                const Text('Email', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildEmailField(),
                const SizedBox(height: 24),
                const Text('Mật khẩu', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                _buildPasswordField(),
                const SizedBox(height: 32),
                _buildContinueButton(),
                const SizedBox(height: 24),
                _buildSeparator(),
                const SizedBox(height: 24),
                _buildSocialLoginButton(
                  icon: Icons.phone_iphone,
                  label: 'Đăng nhập bằng Apple ID',
                  onTap: () => _handleSocialLogin('Apple'),
                ),
                const SizedBox(height: 12),
                _buildSocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: 'Đăng nhập bằng Google',
                  onTap: () => _handleSocialLogin('Google'),
                ),
                const SizedBox(height: 40),
                _buildTermsText(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Các Widget phụ
  Widget _buildTitleWithLink() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        children: [
          const TextSpan(text: 'Đăng nhập / '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => context.push('/register'),
              child: const Text('Tạo tài khoản', style: TextStyle(color: Color(0xFFBB1819), fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/logo_VNXnews.png', height: 26, width: 26),
        const SizedBox(width: 6),
        const Text('Vnx news', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: _emailController,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: 'Nhập địa chỉ email của bạn',
          hintStyle: TextStyle(color: Colors.white54),
          prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
        validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nhập mật khẩu của bạn',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white70),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
        validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu quá ngắn' : null,
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBB1819), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Tiếp tục', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(children: [
      Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
      const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('hoặc', style: TextStyle(color: Colors.white70))),
      Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
    ]);
  }

  Widget _buildSocialLoginButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E), side: BorderSide.none, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: Colors.white), const SizedBox(width: 12), Text(label, style: const TextStyle(color: Colors.white))]),
      ),
    );
  }

  Widget _buildTermsText() {
    return const Text('Khi tiếp tục, bạn đồng ý với điều khoản sử dụng và chính sách bảo mật của VnExpress.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12));
  }
}