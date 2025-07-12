import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/data/repositories/travel_repository.dart';
import 'package:geek_hackathon/presentation/providers/liked_destinations_provider.dart';

/// --- 初期表示の旅行先リスト ---
final defaultDestinationsProvider = Provider<List<Destination>>((ref) {
  return [
    Destination(
      name: '東京',
      description: '日本の首都であり、歴史と現代が融合する都市。',
      access: '羽田空港から電車で30分',
      imageUrl: 'https://via.placeholder.com/400x600?text=Tokyo',
    ),
    Destination(
      name: '京都',
      description: '伝統的な寺院と文化が色濃く残る古都。',
      access: '新幹線で東京から2時間半',
      imageUrl: 'https://via.placeholder.com/400x600?text=Kyoto',
    ),
    Destination(
      name: '沖縄',
      description: '美しいビーチと独自文化を持つ南の島。',
      access: '那覇空港から各地へバス移動',
      imageUrl: 'https://via.placeholder.com/400x600?text=Okinawa',
    ),
  ];
});

/// --- 現在表示中の旅行先リスト（初期は default）---
final currentDestinationsProvider = StateProvider<List<Destination>>((ref) {
  return ref.watch(defaultDestinationsProvider);
});

/// --- ホーム画面ウィジェット ---
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final CardSwiperController controller = CardSwiperController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // スワイプ処理（いいね／スキップ）
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final destinations = ref.read(currentDestinationsProvider);
    final swipedDestination = destinations[previousIndex];

    if (direction == CardSwiperDirection.left) {
      debugPrint("スキップ: ${swipedDestination.name}");
    } else if (direction == CardSwiperDirection.right) {
      debugPrint("いいね！: ${swipedDestination.name}");
      ref.read(likedDestinationsProvider.notifier).addDestination(swipedDestination);
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(currentDestinationsProvider);

    return Scaffold(
      body: SafeArea(
        child: destinations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : CardSwiper(
                controller: controller,
                cardsCount: destinations.length,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(10, 10),
                padding: const EdgeInsets.all(24),
                cardBuilder: (context, index, percentX, percentY) {
                  final d = destinations[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          d.imageUrl ?? 'https://via.placeholder.com/400x600?text=No+Image',
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            color: Colors.black54,
                            child: Text(
                              d.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                onSwipe: _onSwipe,
                onEnd: () => debugPrint('カードがなくなりました'),
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final defaultList = ref.read(defaultDestinationsProvider);
          ref.read(currentDestinationsProvider.notifier).state = defaultList;
        },
        label: const Text('リセット'),
        icon: const Icon(Icons.refresh),
      ),
    );
  }
}
