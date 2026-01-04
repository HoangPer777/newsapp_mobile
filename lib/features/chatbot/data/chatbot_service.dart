import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:newsapp_mobile/core/config/env.dart';

class ChatbotService {
  final String _baseUrl = Env.chatbotApiBase;

  // 1. Semantic Search
  Future<List<dynamic>> searchArticles(String query, {int limit = 5}) async {
    final url = Uri.parse('$_baseUrl/search/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query, 'limit': limit}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        // Server returns { "results": [ ... ] }
        return data['results'] ?? [];
      } else {
        throw Exception('Search failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatbotService Search Error: $e');
      rethrow;
    }
  }

  // 2. Q&A (Ask Chatbot)
  Future<Map<String, dynamic>> askQuestion(String question, int? articleId) async {
    final url = Uri.parse('$_baseUrl/qa');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': question,
          'articleId': articleId,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
        // Returns { "answer": "...", "citations": [...] }
      } else {
        throw Exception('QA failed: ${response.statusCode}');
      }
    } catch (e) {
      print('ChatbotService QA Error: $e');
      return {
        'answer': 'Lỗi kết nối đến Chatbot: $e',
        'citations': []
      };
    }
  }
}
