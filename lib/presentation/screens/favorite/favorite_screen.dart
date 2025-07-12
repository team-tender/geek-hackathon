import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/presentation/screens/home/home_viewmodel.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteDestinationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('お気に入り一覧'),
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('お気に入りがありません'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final d = favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        d.imageUrl ?? 'https://via.placeholder.com/100x100?text=No+Image',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(d.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(d.description),
                        const SizedBox(height: 4),
                        Text('アクセス: ${d.access}'),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
    );
  }
}
