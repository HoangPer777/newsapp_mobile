import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart'; // FIX 1: Thêm import này để hết lỗi WidgetRef
import '../../data/models/user.dart';
import '../../../../core/config/env.dart';
import '../../presentation/providers/auth_provider.dart'; // FIX 2: Import provider để gọi được authProvider

class AuthService {
  // FIX 3: Khai báo biến _baseUrl bị thiếu
  static final String _baseUrl = '${Env.apiBase}/auth';

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
}