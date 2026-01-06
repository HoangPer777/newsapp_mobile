import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CommentService {
  final dio = Dio(BaseOptions(
    baseUrl: "http://10.0.2.2:8080/api",
    contentType: Headers.jsonContentType,
  ));

  // Khai báo kho lưu trữ để lấy Token
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> getComments(int articleId) async {
    final res = await dio.get("/comments/$articleId");
    return res.data;
  }
// Đổi từ Future<bool> thành Future<void>
  Future<void> addComment(int articleId, String content) async {
    try {
      // 2. Lấy Token ra khỏi kho (Lúc đăng nhập lưu tên gì thì giờ lấy tên đó)
      String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        throw Exception("Unauthorized");
        // print("Chưa có Token, vui lòng đăng nhập lại");
        // return false;
      }

      // 3. Gửi Request có kẹp Token
      // final res = await dio.post(
      await dio.post(
        "/comments", // Gửi vào /api/comments
        data: {
          "articleId": articleId, // Backend thường cần ID bài báo trong body
          "content": content,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      // Nếu thành công thì không làm gì cả (hàm void)

    } on DioException catch (e) {
      // 4. Nếu Server trả về lỗi 403 hoặc 401 (Token hết hạn/sai)
      if (e.response?.statusCode == 403 || e.response?.statusCode == 401) {
        throw Exception("Unauthorized");
      }
      // Các lỗi khác thì ném tiếp ra ngoài
      throw Exception("Lỗi kết nối: ${e.message}");
    //   return res.statusCode == 200 || res.statusCode == 201;
    // } catch (e) {
    //   print("Lỗi thêm comment: $e");
    //   return false;
    }
  }
}