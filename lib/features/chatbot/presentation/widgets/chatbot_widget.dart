import 'package:flutter/material.dart';
import 'package:newsapp_mobile/features/chatbot/data/chatbot_service.dart';

class ChatbotWidget extends StatefulWidget {
  final int articleId;
  const ChatbotWidget({super.key, required this.articleId});

  @override
  State<ChatbotWidget> createState() => _ChatbotWidgetState();
}

class _ChatbotWidgetState extends State<ChatbotWidget> {
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _service = ChatbotService();
  
  // List of { "role": "user"|"bot", "text": "..." }
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Chào bạn! Tôi có thể giúp gì về bài báo này?"}
  ];
  
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    setState(() {
      _messages.add({"role": "user", "text": text});
      _isTyping = true;
    });

    try {
      final response = await _service.askQuestion(text, widget.articleId);
      final answer = response['answer'] ?? "Không có câu trả lời.";
      
      if (mounted) {
        setState(() {
          _messages.add({"role": "bot", "text": answer});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({"role": "bot", "text": "Lỗi: $e"});
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
    // viewInsets.bottom is the keyboard height
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8 + (bottomInset > 0 ? 0 : 0), 
      margin: EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
        color: Color(0xFF111214), // Dark Background
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)), // Dark border
            ),
            child: Row(
              children: [
                const Icon(Icons.smart_toy, color: Color(0xFFbb1819)), // Brand Red
                const SizedBox(width: 8),
                const Text("Chatbot Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.close, color: Colors.white70), onPressed: () => Navigator.pop(context)),
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
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFbb1819) : const Color(0xFF2A2C30), // User Red, Bot Dark Grey
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['text']!,
                      style: const TextStyle(color: Colors.white),
                    ),
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
                child: Text("Chatbot đang trả lời...", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.white54)),
              ),
            ),

          // Input Area
          Padding(
            padding: EdgeInsets.only(
              left: 16, 
              right: 16, 
              top: 8, 
              bottom: bottomInset + 16
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white), // White Input Text
                    textInputAction: TextInputAction.send, 
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Đặt câu hỏi...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E2023),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      // Borders
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Colors.white24), // Visible border when inactive
                      ),
                      focusedBorder: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(24),
                         borderSide: const BorderSide(color: Color(0xFFbb1819)), // Red border when focused
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFFbb1819),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
