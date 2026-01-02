class Env {
  // Đọc từ --dart-define, fallback local emulator
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue:
        // 'http://172.20.10.3:8080', // chạy ipconfig trong terminal rồi lấy ip IPv4 Address. đảm bảo máy tính và điện thoại cùng 1 mạng
        'http://10.0.129.45:8080',
    // 'http://10.0.2.2:8080',
    // 'http://localhost:8080',
  );
  static const chatbotApiBase = String.fromEnvironment('CHATBOT_API_BASE',
      defaultValue:
          // 'http://172.20.10.3:8000',
          'http://10.0.129.45:8000'
      // usage: same host as apiBase but port 8000
      );
}

// Dev Mode:
// flutter run --dart-define=API_BASE=http://10.0.129.45:8080 --dart-define=CHATBOT_API_BASE=http://10.0.129.45:8000
//
// Production:
// flutter run --dart-define=API_BASE=http://146.190.87.167:8080 --dart-define=CHATBOT_API_BASE=http://146.190.87.167:8000
