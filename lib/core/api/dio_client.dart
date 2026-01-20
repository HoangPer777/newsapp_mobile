// import 'package:dio/dio.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../config/env.dart';
//
// class DioClient {
//   DioClient._();
//   static final DioClient _i = DioClient._();
//   factory DioClient() => _i;
//
//   final _storage = const FlutterSecureStorage();
//
//   late final Dio dio = Dio(BaseOptions(
//     baseUrl: Env.apiBase,
//     connectTimeout: const Duration(seconds: 10),
//     receiveTimeout: const Duration(seconds: 20),
//     validateStatus: (status) => true, // <<==== THÊM DÒNG NÀY
//
//   ))
//   // 🎯 THÊM LOGINTERCEPTOR VÀO ĐÂY (Vị trí đầu tiên)
//     ..interceptors.add(LogInterceptor(
//       requestBody: true,    // In body yêu cầu
//       responseBody: true,   // In body phản hồi
//       requestHeader: true,  // In headers yêu cầu
//       error: true,          // In chi tiết lỗi
//     ))
//     ..interceptors.add(InterceptorsWrapper(
//       onRequest: (options, handler) async {
//         final token = await _storage.read(key: 'access_token');
//         if (token != null) options.headers['Authorization'] = 'Bearer $token';
//         return handler.next(options);
//       },
//       onError: (e, handler) async {
//         // Gợi ý chỗ refresh_token (tùy backend)
//         if (e.response?.statusCode == 401) {
//           // final newToken = await AuthRepository().refresh();
//           // if (newToken != null) { ... retry logic ... }
//         }
//         return handler.next(e);
//       },
//     ));
// }

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/env.dart';

class DioClient {
  // 1. Singleton Pattern (Chỉ tạo 1 instance duy nhất)
  DioClient._();
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;

  // 2. Storage để lưu Token
  final _storage = const FlutterSecureStorage();

  // 3. Khởi tạo Dio với cấu hình chuẩn
  late final Dio dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBase, // Lấy URL từ Env
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      responseType: ResponseType.json,
      // Cho phép tất cả status code dưới 500 đều được coi là thành công (tùy chọn)
      // validateStatus: (status) => status != null && status < 500,
    ),
  )..interceptors.addAll([
    // 4. Log Interceptor (In log ra console để debug)
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
    ),

    // 5. Auth Interceptor (Xử lý Token tự động)
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Lấy token từ bộ nhớ an toàn
        final token = await _storage.read(key: 'access_token');

        // Nếu có token, gắn vào Header Authorization
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Xử lý lỗi 401 (Unauthorized) - Token hết hạn
        if (e.response?.statusCode == 401) {
          // TODO: Gọi logic Refresh Token ở đây
          // Ví dụ:
          // 1. Gọi API refresh token
          // 2. Nếu thành công -> Lưu token mới -> Gửi lại request cũ (e.requestOptions)
          // 3. Nếu thất bại -> Đăng xuất (xóa token) -> Chuyển về màn hình Login
          print("Token hết hạn! Cần refresh token.");
        }
        return handler.next(e);
      },
    ),
  ]);
}