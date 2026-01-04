class Env {
  // Đọc từ --dart-define, fallback local emulator
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue:
<<<<<<< HEAD
        // 'http://172.20.10.3:8080', // chạy ipconfig trong terminal rồi lấy ip IPv4 Address. đảm bảo máy tính và điện thoại cùng 1 mạng
      // 'http://10.0.129.45:8080',
    'http://10.0.2.2:8080',
=======
        // 'http://172.20.10.3:8080', // iphone // chạy ipconfig trong terminal rồi lấy ip IPv4 Address. đảm bảo máy tính và điện thoại cùng 1 mạng
        'http://10.0.79.97:8080', // ktx
    // 'http://10.0.70.228:8080',

    // 'http://10.0.2.2:8080',
>>>>>>> a894ea0bbdad3a235128b06f194cb7a40ac1a71d
    // 'http://localhost:8080',
  );
  static const chatbotApiBase = String.fromEnvironment(
    'CHATBOT_API_BASE',
    defaultValue:
<<<<<<< HEAD
    // 'http://172.20.10.3:8000',
    // 'http://10.0.129.45:8000'
        'http://10.0.2.2:8080',

    // usage: same host as apiBase but port 8000 công nghệ
=======
        // 'http://172.20.10.3:8000',
        'http://10.0.79.97:8080',
    // 'http://10.0.70.228:8000'
    // usage: same host as apiBase but port 8000
>>>>>>> a894ea0bbdad3a235128b06f194cb7a40ac1a71d
  );
}

// Dev Mode:
// flutter run --dart-define=API_BASE=http://10.0.79.97:8080 --dart-define=CHATBOT_API_BASE=http://10.0.79.97:8000
//
// Production:
// flutter run --dart-define=API_BASE=http://146.190.87.167:8080 --dart-define=CHATBOT_API_BASE=http://146.190.87.167:8000
