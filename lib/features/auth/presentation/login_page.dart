import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../data/auth_repository.dart';
import '../../menu/presentation/providers/auth_provider.dart';


class LoginPage extends ConsumerStatefulWidget {
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

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    // Dùng mã WEB Client ID (lấy từ Google Cloud Console)
    serverClientId: '782229500976-hnujerp4gbs3n41ib6vsarnt13pe3clt.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // BƯỚC 1: Login lấy Token và UID
        final loginData = await _authRepository.login(
          _emailController.text,
          _passwordController.text,
        );

        final String token = loginData['accessToken'];
        final int userId = loginData['userId'];

        // BƯỚC 2: Lấy Profile chi tiết
        final userModel = await _authRepository.getMe(token, userId);

        // BƯỚC 3: Cập nhật Provider toàn cục
        ref.read(authProvider.notifier).setAuth(token, userModel);

        if (mounted) {
          context.go('/'); // Về trang chủ
        }
      } on DioException catch (e) {
        String errorMessage = 'Đăng nhập thất bại';
        if (e.response?.data is Map) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
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
        title: _buildLogo(),
        centerTitle: true,
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
                const Text('Email', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                _buildEmailField(),
                const SizedBox(height: 24),
                const Text('Mật khẩu', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 8),
                _buildPasswordField(),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => context.push('/forgot-password'),
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: Color(0xFFBB1819), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _buildContinueButton(),
                const SizedBox(height: 24),
                _buildSeparator(),
                const SizedBox(height: 24),
                _buildSocialLoginButtons(),
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

  Widget _buildLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset('assets/images/logo_VNXnews.png', height: 26, width: 26, fit: BoxFit.cover),
        ),
        const SizedBox(width: 6),
        const Text('Vnx news', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
      ],
    );
  }

  Widget _buildTitleWithLink() {
    return RichText(
      text: TextSpan(
        text: '', // SỬA LỖI: Thêm text rỗng ở đây
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
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
          hintText: 'Nhập mật khẩu',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white70),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        validator: (v) => (v == null || v.length < 6) ? 'Mật khẩu tối thiểu 6 ký tự' : null,
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleContinue,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFBB1819), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Tiếp tục', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.white12)),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('hoặc', style: TextStyle(color: Colors.white54))),
        Expanded(child: Divider(color: Colors.white12)),
      ],
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        _socialButton(
          Icons.login, // Bạn có thể dùng icon Google tùy chỉnh nếu có
          'Đăng nhập bằng Google',
          onTap: () => _handleGoogleSignIn(), // Gọi hàm xử lý bên dưới
        ),
        const SizedBox(height: 12),
        _socialButton(
          Icons.facebook,
          'Đăng nhập bằng Facebook',
          color: const Color(0xFF1877F2),
          onTap: () {
            // Xử lý Facebook sau
          },
        ),
      ],
    );
  }

  Widget _socialButton(IconData icon, String label, {Color? color, VoidCallback? onTap}) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        backgroundColor: const Color(0xFF1E1E1E),
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color ?? Colors.white),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      // 1. Mở popup đăng nhập Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User hủy đăng nhập
        return;
      }

      // 2. Lấy thông tin Auth (idToken)
      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Không lấy được idToken từ Google');
      }

      // 3. Gọi API Backend qua Repository
      final loginData = await _authRepository.loginWithGoogle(idToken);

      final String token = loginData['accessToken'];
      // Kiểm tra userId, tùy backend trả về 'userId' hay 'id'
      final int userId = loginData['userId'] ?? loginData['id'];

      // 4. Lấy Profile chi tiết
      final userModel = await _authRepository.getMe(token, userId);

      // 5. Cập nhật Provider
      ref.read(authProvider.notifier).setAuth(token, userModel);

      if (mounted) {
        context.go('/'); // Đăng nhập thành công thì về trang chủ
      }

    } on DioException catch (e) {
      String errorMessage = 'Đăng nhập Google thất bại';
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Khi tiếp tục, bạn đồng ý với ', // SỬA LỖI: Thêm text ở đây
        style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
        children: const [
          TextSpan(text: 'điều khoản sử dụng', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
          TextSpan(text: ' và '),
          TextSpan(text: 'chính sách bảo mật', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
          TextSpan(text: ' của VNX.'),
        ],
      ),
    );
  }
}