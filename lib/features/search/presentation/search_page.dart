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

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _chatbotService = ChatbotService();
  final FocusNode _focusNode = FocusNode();

  List<ArticleEntity> _backendResults = [];
  List<ArticleEntity> _chatbotResults = [];
  bool _isLoading = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _doSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    _focusNode.unfocus();

    setState(() {
      _isLoading = true;
      _error = null;
      _hasSearched = true;
    });

    final results = await Future.wait([
      _searchFromBackend(query),
      _searchFromAI(query),
    ]);

    if (mounted) {
      print("DEBUG: Backend trả về ${results[0].length} bài");
      print("DEBUG: AI trả về ${results[1].length} bài"); // NẾU DÒNG NÀY RA 0 THÌ DO API
      setState(() {
        _backendResults = results[0];
        _chatbotResults = results[1];
        _isLoading = false;
      });
    }
  }

  Future<List<ArticleEntity>> _searchFromBackend(String query) async {
    try {
      return await ref.read(articleRepositoryProvider).searchArticles(query);
    } catch (e) {
      debugPrint("⚠️ Lỗi Backend: $e");
      return [];
    }
  }

  Future<List<ArticleEntity>> _searchFromAI(String query) async {
    try {
      final dynamic response = await _chatbotService.searchArticles(query);

      // ✅ CASE 1: Backend trả THẲNG LIST
      if (response is List) {
        return response.map((item) => _mapToArticle(item)).toList();
      }

      // ✅ CASE 2: Backend trả MAP { results: [...] }
      if (response is Map && response['results'] is List) {
        return (response['results'] as List)
            .map((item) => _mapToArticle(item))
            .toList();
      }
    } catch (e) {
      debugPrint("⚠️ Lỗi AI: $e");
    }
    return [];
  }

  ArticleEntity _mapToArticle(dynamic item) {
    final Map<String, dynamic> articleMap = Map<String, dynamic>.from(item);
    final rawDate = articleMap['published_at'] ?? DateTime.now().toIso8601String();

    String displayTitle =
        articleMap['title'] ?? articleMap['chunk_text'] ?? "Gợi ý từ AI";
    if (displayTitle.length > 60) {
      displayTitle = "${displayTitle.substring(0, 60)}...";
    }

    return ArticleEntity(
      id: articleMap['article_id'] ?? 0,
      title: displayTitle,
      content: articleMap['chunk_text'] ?? '',
      publishedAt: DateTime.tryParse(rawDate) ?? DateTime.now(),
      category: articleMap['category'] ?? 'AI Gợi ý',
      authorName: articleMap['author_name'] ?? 'AI Bot',
      imageUrl: articleMap['image_url'],
      matchScore: (articleMap['score'] as num?)?.toDouble() ?? 0.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- KHAI BÁO CÁC BIẾN LOGIC ĐỂ PHÂN CHIA DANH SÁCH ---
    final backendCount = _backendResults.length;
    final chatbotCount = _chatbotResults.length;
    final bool showSeparator = chatbotCount > 0;
    final totalCount = backendCount + chatbotCount + (showSeparator ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFF111214),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111214),
        elevation: 0,
        centerTitle: true,
        title: const Text('Tìm kiếm AI',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        leading: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchInput(),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Color(0xFFbb1819)))),

          if (!_isLoading && _hasSearched)
            Expanded(
              child: totalCount == 0
                  ? _buildEmptyState()
                  : _buildResultsList(totalCount, backendCount, showSeparator),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              style: const TextStyle(color: Colors.white),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _doSearch(),
              decoration: InputDecoration(
                hintText: 'Bạn muốn tìm tin tức gì?',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: const Color(0xFF1E2023),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _doSearch,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFbb1819),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.search_off, size: 60, color: Colors.white24),
          SizedBox(height: 16),
          Text("Không tìm thấy kết quả phù hợp", style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildResultsList(int totalCount, int backendCount, bool showSeparator) {
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: totalCount,
      separatorBuilder: (ctx, i) => const Divider(color: Colors.white12, height: 1, indent: 16, endIndent: 16),
      itemBuilder: (context, index) {
        // 1. Kết quả từ Backend
        if (index < backendCount) {
          return _buildArticleItem(_backendResults[index]);
        }
        // 2. Nhãn ngăn cách AI
        if (showSeparator && index == backendCount) {
          return _buildSeparatorLabel();
        }
        // 3. Kết quả từ AI
        final chatbotIndex = index - (backendCount + (showSeparator ? 1 : 0));
        if (chatbotIndex >= 0 && chatbotIndex < _chatbotResults.length) {
          return _buildArticleItem(_chatbotResults[chatbotIndex], isAiSuggestion: true);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSeparatorLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: const [
          Expanded(child: Divider(color: Colors.white24)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text("ĐỀ XUẤT TỪ AI",
                style: TextStyle(
                    color: Color(0xFFbb1819),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12)),
          ),
          Expanded(child: Divider(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildArticleItem(ArticleEntity entity, {bool isAiSuggestion = false}) {
    return InkWell(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => ArticlePage(article: entity, articleSlug: entity.id.toString())));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: _buildImage(entity.imageUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entity.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, height: 1.3)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildCategoryBadge(entity, isAiSuggestion),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${entity.authorName} • ${DateFormat('dd/MM').format(entity.publishedAt ?? DateTime.now())}",
                          style: const TextStyle(color: Colors.grey, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
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

  Widget _buildImage(String? url) {
    if (url == null || !url.startsWith('http')) {
      return Container(
          width: 110,
          height: 80,
          color: const Color(0xFF2A2C30),
          child: const Icon(Icons.image_not_supported, color: Colors.grey));
    }
    return Image.network(
      url,
      width: 110,
      height: 80,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
          width: 110,
          height: 80,
          color: const Color(0xFF2A2C30),
          child: const Icon(Icons.broken_image, color: Colors.grey)),
    );
  }

  Widget _buildCategoryBadge(ArticleEntity entity, bool isAi) {
    Color color = isAi ? Colors.green : const Color(0xFFbb1819);
    String label = isAi
        ? "${((entity.matchScore ?? 0) * 100).toStringAsFixed(0)}% Match"
        : (entity.category ?? "Tin tức").toUpperCase();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.5), width: 0.5)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}