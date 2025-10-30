# News App FrontEnd (Flutter)

Ứng dụng di động Flutter để đọc tin tức (Android/iOS). Dự án Android đã cấu hình Java 21.

## Cách để pull về và chạy
1) Clone dự án:
```bash
git clone https://github.com/HoangPer777/newsapp_mobile.git
cd newsapp_mobile
```

2) Cài môi trường tối thiểu:
- Flutter SDK (khuyến nghị 3.24.x)
- Android SDK + platform-tools
- JDK 21 (đặt `JAVA_HOME` trỏ tới JDK 21)

3) Cấu hình flutter
- Cài đặt SDK: https://www.youtube.com/watch?v=UbMdjyXynbk
- Cài đặt Flutter & Plugin

4) Cài dependencies và chạy:
```bash
flutter pub get
flutter run
```

5) Kết nối với máy ảo và chạy

Ghi chú:
- Không commit tệp bí mật (ví dụ `android/app/google-services.json`, keystore). Nếu cần, mỗi người tự đặt file vào đúng vị trí trên máy của mình.
