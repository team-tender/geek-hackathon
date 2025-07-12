import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:go_router/go_router.dart';
import 'package:geek_hackathon/presentation/screens/question/question_viewmodel.dart';
import 'package:geek_hackathon/presentation/screens/question/animated_arrow.dart';
import 'package:lottie/lottie.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});
  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen>
    with SingleTickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  late final AnimationController _arrowShakeController;

  @override
  void dispose() {
    _swiperController.dispose();
    _arrowShakeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _arrowShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionViewModelProvider.notifier).fetchFirstQuestion();
    });
  }

  bool _isNavigating = false;

  Future<void> handleAnswer(String answer) async {
    if (_isNavigating) return;

    final viewModel = ref.read(questionViewModelProvider.notifier);
    final currentState = ref.read(questionViewModelProvider);

    await viewModel.submitAnswer(currentState.question, answer);

    if (viewModel.answers.length >= 5) {
      setState(() {
        _isNavigating = true; // カード非表示フラグ
      });

      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionViewModelProvider);
    final viewModel = ref.read(questionViewModelProvider.notifier);
    if (_isNavigating) {
      // 遷移直前はカード非表示にして空の画面やローディング表示などにする
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (state.status == ApiStatus.loading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/loading.json', // ← あなたのLottieファイルパス
                    height: 400,
                  ),
                ],
              ),
            )
          else if (state.status == ApiStatus.error)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 20),
                  Text('エラーが発生しました: ${state.errorMessage}'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => viewModel.fetchFirstQuestion(),
                    child: const Text('やり直す'),
                  ),
                ],
              ),
            )
          else
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width,
                  child: CardSwiper(
                    controller: _swiperController,
                    cardsCount: 1,
                    numberOfCardsDisplayed: 1,
                    isLoop: false,
                    allowedSwipeDirection: const AllowedSwipeDirection.all(),
                    onSwipe: (previousIndex, currentIndex, direction) {
                      String answer = '';
                      if (direction == CardSwiperDirection.right) {
                        answer = 'はい';
                      } else if (direction == CardSwiperDirection.left) {
                        answer = 'いいえ';
                      } else if (direction == CardSwiperDirection.top) {
                        answer = 'わからない';
                      } else if (direction == CardSwiperDirection.bottom) {
                        answer = 'たぶんそう';
                      }
                      setState(() {});
                      Future.delayed(const Duration(milliseconds: 1000), () {
                        if (mounted) {
                          setState(() {});
                        }
                      });
                      handleAnswer(answer);
                      return true;
                    },
                    cardBuilder:
                        (context, index, percentThresholdX, percentThresholdY) {
                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: const Color(0xFFFFE5CB),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      'assets/liveChatbot.gif',
                                      height: 280,
                                      width: 280,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  //const Spacer(),
                                  SizedBox(height: 50),
                                  Text(
                                    state.question,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                    textAlign: TextAlign.center,
                                  ),
                                  // SizedBox(height: 20),
                                  // const Text(
                                  //   '右: はい / 左: いいえ / 上: わからない / 下: たぶんそう',
                                  //   style: TextStyle(fontSize: 16, color: Colors.grey),
                                  //   textAlign: TextAlign.center,
                                  // ),
                                  // const Spacer(),
                                ],
                              ),
                            ),
                          );
                        },
                  ),
                ),
              ],
            ),
          // 左側 NO（横揺れ）
          AnimatedArrow(
            imagePath: 'assets/arrow_right.png',
            label: 'NO',
            delay: Duration(milliseconds: 0),
            direction: Axis.horizontal, // ← 横揺れ
          ),

          // 右側 YES（横揺れ）
          AnimatedArrow(
            imagePath: 'assets/arrow_left.png',
            label: 'YES',
            delay: Duration(milliseconds: 0),
            direction: Axis.horizontal, // ← 横揺れ
          ),

          // 下側 SKIP（縦揺れ）
          AnimatedArrow(
            imagePath: 'assets/arrow_downward.png',
            label: 'SKIP',
            delay: Duration(milliseconds: 0),
            bottom: 16,
            direction: Axis.vertical, // ← ★縦揺れ
          ),

          AnimatedArrow(
            imagePath: 'assets/arrow_upward.png',
            label: 'MAYBE YES',
            delay: Duration(milliseconds: 0),
            top: 10,
            direction: Axis.vertical, // ← ★縦揺れ
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Undoボタン（背景黒、アイコン白）
                ElevatedButton(
                  onPressed: () {
                    _swiperController.undo();
                    ref.read(questionViewModelProvider.notifier).undo();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 背景黒
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                  ),
                  child: const Icon(
                    Icons.undo,
                    size: 35,
                    color: Colors.white,
                  ), // アイコン白
                ),
                const SizedBox(height: 20),
                // Resetボタン（背景白、アイコン黒）
                ElevatedButton(
                  onPressed: () {
                    ref.read(questionViewModelProvider.notifier).reset();
                    ref
                        .read(questionViewModelProvider.notifier)
                        .fetchFirstQuestion();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 背景白
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    //side: const BorderSide(color: Colors.black), // 黒い枠線を付けたい場合
                  ),
                  child: const Icon(
                    Icons.refresh,
                    size: 35,
                    color: Colors.black,
                  ), // アイコン黒
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DestinationResult extends StatelessWidget {
  const DestinationResult({
    super.key,
    required this.destination,
    required this.onRestart,
  });
  final Destination destination;
  final VoidCallback onRestart;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                (destination.imageUrl != null &&
                    destination.imageUrl!.isNotEmpty)
                ? Image.network(
                    destination.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            );
                    },
                    errorBuilder: (context, error, stack) => const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image, size: 50)),
                    ),
                  )
                : const SizedBox(
                    height: 200,
                    child: Center(child: Text('画像がありません')),
                  ),
          ),
          const SizedBox(height: 20),
          Text(destination.description, textAlign: TextAlign.center),
          const SizedBox(height: 30),
          ElevatedButton(onPressed: onRestart, child: const Text('もう一度診断する')),
        ],
      ),
    );
  }
}
