import 'package:flutter/material.dart';
import 'package:newsapp_mobile/features/chatbot/presentation/widgets/chatbot_widget.dart';
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cho phép body đẩy lên khi bàn phím hiện ra
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Chatbot Assistant'),
        backgroundColor: const Color(0xFF111214),
      ),
      body: const ChatbotWidget(articleId: 0), // Gọi cái Widget xịn của Han vào đây
    );
  }
}
