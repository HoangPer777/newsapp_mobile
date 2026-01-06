import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp_mobile/core/config/env.dart';

// 1. Tạo Model để quản lý dữ liệu bài báo liên quan
class RelatedArticle {
  final int id;
  final String title;
  final String link;
  final double score;

  RelatedArticle({
    required this.id,
    required this.title,
    required this.link,
    required this.score
  });

  // Chuyển đổi từ JSON của Python sang Object Flutter
  factory RelatedArticle.fromJson(Map<String, dynamic> json) {
    return RelatedArticle(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Bài viết liên quan',
      link: json['link'] ?? '',
      // Xử lý an toàn cho kiểu số thực (tránh lỗi nếu server trả về int)
      score: (json['score'] ?? 0.0).toDouble(),
    );
  }
}

class ChatbotService {
  final String _baseUrl = Env.chatbotApiBase;

  // 1. Semantic Search (Giữ nguyên hoặc tùy chỉnh theo ý Han)
  // Future<List<dynamic>> searchArticles(String query, {int limit = 5}) async {
  Future<dynamic> searchArticles(String query, {int limit = 5}) async {
    final url = Uri.parse('$_baseUrl/search');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'limit': limit}),
      );
      print("DEBUG Service: Status Code = ${response.statusCode}");
      if (response.statusCode == 200) {
        // Decode tiếng Việt và ép kiểu sang Map
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Trả về toàn bộ data (bao gồm cả key 'results')
        // để SearchPage dùng containsKey('results') không bị lỗi
        return data;
      } else {
        print('Search failed with status: ${response.statusCode}');
        return {'results': []}; // Trả về cấu trúc rỗng thay vì ném lỗi để app không crash
      }
    } catch (e) {
      print('ChatbotService Search Error: $e');
      return {'results': []}; // Trả về cấu trúc mặc định để không crash
    }
  }

  // 2. Q&A (Cập nhật để trả về List<RelatedArticle>)
  Future<Map<String, dynamic>> askQuestion(String question, int? articleId) async {
    final url = Uri.parse('$_baseUrl/qa');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          // Nếu articleId là 0 (mặc định trang chat tổng), gửi null để RAG tìm toàn bộ
          'articleId': articleId == 0 ? null : articleId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        // Chuyển đổi danh sách bài báo từ JSON sang List<RelatedArticle>
        List<RelatedArticle> articles = [];
        if (data['related_articles'] != null) {
          articles = (data['related_articles'] as List)
              .map((item) => RelatedArticle.fromJson(item))
              .toList();
        }

        return {
          'answer': data['answer'] ?? "Không có câu trả lời.",
          'articles': articles, // Trả về danh sách object xịn cho Widget
        };
      } else {
        throw Exception('QA failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatbotService QA Error: $e');
      return {
        'answer': 'Lỗi kết nối đến Chatbot: $e',
        'articles': <RelatedArticle>[] // Trả về mảng rỗng để UI không bị crash
      };
    }
  }
}