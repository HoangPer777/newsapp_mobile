import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newsapp_mobile/features/article/data/repositories/article_repository_impl.dart';
import 'package:newsapp_mobile/features/article/presentation/widgets/article_page.dart';
import 'package:newsapp_mobile/features/chatbot/data/chatbot_service.dart';
import 'package:intl/intl.dart';
import '../../article/domain/entities/article_entity.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

// ... (imports are fine)

class _SearchPageState extends ConsumerState<SearchPage> {
  // ... (controllers existing)
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();

  // List chứa 2 phần: Backend + Chatbot
  List<ArticleEntity> _backendResults = [];
  List<ArticleEntity> _chatbotResults = [];

  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;

  void _doSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    // Reset state
    setState(() {
      _isLoading = true;
      _error = null;
      _backendResults = [];
      _chatbotResults = [];
      _hasSearched = true;
    });

    try {
      // 1. Gọi song song 2 API
      final backendFuture =
          ref.read(articleRepositoryProvider).searchArticles(query);
      final chatbotFuture = _chatbotService.searchArticles(query);

      // Chạy chờ cả 2 cùng xong (Future.wait)
      // Lưu ý: Nếu 1 cái lỗi, cái kia vẫn chạy nếu handle try/catch riêng.
      // Ở đây dùng Future.wait đơn giản, nếu 1 cái lỗi sẽ nhảy xuống catch chung.
      // Để robust hơn nên soft-fail, nhưng tạm thời làm đơn giản.
      final results = await Future.wait([
        backendFuture,
        chatbotFuture,
      ]);

      // 2. Xử lý kết quả Backend
      final backendList = results[0] as List<ArticleEntity>;

      // 3. Xử lý kết quả Chatbot (List<dynamic> -> List<ArticleEntity>)
      final chatbotRaw = results[1] as List<dynamic>;
      final chatbotList = chatbotRaw.where((item) => (item['score'] ?? 0) > 0.50).map((item) {
        final rawDate =
            item['published_at'] ?? DateTime.now().toIso8601String();
        final DateTime pubDate = DateTime.tryParse(rawDate) ?? DateTime.now();

        return ArticleEntity(
          id: item['article_id'],
          title: item['title'] ?? 'Gợi ý từ AI',
          content: item['chunk_text'] ?? '',
          publishedAt: pubDate,
          category: item['category'] ?? 'AI Gợi ý',
          authorName: item['author_name'] ?? 'AI Bot',
          imageUrl: item['image_url'],
          matchScore: item['score'],
        );
      }).toList();

      if (mounted) {
        setState(() {
          _backendResults = backendList;
          _chatbotResults = chatbotList.cast<ArticleEntity>();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tổng số item = backend + chatbot + separator (nếu có chatbot)
    final backendCount = _backendResults.length;
    final chatbotCount = _chatbotResults.length;
    final bool showSeparator = chatbotCount > 0;
    
    // Nếu có chatbot thì thêm 1 item cho separator
    final totalCount = backendCount + chatbotCount + (showSeparator ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111214),
        title: const Text('Tìm kiếm AI', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          // SEARCH INPUT
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập nội dung cần tìm...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF1E2023),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _doSearch(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _doSearch,
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFbb1819),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                  ),
                )
              ],
            ),
          ),

          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text('Lỗi: $_error',
                  style: const TextStyle(color: Colors.red)),
            ),

          if (!_isLoading && totalCount == 0 && _hasSearched && _error == null)
             const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Không tìm thấy kết quả phù hợp",
                  style: TextStyle(color: Colors.white54)),
            ),

          // RESULTS LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: totalCount,
              separatorBuilder: (ctx, i) {
                 // Không cần separator divider nếu đó là vị trí của Header "ĐỀ XUẤT"
                 // Nhưng để đơn giản ta cứ để divider mờ
                 return const Divider(color: Colors.white12, height: 1);
              },
              itemBuilder: (context, index) {
                // LOGIC RENDER LIST GỘP

                // 1. Nếu index nằm trong vùng Backend
                if (index < backendCount) {
                  return _buildArticleItem(_backendResults[index]);
                }

                // 2. Nếu là vị trí Separator
                // (Index backendCount chính là phần tử tiếp theo sau list backend)
                if (showSeparator && index == backendCount) {
                  return _buildSeparatorLabel();
                }

                // 3. Nếu là vùng Chatbot
                // index thực tế trong list chatbot = index - (backend + 1 separator)
                final chatbotIndex = index - (backendCount + (showSeparator ? 1 : 0));
                return _buildArticleItem(_chatbotResults[chatbotIndex], isAiSuggestion: true);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeparatorLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      alignment: Alignment.center,
      child: Row(
        children: const [
           Expanded(child: Divider(color: Colors.white24)),
           Padding(
             padding: EdgeInsets.symmetric(horizontal: 12),
             child: Text("---- AI ĐỀ XUẤT ----", style: TextStyle(color: Color(0xFFbb1819), fontWeight: FontWeight.bold, letterSpacing: 1.2)),
           ),
           Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildArticleItem(ArticleEntity entity, {bool isAiSuggestion = false}) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => ArticlePage(
                      article: entity,
                      articleSlug: entity.id.toString(),
                    )));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                entity.imageUrl ?? "https://via.placeholder.com/150",
                width: 110,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 110,
                  height: 80,
                  color: const Color(0xFF2A2C30),
                  child: const Icon(Icons.image_not_supported,
                      color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entity.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      // Badge nếu là AI
                      if (isAiSuggestion && entity.matchScore != null) ...[
                         Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2), // Màu xanh lá cho score
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.green.withOpacity(0.5))),
                          child: Text(
                            "${(entity.matchScore! * 100).toStringAsFixed(0)}% Match", // Hiển thị %
                            style: const TextStyle(
                                color: Colors.green,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else if (isAiSuggestion) ...[ // If AI but no score, show generic AI badge
                         Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.5))),
                          child: const Text(
                            "AI Suggested",
                            style: TextStyle(
                                color: Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ] else ...[
                        // Badge Tin tức thường
                         Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: const Color(0xFFbb1819).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              ),
                          child: Text(
                             (entity.category.isNotEmpty ? entity.category : 'Tin tức').toUpperCase(),
                            style: const TextStyle(
                                color: Color(0xFFbb1819),
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      
                      Expanded(
                        child: Text(
                          "${entity.authorName} • ${DateFormat('dd/MM').format(entity.publishedAt)}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 11),
                        ),
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
