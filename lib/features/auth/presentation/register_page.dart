import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleContinue() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement register logic
      print('Name: ${_nameController.text}');
      print('Email: ${_emailController.text}');
      print('Password: ${_passwordController.text}');
    }
  }

  void _handleSocialLogin(String provider) {
    // TODO: Implement social login logic
    print('Register with $provider');
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
                // Title with link
                _buildTitleWithLink(),
                const SizedBox(height: 40),
                // Full Name Label
                const Text(
                  'Họ và Tên',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Full Name Input Field
                _buildNameField(),
                const SizedBox(height: 24),
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
                  label: 'Đăng ký bằng Apple ID',
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
                  label: 'Đăng ký bằng Facebook',
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
                  label: 'Đăng ký bằng Google',
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
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        children: [
          const TextSpan(text: 'Tạo tài khoản / '),
          WidgetSpan(
            child: GestureDetector(
              onTap: () {
                context.push('/login');
              },
              child: const Text(
                'Đăng nhập',
                style: TextStyle(
                  color: Color(0xFFBB1819),
                  decoration: TextDecoration.underline,
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
            errorBuilder: (context, error, stackTrace) {
              // Fallback nếu không tìm thấy logo
              return Container(
                height: 26,
                width: 26,
                decoration: BoxDecoration(
                  color: const Color(0xFFBB1819),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Center(
                  child: Text(
                    'E',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'VNEXPRESS',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildNameField() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: _nameController,
        keyboardType: TextInputType.name,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Nhập họ và tên của bạn',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white70),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Vui lòng nhập họ và tên';
          }
          if (value.length < 2) {
            return 'Họ và tên phải có ít nhất 2 ký tự';
          }
          return null;
        },
      ),
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
              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
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
        child: const Text(
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

