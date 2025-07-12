import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/presentation/screens/home/home_viewmodel.dart';
import 'package:geek_hackathon/presentation/screens/home/widgets/distination_card.dart';
import 'package:geek_hackathon/presentation/screens/home/widgets/swipe_action_button.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final CardSwiperController controller = CardSwiperController();
  List<bool> isFlippedList = [];

  // サンプルデータ (変更なし)
  final List<Destination> defaultDestinations = [
    Destination(
      name: '京都',
      description: '伝統と文化の街、古都京都。',
      access: '東京から新幹線で約2時間30分',
      imageUrl: 'https://images.unsplash.com/photo-1578637387935-13293e502嵓嵓嵓',
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
      imageUrl: 'https://images.unsplash.com/photo-1557898142-29a3a251b14a',
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
  void dispose() {
    controller.dispose();
    super.dispose();
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
                // cardBuilderが非常にシンプルに！
                cardBuilder: (context, index, percentX, percentY) {
                  return DestinationCard(
                    destination: destinations[index],
                    isFlipped: isFlippedList[index],
                    onTap: () {
                      setState(() {
                        isFlippedList[index] = !isFlippedList[index];
                      });
                    },
                  );
                },
              ),
            // スワイプボタンもウィジェットとして分離
            if (destinations.isNotEmpty)
              SwipeActionButtons(controller: controller),
          ],
        ),
      ),
    );
  }
}
