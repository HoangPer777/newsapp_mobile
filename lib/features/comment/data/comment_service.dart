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

  Future<bool> addComment(int articleId, String content) async {
    try {
      // 2. Lấy Token ra khỏi kho (Lúc đăng nhập lưu tên gì thì giờ lấy tên đó)
      String? token = await _storage.read(key: 'access_token');

      if (token == null) {
        print("Chưa có Token, vui lòng đăng nhập lại");
        return false;
      }

      // 3. Gửi Request có kẹp Token
      final res = await dio.post(
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

      return res.statusCode == 200 || res.statusCode == 201;
    } catch (e) {
      print("Lỗi thêm comment: $e");
      return false;
    }
  }
}