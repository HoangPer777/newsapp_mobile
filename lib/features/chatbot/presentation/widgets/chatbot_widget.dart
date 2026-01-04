import 'package:flutter/material.dart';
import 'package:newsapp_mobile/features/chatbot/data/chatbot_service.dart';

import '../../../article/presentation/widgets/article_page.dart';

class ChatbotWidget extends StatefulWidget {
  final int articleId;
  const ChatbotWidget({super.key, required this.articleId});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _service = ChatbotService();

  // Sửa List để lưu được thêm thông tin article_id
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Chào bạn! Tôi có thể giúp gì cho bạn?", "article_id": ""}
  ];

  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({"role": "user", "text": text, "article_id": ""});
      _isTyping = true;
    });

    try {
      final response = await _service.askQuestion(text, widget.articleId);
      final answer = response['answer'] ?? "Không có câu trả lời.";

      // Lấy ID từ citations mà mình đã sửa ở Python (ví dụ: "article_id:33")
      final List citations = response['citations'] ?? [];
      String linkedId = "";
      if (citations.isNotEmpty) {
        String firstCitation = citations[0].toString();
        if (firstCitation.contains("article_id:")) {
          linkedId = firstCitation.split(":")[1].trim(); // Lấy số 33 ra
        }
      }

      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": answer,
            "article_id": linkedId // Lưu ID vào tin nhắn của bot
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "bot", "text": "Lỗi: $e", "article_id": ""});
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111214),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header (Giữ nguyên)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Color(0xFFbb1819)),
                const SizedBox(width: 8),
                const Text("Chatbot Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // Chat Area (Sửa để hiện Link)
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final hasLink = msg['article_id'] != null && msg['article_id']!.isNotEmpty;

                // ĐIỀU KIỆN
                // Lấy nội dung chữ ra một biến String trước
                final String botText = msg['text'] ?? "";
                final String articleId = msg['article_id'] ?? "";

                // Thực hiện kiểm tra trên biến String (botText)
                final bool shouldShowLink = !isUser &&
                    articleId.isNotEmpty &&
                    !botText.contains("Lỗi AI") && // Thêm để chặn lỗi 429
                    !botText.contains("429") &&
                    !botText.toLowerCase().contains("không tìm thấy");

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser ? const Color(0xFFbb1819) : const Color(0xFF2A2C30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // child: Text(msg['text']!, style: const TextStyle(color: Colors.white)),
                        child: Text(botText, style: const TextStyle(color: Colors.white)),
                      ),
                      // Hiển thị nút "Xem bài báo" nếu có article_id
                      // if (!isUser && hasLink)
                      if (shouldShowLink)
                        Padding(
                          padding: const EdgeInsets.only(left: 4, bottom: 8),
                          child: InkWell(
                            onTap: () {
                              // if (msg['article_id'] != null && msg['article_id']!.isNotEmpty) {
                              //   // 1. Lấy ID bài báo từ tin nhắn chatbot
                              //   final String id = msg['article_id']!;
                              //
                              //   // 2. Vì ArticlePage của Han yêu cầu 'articleSlug',
                              //   // Han hãy dùng chính cái ID này truyền vào tham số articleSlug.
                              //   // (Trong hệ thống của Han, slug và id có thể dùng thay thế cho nhau ở bước điều hướng)
                              //
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //       builder: (context) => ArticlePage(
                              //         articleSlug: id, // Han truyền ID vào đây nhé
                              //       ),
                              //     ),
                              //   );
                              // }
                              // 1. Kiểm tra xem AI có tìm thấy bài báo nào khác không (msg['article_id'])
                              // 2. Nếu có, đi tới bài đó. Nếu không, mới dùng bài hiện tại (widget.articleId)
                              final String destinationId = (msg['article_id'] != null && msg['article_id']!.isNotEmpty)
                                  ? msg['article_id']!
                                  : widget.articleId.toString();

                              print("Navigating to Article ID: $destinationId"); // Để Han theo dõi log

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticlePage(
                                    articleSlug: destinationId,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.link, size: 16, color: Colors.blueAccent),
                                const SizedBox(width: 4),
                                Text(
                                  "Xem bài báo #${msg['article_id']}",
                                  style: const TextStyle(color: Colors.blueAccent, fontSize: 12, decoration: TextDecoration.underline),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isTyping)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(alignment: Alignment.centerLeft, child: Text("Chatbot đang trả lời...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54))),
            ),

          // Input Area (Giữ nguyên)
          Padding(
            padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: bottomInset + 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Đặt câu hỏi...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E2023),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFbb1819))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(backgroundColor: const Color(0xFFbb1819), child: IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: _sendMessage)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}