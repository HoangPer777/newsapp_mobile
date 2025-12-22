import 'package:flutter/material.dart';
import 'package:newsapp_mobile/features/article/presentation/widgets/article_page.dart';
import 'package:newsapp_mobile/features/chatbot/data/chatbot_service.dart';
import 'package:intl/intl.dart';
import '../../article/domain/entities/article_entity.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// ... (imports are fine)

class _SearchPageState extends State<SearchPage> {
  // ... (controllers existing)
  final TextEditingController _controller = TextEditingController();
  final ChatbotService _service = ChatbotService();

  List<dynamic> _results = [];
  bool _isLoading = false;
  String? _error;

  void _doSearch() async {
    final query = _controller.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _results = [];
    });

    try {
      final rawResults = await _service.searchArticles(query);
      // Filter by strict threshold (e.g. 50% match)
      final filtered =
          rawResults.where((item) => (item['score'] ?? 0) > 0.50).toList();

      setState(() {
        _results = filtered;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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

          if (!_isLoading && _results.isEmpty && _controller.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text("Không tìm thấy kết quả phù hợp (độ khớp < 50%)",
                  style: TextStyle(color: Colors.white54)),
            ),

          // RESULTS LIST
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _results.length,
              separatorBuilder: (ctx, i) =>
                  const Divider(color: Colors.white12, height: 1),
              itemBuilder: (context, index) {
                final item = _results[index];

                // Map API JSON to Entity for Navigation
                final rawDate =
                    item['published_at'] ?? DateTime.now().toIso8601String();
                final DateTime pubDate =
                    DateTime.tryParse(rawDate) ?? DateTime.now();

                final entity = ArticleEntity(
                  id: item['article_id'],
                  title: item['title'] ?? 'Full Article',
                  content: item['chunk_text'] ??
                      '', // Placeholder content if not full
                  publishedAt: pubDate,
                  category: item['category'] ?? 'Tin tức',
                  authorName: item['author_name'] ?? 'Unknown',
                  imageUrl: item['image_url'],
                );

                final double score = (item['score'] ?? 0) * 100;

                // Rich UI Item (copied/adapted from HomePage logic)
                return InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ArticlePage(
                                  article: entity, // Pass full entity!
                                  articleSlug: entity.id.toString(),
                                )));
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            entity.imageUrl ??
                                "https://via.placeholder.com/150",
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
                              // Score Badge + Info
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.5))),
                                    child: Text(
                                      "${score.toStringAsFixed(0)}% Match",
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${entity.authorName} • ${DateFormat('dd/MM').format(pubDate)}",
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
              },
            ),
          ),
        ],
      ),
    );
  }
}
