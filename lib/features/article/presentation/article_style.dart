// // // lib/features/article/presentation/article_style.dart
// // import 'package:flutter/material.dart';
// //
// // // 1. Màu sắc cục bộ
// // const Color _primaryRed = Color(0xFFBB1819);
// //
// // // 2. Định nghĩa kiểu chữ (Ví dụ: Tiêu đề bài báo)
// // const TextStyle articleHeadlineStyle = TextStyle(
// //   fontSize: 24,
// //   fontWeight: FontWeight.bold,
// //   color: Colors.white,
// // );
// //
// // // 3. Định nghĩa kiểu chữ (Ví dụ: Nội dung bài báo)
// // const TextStyle articleBodyStyle = TextStyle(
// //   fontSize: 16,
// //   height: 1.5, // Tăng khoảng cách dòng
// //   color: Colors.white70,
// // );
// //
// // // 4. Cấu hình cho thanh nút nổi
// // const double bottomNavBarHeight = 60.0;
// // const double iconSize = 28.0;
// //
// // // Có thể tạo một hàm để trả về màu cần thiết cho trang này
// // Color getArticleAccentColor(BuildContext context) {
// //   // Trả về màu Primary đã được định nghĩa trong theme gốc
// //   return Theme.of(context).colorScheme.primary;
// // }
//
// import 'package:flutter/material.dart';
//
// // Định nghĩa màu Primary Red (#bb1819)
// const Color primaryRed = Color(0xFFBB1819);
// const Color darkBackground = Color(0xFF121212);
// const Color darkSurface = Color(0xFF1D1D1D); // Nền cho Bottom Bar/Cards
//
// // 1. Cấu hình Dark Theme (Có thể đặt trong main.dart hoặc đây)
// final newsAppDarkTheme = ThemeData(
//   brightness: Brightness.dark,
//   primaryColor: primaryRed,
//   scaffoldBackgroundColor: darkBackground, // Màu nền chính
//
//   // ColorScheme định nghĩa màu sắc cho toàn bộ ứng dụng
//   colorScheme: const ColorScheme.dark(
//     primary: primaryRed, // Màu nổi bật chính
//     secondary: primaryRed,
//     background: darkBackground,
//     surface: darkSurface, // Màu nền cho các thanh/card
//   ),
//
//   // Cấu hình AppBar
//   appBarTheme: const AppBarTheme(
//     backgroundColor: darkBackground,
//     foregroundColor: Colors.white,
//     elevation: 0, // Không đổ bóng
//   ),
//
//   // Cấu hình Text
//   textTheme: const TextTheme(
//     // Tiêu đề lớn
//     headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//     // Nội dung bài báo
//     bodyLarge: TextStyle(color: Colors.white70, fontSize: 16.0, height: 1.6),
//   ),
//
//   // Cấu hình Floating Action Buttons (cho thanh nút nổi)
//   floatingActionButtonTheme: const FloatingActionButtonThemeData(
//     backgroundColor: primaryRed,
//     foregroundColor: Colors.white,
//   ),
// );
//
// // 2. Kiểu chữ riêng cho trang chi tiết (nếu cần)
// const TextStyle articleBodyStyle = TextStyle(
//   fontSize: 16.0,
//   height: 1.6,
//   color: Colors.white70,
//   fontFamily: 'Roboto', // Có thể dùng font khác nếu bạn muốn
// );
//
// const TextStyle articleMetadataStyle = TextStyle(
//   fontStyle: FontStyle.italic,
//   color: Colors.grey,
//   fontSize: 13,
// );

import 'package:flutter/material.dart';

// =======================================================
// 1. ĐỊNH NGHĨA MÀU SẮC (Color Palette)
// =======================================================
const Color primaryRed = Color(0xFFBB1819); // Màu đỏ chủ đạo
const Color darkBackground = Color(0xFF121212); // Nền đen (Scaffold)
const Color darkSurface = Color(0xFF1E1E1E); // Nền xám tối (Card/Sheet)

// =======================================================
// 2. CẤU HÌNH THEME (Dark Mode)
// =======================================================
final newsAppDarkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: primaryRed,
  scaffoldBackgroundColor: darkBackground,

  // Định nghĩa bảng màu toàn cục
  colorScheme: const ColorScheme.dark(
    primary: primaryRed,
    secondary: primaryRed,
    surface: darkSurface,
    background: darkBackground,
    onSurface: Colors.white,
  ),

  // Cấu hình AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    foregroundColor: Colors.white,
    elevation: 0, // Phẳng, không đổ bóng
    centerTitle: true,
  ),

  // Cấu hình Font chữ mặc định cho Theme
  textTheme: const TextTheme(
    // Dùng cho tiêu đề bài báo lớn
    headlineMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 22,
      height: 1.3,
    ),
    // Dùng cho nội dung bài báo
    bodyLarge: TextStyle(
      color: Colors.white70,
      fontSize: 16.0,
      height: 1.6,
    ),
  ),

  // Cấu hình nút nổi (Floating Action Button)
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryRed,
    foregroundColor: Colors.white,
  ),
);

// =======================================================
// 3. CÁC STYLE RIÊNG LẺ (Custom TextStyles)
// =======================================================

// Style cho nội dung chi tiết bài báo
const TextStyle articleBodyStyle = TextStyle(
  fontSize: 16.5,
  height: 1.6, // Khoảng cách dòng thoáng dễ đọc
  color: Colors.white70, // Màu trắng hơi xám dịu mắt
  fontFamily: 'Roboto',
);

// Style cho thông tin Metadata (Ngày giờ, Tác giả phụ)
const TextStyle articleMetadataStyle = TextStyle(
  fontStyle: FontStyle.italic,
  color: Colors.grey,
  fontSize: 13,
);

// Style cho Category (Thẻ loại tin tức) - MÀU ĐỎ
const TextStyle articleCategoryStyle = TextStyle(
  color: primaryRed,
  fontWeight: FontWeight.w800, // Rất đậm
  fontSize: 14,
  letterSpacing: 1.0, // Giãn chữ
  // Đã xóa dòng uppercase: true gây lỗi
);