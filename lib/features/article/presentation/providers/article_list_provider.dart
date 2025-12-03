// TODO Implement this library.
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Import Entity (Model sạch dùng cho UI)
import '../../domain/entities/article_entity.dart';

// 2. Import Repository Implementation (Nơi chứa provider của repository)
import '../../data/repositories/article_repository_impl.dart';

/// Provider này quản lý trạng thái tải danh sách bài báo
/// Kiểu trả về: Future<List<ArticleEntity>>
/// UI sẽ dùng .when() để xử lý 3 trạng thái: loading, error, data
final articleListProvider = FutureProvider<List<ArticleEntity>>((ref) async {

  // 1. Lấy Repository từ provider (đã được tạo thủ công ở file repo impl)
  // Lưu ý: 'articleRepositoryProvider' phải được define trong file article_repository_impl.dart
  // Nếu bạn dùng code thủ công tôi đưa trước đó, biến này đã có sẵn.
  final repository = ref.watch(articleRepositoryProvider);

  // 2. Gọi hàm lấy danh sách (Repository sẽ gọi API và map dữ liệu)
  return repository.getArticles();
});