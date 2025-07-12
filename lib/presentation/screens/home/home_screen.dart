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
      name: '長崎',
      description: '異国情緒あふれる港町。歴史と文化が交差する街。',
      access: '羽田空港から長崎空港まで約2時間',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1690957484571-26f88c6ad43f?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8TmFnYXNha2l8ZW58MHx8MHx8fDA%3D', // 長崎の街並み
    ),
    Destination(
      name: '金沢',
      description: '加賀百万石の城下町。兼六園や近江町市場が魅力。',
      access: '東京から新幹線で約2時間30分',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1690957484571-26f88c6ad43f?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8TmFnYXNha2l8ZW58MHx8MHx8fDA%3D', // 金沢・雪の茶屋街
    ),
    Destination(
      name: '屋久島',
      description: '世界自然遺産の島。神秘的な森と豊かな自然。',
      access: '鹿児島からフェリーで約4時間、または飛行機で約35分',
      imageUrl:
          'https://plus.unsplash.com/premium_photo-1690957484571-26f88c6ad43f?w=800&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8TmFnYXNha2l8ZW58MHx8MHx8fDA%3D', // 屋久島・苔むす森
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
