import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/dio_client.dart';

// Expose Dio for repositories
final dioProvider = Provider((ref) => DioClient().dio);

// Provider này sẽ đọc role từ storage mỗi khi app khởi động hoặc refresh
final userRoleProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'role'); // 'role' là key đã lưu lúc login
});