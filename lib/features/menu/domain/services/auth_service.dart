import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // FIX 1: Thêm import này để hết lỗi WidgetRef
import '../../data/models/user.dart';
import '../../../../core/config/env.dart';
import '../../presentation/providers/auth_provider.dart';// FIX 2: Import provider để gọi được authProvider
import 'package:http_parser/http_parser.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {

  static final String _baseUrl = '${Env.apiBase}/auth';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    // BẮT BUỘC dùng Web Client ID ở Giai đoạn 1
    serverClientId: '307674059153-9djp3m9qqief5t5q9reslqoddeo4abls.apps.googleusercontent.com',
  );

  static Future<void> signInWithGoogle(WidgetRef ref) async {
    try {
      // 1. Mở popup chọn tài khoản
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      // 2. Lấy idToken
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // 3. Gửi idToken lên Spring Boot
        final response = await http.post(
          Uri.parse('${Env.apiBase}/auth/google'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"idToken": idToken}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // 4. Lấy Profile và lưu vào Riverpod
          final user = await getMe(data['accessToken'], data['userId']);
          ref.read(authProvider.notifier).setAuth(data['accessToken'], user);
        }
        else {
          final body = jsonDecode(response.body);
          throw Exception(body['message'] ?? 'Google login failed');
        }
      }
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  static Future<String> uploadAvatar(String token, int uid, String filePath) async {
    var request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/upload-avatar?uid=$uid'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(
      'file',
      filePath,
      contentType: MediaType('image', 'jpeg'),
    ));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['avatarUrl']; // Trả về link ảnh mới
    } else {
      throw Exception('Upload ảnh thất bại');
    }
  }

  // 1. Gửi yêu cầu mã OTP
  static Future<void> forgotPassword(String email) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/forgot-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );
    if (res.statusCode != 200) {
      String msg = 'Email không tồn tại hoặc lỗi hệ thống';
      try {
        final body = jsonDecode(res.body);
        if (body['message'] != null) msg = body['message'];
      } catch (_) {}
      throw Exception(msg);
    }
  }

  // 2. Xác nhận mã và đặt mật khẩu mới
  static Future<void> resetPassword(String email, String token, String newPassword) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/reset-password'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "token": token,
        "newPassword": newPassword,
      }),
    );
    if (res.statusCode != 200) {
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Mã xác nhận không đúng hoặc đã hết hạn');
    }
  }

  static Future<void> loginAndFetchProfile(WidgetRef ref, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      String token = data['accessToken'];

      // Kiểm tra xem backend trả về userId hay id
      int uid = data['userId'] ?? data['id'];

      // Gọi tiếp API lấy profile đầy đủ
      UserModel user = await getMe(token, uid);

      // Lưu vào Riverpod Provider
      ref.read(authProvider.notifier).setAuth(token, user);
    } else {
      throw Exception('Đăng nhập thất bại');
    }
  }

  static Future<UserModel> getMe(String token, int uid) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/me?uid=$uid'),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Get user failed');
    }

    return UserModel.fromJson(jsonDecode(res.body));
  }

  static Future<UserModel> updateUser(
      String token,
      int uid,
      Map<String, dynamic> data,
      ) async {
    final res = await http.put(
      Uri.parse('$_baseUrl/update?uid=$uid'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (res.statusCode != 200) {
      throw Exception('Update failed');
    }

    return UserModel.fromJson(jsonDecode(res.body));
  }
  static Future<void> changePassword(
      String token,
      int uid,
      String oldPassword,
      String newPassword,
      ) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/change-password?uid=$uid'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "oldPassword": oldPassword,
        "newPassword": newPassword,
      }),
    );

    if (res.statusCode != 200) {
      // Parse lỗi từ backend nếu có, ví dụ: "Old password is incorrect"
      final body = jsonDecode(res.body);
      throw Exception(body['message'] ?? 'Đổi mật khẩu thất bại');
    }
  }
}