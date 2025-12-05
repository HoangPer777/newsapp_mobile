import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../data/auth_repository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  Future<void> _handleContinue() async {
    print('Login button pressed'); // DEBUG LOG
    if (_formKey.currentState!.validate()) {
      print('Form is valid, starting login...'); // DEBUG LOG
      setState(() => _isLoading = true);
      try {
        print('Calling AuthRepository.login...'); // DEBUG LOG
        await _authRepository.login(
          _emailController.text,
          _passwordController.text,
        );
        print('Login successful, navigating...'); // DEBUG LOG
        if (mounted) {
          context.go('/');
        }
      } on DioException catch (e) {
        print('DioException caught: ${e.message}'); // DEBUG LOG
        print('Response data: ${e.response?.data}'); // DEBUG LOG
        
        String errorMessage = 'Đăng nhập thất bại';
        if (e.response?.data is Map<String, dynamic>) {
          errorMessage = e.response?.data['message'] ?? errorMessage;
        } else if (e.response?.data is String) {
          // Nếu server trả về HTML (ví dụ: trang login wifi), hiển thị thông báo lỗi chung
          errorMessage = 'Lỗi kết nối: Server trả về dữ liệu không hợp lệ (có thể do mạng WiFi chặn).';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print('General Exception caught: $e'); // DEBUG LOG
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã có lỗi xảy ra: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        print('Login process finished'); // DEBUG LOG
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      print('Form validation failed'); // DEBUG LOG
    }
  }

  void _handleSocialLogin(String provider) {
    // TODO: Implement social login logic
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
        actions: [
          // Thêm một widget trống để cân bằng với leading button
          const SizedBox(width: 56),
        ],
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
                // Title with link
                Center(
                  child: _buildTitleWithLink(),
                ),
                const SizedBox(height: 40),
                // Email Label
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Email Input Field
                _buildEmailField(),
                const SizedBox(height: 24),
                // Password Label
                const Text(
                  'Mật khẩu',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Password Input Field
                _buildPasswordField(),
                const SizedBox(height: 32),
                // Continue Button
                _buildContinueButton(),
                const SizedBox(height: 24),
                // Separator
                _buildSeparator(),
                const SizedBox(height: 24),
                // Social Login Buttons
                _buildSocialLoginButton(
                  icon: Icons.phone_iphone,
                  label: 'Đăng nhập bằng Apple ID',
                  onTap: () => _handleSocialLogin('Apple'),
                  customIcon: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.phone_iphone,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSocialLoginButton(
                  icon: Icons.facebook,
                  label: 'Đăng nhập bằng Facebook',
                  onTap: () => _handleSocialLogin('Facebook'),
                  customIcon: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Text(
                      'f',
                      style: TextStyle(
                        color: Color(0xFF1877F2),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildSocialLoginButton(
                  icon: Icons.g_mobiledata,
                  label: 'Đăng nhập bằng Google',
                  onTap: () => _handleSocialLogin('Google'),
                  customIcon: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        color: Color(0xFF4285F4),
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Terms and Privacy Policy
                _buildTermsText(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleWithLink() {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        children: [
          const TextSpan(
            text: 'Đăng nhập / ',
          ),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () {
                context.push('/register');
              },
              child: const Text(
                'Tạo tài khoản',
                style: TextStyle(
                  color: Color(0xFFBB1819),
                  // decoration: TextDecoration.underline,
                  fontSize: 18,
                ),
              ),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.asset(
            'assets/images/logo_VNXnews.png',
            height: 26,
            width: 26,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Vnx news',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nhập địa chỉ email của bạn',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.email_outlined, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập email';
          }
          if (!value.contains('@')) {
            return 'Email không hợp lệ';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nhập mật khẩu của bạn',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.white70,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập mật khẩu';
          }
          if (value.length < 6) {
            return 'Mật khẩu phải có ít nhất 6 ký tự';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: _handleContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFBB1819),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Tiếp tục',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: const Text(
            'hoặc',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withOpacity(0.1),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? iconColor,
    Widget? customIcon,
  }) {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (customIcon != null)
              customIcon
            else
              Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 12,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'Khi tiếp tục, bạn đồng ý với '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to terms of use
                print('Terms of use');
              },
              child: const Text(
                'điều khoản sử dụng',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: ', '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                // TODO: Navigate to privacy policy
                print('Privacy policy');
              },
              child: const Text(
                'chính sách bảo mật',
                style: TextStyle(
                  color: Colors.white,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          const TextSpan(text: ' của VnExpress & được bảo vệ bởi reCAPTCHA.'),
        ],
      ),
    );
  }
}
