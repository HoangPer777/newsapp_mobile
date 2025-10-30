import 'package:flutter/material.dart';
class ArticlePage extends StatelessWidget {
  final String articleId;
  const ArticlePage({super.key, required this.articleId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Article $articleId')),
        body: const Center(child: Text('Nội dung bài viết')));
  }
}
