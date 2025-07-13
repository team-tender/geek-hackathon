import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geek_hackathon/data/repositories/travel_repository.dart';
import 'package:geek_hackathon/presentation/providers/language_provider.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialDestinations();
    });
  }

  Future<void> _loadInitialDestinations() async {
    // リストが空の場合のみAPIから取得
    if (ref.read(destinationListProvider).isEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final languageCode = ref.read(languageProvider).languageCode;
        final repo = ref.read(travelRepositoryProvider);
        final destinations = await repo.fetchRandomDestinations(languageCode);
        if (mounted) {
          ref.read(destinationListProvider.notifier).state = destinations;
          isFlippedList = List.generate(destinations.length, (_) => false);
        }
      } catch (e) {
        debugPrint('Failed to load random destinations: $e');
        // エラーハンドリング (例: スナックバー表示)
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('旅行先の取得に失敗しました。')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      // 既存のデータがあればそれを使う（診断結果からの遷移など）
      setState(() {
        _isLoading = false;
        isFlippedList = List.generate(
          ref.read(destinationListProvider).length,
          (_) => false,
        );
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = ref.watch(destinationListProvider);

    // 言語設定が変更されたら、データを再取得する
    ref.listen(languageProvider, (previous, next) {
      if (previous != next) {
        ref.read(destinationListProvider.notifier).state = []; // データをクリア
        _loadInitialDestinations(); // 再取得
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (destinations.isEmpty)
              const Center(
                child: Text(
                  '旅行先の読み込みに失敗しました。\n画面を再読み込みしてください。',
                  textAlign: TextAlign.center,
                ),
              )
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
                    }
                  }
                  return true;
                },
                cardBuilder: (context, index, percentX, percentY) {
                  return DestinationCard(
                    destination: destinations[index],
                    isFlipped: isFlippedList.length > index
                        ? isFlippedList[index]
                        : false,
                    onTap: () {
                      setState(() {
                        if (isFlippedList.length > index) {
                          isFlippedList[index] = !isFlippedList[index];
                        }
                      });
                    },
                  );
                },
              ),
            if (destinations.isNotEmpty && !_isLoading)
              SwipeActionButtons(controller: controller),
          ],
        ),
      ),
    );
  }
}
