# News App FrontEnd (Flutter)

Ứng dụng di động Flutter để đọc tin tức (Android/iOS). Dự án Android đã cấu hình Java 21.

## Cách để thành viên khác pull về và chạy
1) Clone dự án:
```bash
git clone <your-repo-url>
cd newsapp_mobile
```

2) Cài môi trường tối thiểu:
- Flutter SDK (khuyến nghị 3.24.x)
- Android SDK + platform-tools
- JDK 21 (đặt `JAVA_HOME` trỏ tới JDK 21)
- (Tùy chọn iOS) Xcode trên macOS

Kiểm tra:
```bash
flutter doctor -v
```

3) Cài dependencies và chạy:
```bash
flutter pub get
flutter run
```

4) Build APK (nếu cần):
```bash
flutter build apk --debug
# hoặc
flutter build apk --release
```

Ghi chú:
- Không commit tệp bí mật (ví dụ `android/app/google-services.json`, keystore). Nếu cần, mỗi người tự đặt file vào đúng vị trí trên máy của mình.
