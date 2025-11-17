import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';

class DioClient {
  DioClient._();
  static final DioClient _i = DioClient._();
  factory DioClient() => _i;

  final _storage = const FlutterSecureStorage();

  late final Dio dio = Dio(BaseOptions(
    baseUrl: Env.apiBase,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    validateStatus: (status) => true, // <<==== THÊM DÒNG NÀY

  ))
  // 🎯 THÊM LOGINTERCEPTOR VÀO ĐÂY (Vị trí đầu tiên)
    ..interceptors.add(LogInterceptor(
      requestBody: true,    // In body yêu cầu
      responseBody: true,   // In body phản hồi
      requestHeader: true,  // In headers yêu cầu
      error: true,          // In chi tiết lỗi
    ))
    ..interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        return handler.next(options);
      },
      onError: (e, handler) async {
        // Gợi ý chỗ refresh_token (tùy backend)
        if (e.response?.statusCode == 401) {
          // final newToken = await AuthRepository().refresh();
          // if (newToken != null) { ... retry logic ... }
        }
        return handler.next(e);
      },
    ));
}