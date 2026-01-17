import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../menu/data/models/user.dart';
import '../../../../core/api/dio_client.dart';

class AuthRepository {
  // Định nghĩa storage để lưu token vào bộ nhớ máy
  final _storage = const FlutterSecureStorage();
  late final Dio _dio;

  // Constructor
  AuthRepository({Dio? dio}) {
    _dio = dio ?? DioClient().dio;
  }

  // 1. Đăng nhập
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Lấy thông tin từ response
        final token = data['accessToken'];
        final role = data['role']; // Có thể null nếu backend chưa trả về

        // LƯU STORAGE
        if (token != null) {
          print('AuthRepository: Token found, saving...');
          await _storage.write(key: 'access_token', value: token);
        }

        if (role != null) {
          print('AuthRepository: Role found ($role), saving...');
          await _storage.write(key: 'role', value: role.toString());
        }

        // Trả về data để UI sử dụng (ví dụ lấy userId)
        return data;
      } else {
        throw Exception('Đăng nhập thất bại: ${response.statusMessage}');
      }
    } on DioException catch (e) {
      // Ném lỗi ra để UI (LoginPage) hiển thị thông báo đỏ
      rethrow;
    }
  }

  // 2. Lấy thông tin chi tiết User
  Future<UserModel> getMe(String token, int uid) async {
    try {
      final response = await _dio.get(
        '/auth/me',
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

  // 3. Đăng ký
  Future<Map<String, dynamic>> register(String email, String password, String displayName) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['accessToken'];

        // Tự động lưu token khi đăng ký thành công (đăng nhập luôn)
        if (token != null) {
          await _storage.write(key: 'access_token', value: token);
        }
        return data;
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
      await _storage.delete(key: 'role'); // Xóa luôn role cho sạch
    } catch (e) {
      print("Lỗi xóa token: $e");
    }
  }

  // 5. Hàm hỗ trợ lấy token đã lưu
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // 6. Đăng nhập bằng Google
  Future<Map<String, dynamic>> loginWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google',
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['accessToken'] != null) {
          await _storage.write(key: 'access_token', value: data['accessToken']);
        }
        return data;
      } else {
        throw Exception('Đăng nhập Google thất bại');
      }
    } on DioException catch (e) {
      rethrow;
    }
  }
}