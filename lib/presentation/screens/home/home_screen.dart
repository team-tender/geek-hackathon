import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/presentation/screens/home/home_viewmodel.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<bool> isFlippedList = [];

  final List<Destination> defaultDestinations = [
    Destination(
      name: '京都',
      description: '伝統と文化の街、古都京都。',
      access: '東京から新幹線で約2時間30分',
      imageUrl: 'https://images.unsplash.com/photo-1519046904884-53103b34b206',
    ),
    Destination(
      name: '沖縄',
      description: '青い海と白い砂浜が広がる楽園。',
      access: '羽田空港から直行便で約3時間',
      imageUrl: 'https://images.unsplash.com/photo-1519046904884-53103b34b206',
    ),
    Destination(
      name: '北海道',
      description: '大自然と美味しいグルメを楽しめる。',
      access: '新千歳空港から札幌まで電車で約40分',
      imageUrl: 'https://images.unsplash.com/photo-1519046904884-53103b34b206',
    ),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final current = ref.read(destinationListProvider);
      if (current.isEmpty) {
        ref.read(destinationListProvider.notifier).state = defaultDestinations;
      }
      isFlippedList = List.generate(
        ref.read(destinationListProvider).length,
        (_) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationListProvider);

    if (isFlippedList.length != destinations.length) {
      isFlippedList = List.generate(destinations.length, (_) => false);
    }

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (destinations.isEmpty)
              const Center(child: Text('診断結果がありません'))
            else
              CardSwiper(
                controller: controller,
                cardsCount: destinations.length,
                numberOfCardsDisplayed: 3,
                backCardOffset: const Offset(10, 10),
                padding: const EdgeInsets.all(24),
                allowedSwipeDirection: AllowedSwipeDirection.only(
                  left: true,
                  right: true,
                  up: false,
                  down: false,
                ),
                onSwipe: (previousIndex, currentIndex, direction) {
                  if (direction == CardSwiperDirection.right) {
                    final d = destinations[previousIndex];
                    final favorites = ref.read(favoriteDestinationProvider);
                    if (!favorites.contains(d)) {
                      ref.read(favoriteDestinationProvider.notifier).state = [
                        ...favorites,
                        d,
                      ];
                      debugPrint('★ お気に入りに追加: ${d.name}');
                    } else {
                      debugPrint('★ すでにお気に入りに含まれています: ${d.name}');
                    }
                  }
                  return true;
                },
                cardBuilder: (context, index, percentX, percentY) {
                  final d = destinations[index];
                  final isFlipped = isFlippedList[index];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        isFlippedList[index] = !isFlipped;
                      });
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
                        return AnimatedBuilder(
                          animation: rotate,
                          child: child,
                          builder: (context, child) {
                            final angle = rotate.value;
                            return Transform(
                              transform: Matrix4.rotationY(angle),
                              alignment: Alignment.center,
                              child: child,
                            );
                          },
                        );
                      },
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: isFlipped
                          ? Container(
                              key: const ValueKey(true),
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 22)),
                                  const SizedBox(height: 12),
                                  Text(d.description, style: const TextStyle(color: Colors.white70)),
                                  const SizedBox(height: 12),
                                  const Text('アクセス', style: TextStyle(color: Colors.white)),
                                  Text(d.access, style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            )
                          : Container(
                              key: const ValueKey(false),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: DecorationImage(
                                  image: NetworkImage(
                                    d.imageUrl ?? 'https://via.placeholder.com/400x600?text=No+Image',
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                d.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),

            // ↓ 追加: スワイプボタンをカードの下に浮かせて表示
            if (destinations.isNotEmpty)
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FloatingActionButton(
                      heroTag: 'skip',
                      backgroundColor: Colors.redAccent,
                      onPressed: () {
                        controller.swipe(CardSwiperDirection.left);
                      },
                      child: const Icon(Icons.close),
                    ),
                    FloatingActionButton(
                      heroTag: 'like',
                      backgroundColor: Colors.green,
                      onPressed: () {
                        controller.swipe(CardSwiperDirection.right);
                      },
                      child: const Icon(Icons.favorite),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
