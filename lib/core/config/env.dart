class Env {
  // Đọc từ --dart-define, fallback local emulator
  static const apiBase = String.fromEnvironment(
    'API_BASE',
    defaultValue:
        'http://10.0.2.2:8080',
  );
}
