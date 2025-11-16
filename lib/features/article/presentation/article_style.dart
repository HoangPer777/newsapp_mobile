// // lib/features/article/presentation/article_style.dart
// import 'package:flutter/material.dart';
//
// // 1. Màu sắc cục bộ
// const Color _primaryRed = Color(0xFFBB1819);
//
// // 2. Định nghĩa kiểu chữ (Ví dụ: Tiêu đề bài báo)
// const TextStyle articleHeadlineStyle = TextStyle(
//   fontSize: 24,
//   fontWeight: FontWeight.bold,
//   color: Colors.white,
// );
//
// // 3. Định nghĩa kiểu chữ (Ví dụ: Nội dung bài báo)
// const TextStyle articleBodyStyle = TextStyle(
//   fontSize: 16,
//   height: 1.5, // Tăng khoảng cách dòng
//   color: Colors.white70,
// );
//
// // 4. Cấu hình cho thanh nút nổi
// const double bottomNavBarHeight = 60.0;
// const double iconSize = 28.0;
//
// // Có thể tạo một hàm để trả về màu cần thiết cho trang này
// Color getArticleAccentColor(BuildContext context) {
//   // Trả về màu Primary đã được định nghĩa trong theme gốc
//   return Theme.of(context).colorScheme.primary;
// }

import 'package:flutter/material.dart';

// Định nghĩa màu Primary Red (#bb1819)
const Color primaryRed = Color(0xFFBB1819);
const Color darkBackground = Color(0xFF121212);
const Color darkSurface = Color(0xFF1D1D1D); // Nền cho Bottom Bar/Cards

// 1. Cấu hình Dark Theme (Có thể đặt trong main.dart hoặc đây)
final newsAppDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryRed,
  scaffoldBackgroundColor: darkBackground, // Màu nền chính

  // ColorScheme định nghĩa màu sắc cho toàn bộ ứng dụng
  colorScheme: const ColorScheme.dark(
    primary: primaryRed, // Màu nổi bật chính
    secondary: primaryRed,
    background: darkBackground,
    surface: darkSurface, // Màu nền cho các thanh/card
  ),

  // Cấu hình AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    foregroundColor: Colors.white,
    elevation: 0, // Không đổ bóng
  ),

  // Cấu hình Text
  textTheme: const TextTheme(
    // Tiêu đề lớn
    headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    // Nội dung bài báo
    bodyLarge: TextStyle(color: Colors.white70, fontSize: 16.0, height: 1.6),
  ),

  // Cấu hình Floating Action Buttons (cho thanh nút nổi)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryRed,
    foregroundColor: Colors.white,
  ),
);

// 2. Kiểu chữ riêng cho trang chi tiết (nếu cần)
const TextStyle articleBodyStyle = TextStyle(
  fontSize: 16.0,
  height: 1.6,
  color: Colors.white70,
  fontFamily: 'Roboto', // Có thể dùng font khác nếu bạn muốn
);

const TextStyle articleMetadataStyle = TextStyle(
  fontStyle: FontStyle.italic,
  color: Colors.grey,
  fontSize: 13,
);