class Env {
  // Đọc từ --dart-define, fallback local emulator
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue:
        // 'http://172.20.10.3:8080', // chạy ipconfig trong terminal rồi lấy ip IPv4 Address. đảm bảo máy tính và điện thoại cùng 1 mạng
           'http://localhost:8080',
  );
}
