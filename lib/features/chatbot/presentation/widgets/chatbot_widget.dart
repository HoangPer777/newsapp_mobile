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

  // Sửa List để lưu trữ dynamic, vì articles giờ là List<RelatedArticle>
  final List<Map<String, dynamic>> _messages = [
    {
      "role": "bot",
      "text": "Chào bạn! Tôi là trợ lý AI, tôi có thể giúp gì cho bạn ?",
      "articles": <RelatedArticle>[]
    }
  ];

  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({"role": "user", "text": text, "articles": <RelatedArticle>[]});
      _isTyping = true;
    });

    try {
      // Gọi service mới đã cập nhật
      final response = await _service.askQuestion(text, widget.articleId);

      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": response['answer'],
            "articles": response['articles'] // Lưu danh sách object bài báo vào đây
          });
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({
            "role": "bot",
            "text": "Đã xảy ra lỗi khi kết nối với AI.",
            "articles": <RelatedArticle>[]
          });
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isTyping = false);
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
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white12))),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Color(0xFFbb1819)),
                const SizedBox(width: 8),
                const Text("Chatbot Assistant",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white)),
                const Spacer(),
                IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),

          // Chat Area
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                final String botText = msg['text'] ?? "";
                final List<RelatedArticle> articles = msg['articles'] ?? [];

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      // Tin nhắn text
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isUser
                              ? const Color(0xFFbb1819)
                              : const Color(0xFF2A2C30),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(botText,
                            style: const TextStyle(color: Colors.white)),
                      ),

                      // Danh sách các bài báo liên quan (Action Chips)
                      if (!isUser && articles.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            children: articles.map((article) {
                              return ActionChip(
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                backgroundColor: const Color(0xFF1E2023),
                                side: const BorderSide(color: Colors.white12),
                                avatar: const Icon(Icons.link,
                                    size: 16, color: Colors.blueAccent),
                                label: Text(
                                  article.title,
                                  style: const TextStyle(
                                      color: Colors.blueAccent, fontSize: 12),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ArticlePage(
                                        articleSlug: article.id.toString(),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
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
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Chatbot đang trả lời...",
                      style: TextStyle(
                          fontStyle: FontStyle.italic, color: Colors.white54))),
            ),

          // Input Area
          Padding(
            padding: EdgeInsets.only(
                left: 16, right: 16, top: 8, bottom: bottomInset + 16),
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
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Colors.white24)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                          const BorderSide(color: Color(0xFFbb1819))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                    backgroundColor: const Color(0xFFbb1819),
                    child: IconButton(
                        icon: const Icon(Icons.send, color: Colors.white),
                        onPressed: _sendMessage)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}