import 'package:flutter/material.dart';
class CommentPage extends StatelessWidget {
  final String articleId;
  const CommentPage({super.key, required this.articleId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text('Comments for $articleId')),
        body: const Center(child: Text('Luồng bình luận')));
  }
}
