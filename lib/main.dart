import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/article/presentation/article_style.dart';
import 'app.dart';

void main() {
  // Đảm bảo Binding được khởi tạo trước khi gọi native code (nếu có)
  WidgetsFlutterBinding.ensureInitialized();

  // 3. BẮT BUỘC: Bọc toàn bộ ứng dụng trong ProviderScope
  // Nếu thiếu dòng này, Riverpod sẽ báo lỗi "No ProviderScope found"
  runApp(const ProviderScope(child: NewsApp()));
}