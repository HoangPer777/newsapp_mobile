import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/dio_client.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<void> login(String email, String password) async {
    print('AuthRepository: login called with $email'); // DEBUG LOG
    try {
      print('AuthRepository: Sending POST request to /auth/login'); // DEBUG LOG
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      print('AuthRepository: Response received: ${response.statusCode}'); // DEBUG LOG

      final token = response.data['accessToken'];
      final role = response.data['role']; // Lấy role từ Backend trả về

      if (token != null) {
        print('AuthRepository: Token found, saving...'); // DEBUG LOG
        await _storage.write(key: 'access_token', value: token);
        if (role != null) {
          await _storage.write(key: 'role', value: role); // Lưu role vào storage
        }
      } else {
        print('AuthRepository: Token is null!'); // DEBUG LOG
      }
    } catch (e) {
      print('AuthRepository: Error during login: $e'); // DEBUG LOG
      rethrow;
    }
  }

  Future<void> register(String email, String password, String displayName) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'displayName': displayName,
      });

      final token = response.data['accessToken'];
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }
}
