import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'favorite_viewmodel.dart';
import '../../widgets/counter_button.dart';

class FavoriteScreen extends ConsumerWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Count: $count', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 16),
            CounterButton(
              onPressed: () => ref.read(counterProvider.notifier).increment(),
            ),
          ],
        ),
      ),
    );
  }
}
