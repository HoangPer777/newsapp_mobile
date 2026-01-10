import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../api/dio_client.dart';
import '../../features/article/domain/repositories/article_repository.dart';
import '../../features/article/data/repositories/article_repository_impl.dart';
import '../../features/article/data/datasources/article_remote_data_source.dart';
import '../../features/article/domain/services/article_service.dart';

// Expose Dio for repositories
final dioProvider = Provider((ref) => DioClient().dio);

// Provider này sẽ đọc role từ storage mỗi khi app khởi động hoặc refresh
final userRoleProvider = FutureProvider<String?>((ref) async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'role'); // 'role' là key đã lưu lúc login
});

final articleRemoteDataSourceProvider = Provider<ArticleRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ArticleRemoteDataSourceImpl(dio: dio);
});

final articleRepositoryProvider = Provider<ArticleRepository>((ref) {
  final remoteDataSource = ref.watch(articleRemoteDataSourceProvider);
  return ArticleRepositoryImpl(remoteDataSource: remoteDataSource);
});

final articleServiceProvider = Provider<ArticleService>((ref) {
  final articleRepository = ref.watch(articleRepositoryProvider);
  return ArticleService(articleRepository: articleRepository);
});
