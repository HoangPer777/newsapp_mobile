import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/di/providers.dart';
import '../data/home_api.dart';

final healthProvider = FutureProvider<String>((ref) async {
  final dio = ref.read(dioProvider);
  return HomeApi(dio).health();
});

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final health = ref.watch(healthProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('NewsApp')),
      body: Center(
        child: health.when(
          data: (d) => Text('Backend: $d'),
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Lỗi: $e'),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (i) {
          if (i == 1) context.push('/search');
          if (i == 2) context.push('/chat');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}
