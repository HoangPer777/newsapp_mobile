import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../menu/data/models/user.dart'; // Đảm bảo đúng đường dẫn
import '../../../../core/config/env.dart';

class AuthRepository {
  // Định nghĩa storage để lưu token vào bộ nhớ máy
  final _storage = const FlutterSecureStorage();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: '${Env.apiBase}/auth',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // 1. Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Lưu token vào storage khi login thành công
        if (data['accessToken'] != null) {
          await _storage.write(key: 'access_token', value: data['accessToken']);
        }
        return data;
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  // 2. Lấy thông tin chi tiết User
  Future<UserModel> getMe(String token, int uid) async {
    try {
      final response = await _dio.get(
        '/me',
        queryParameters: {'uid': uid},
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Không thể lấy thông tin người dùng');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }

  // 3. Đăng ký (Đã sửa lỗi đường dẫn và storage)
  Future<Map<String, dynamic>> register(String email, String password, String displayName) async {
    try {
      // Vì baseUrl đã có /auth nên ở đây chỉ cần /register
      final response = await _dio.post('/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['accessToken'];
        if (token != null) {
          await _storage.write(key: 'access_token', value: token);
        }
        return data; // Trả về data để lấy userId sau này
      } else {
        throw Exception('Đăng ký thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  // 4. Đăng xuất
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'access_token');
    } catch (e) {
      print("Lỗi xóa token: $e");
    }
  }

  // 5. Hàm hỗ trợ lấy token đã lưu (dùng khi khởi động app)
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
}