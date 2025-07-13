// question_screen.dart
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
    with TickerProviderStateMixin {
  final CardSwiperController _swiperController = CardSwiperController();
  late final AnimationController _arrowShakeController;
  late final AnimationController _undoAnimationController;
  late final Animation<double> _undoRotationAnimation;
  late final AnimationController _resetAnimationController;
  late final Animation<double> _resetRotationAnimation;

  // New AnimationControllers for each swipe direction
  late final AnimationController _rightSwipeArrowController;
  late final AnimationController _leftSwipeArrowController;
  late final AnimationController _topSwipeArrowController;
  late final AnimationController _bottomSwipeArrowController;

  @override
  void dispose() {
    _swiperController.dispose();
    _arrowShakeController.dispose();
    _undoAnimationController.dispose();
    _resetAnimationController.dispose();
    // Dispose new controllers
    _rightSwipeArrowController.dispose();
    _leftSwipeArrowController.dispose();
    _topSwipeArrowController.dispose();
    _bottomSwipeArrowController.dispose();
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

    _undoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _undoRotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _undoAnimationController, curve: Curves.easeOut),
    );

    _resetAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _resetRotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _resetAnimationController, curve: Curves.easeOut),
    );

    // Initialize new swipe arrow controllers
    _rightSwipeArrowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 200,
      ), // Quick animation for feedback
    );
    _leftSwipeArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _topSwipeArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bottomSwipeArrowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
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
                      // Trigger arrow animation based on swipe direction
                      if (direction == CardSwiperDirection.right) {
                        answer = 'はい';
                        _rightSwipeArrowController.forward(from: 0);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _rightSwipeArrowController.reverse();
                        });
                      } else if (direction == CardSwiperDirection.left) {
                        answer = 'いいえ';
                        _leftSwipeArrowController.forward(from: 0);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _leftSwipeArrowController.reverse();
                        });
                      } else if (direction == CardSwiperDirection.top) {
                        answer = 'わからない';
                        _topSwipeArrowController.forward(from: 0);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _topSwipeArrowController.reverse();
                        });
                      } else if (direction == CardSwiperDirection.bottom) {
                        answer = 'たぶんそう';
                        _bottomSwipeArrowController.forward(from: 0);
                        Future.delayed(const Duration(milliseconds: 200), () {
                          _bottomSwipeArrowController.reverse();
                        });
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
                                    child: Center(
                                      child: Transform.scale(
                                        scale: 1.2, // 拡大率を調整
                                        child: Lottie.asset(
                                          'assets/liveChatbot.json',
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                        ),
                                      ),
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
                                  //    '右: はい / 左: いいえ / 上: わからない / 下: たぶんそう',
                                  //    style: TextStyle(fontSize: 16, color: Colors.grey),
                                  //    textAlign: TextAlign.center,
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
          // Left (NO) arrow
          AnimatedArrow(
            imagePath: 'assets/arrow_right.png',
            label: 'NO',
            delay: Duration(milliseconds: 0),
            direction: Axis.horizontal,
            position: Alignment.centerLeft, // New property for positioning
            animationController: _leftSwipeArrowController, // Pass controller
          ),
          // Right (YES) arrow
          AnimatedArrow(
            imagePath: 'assets/arrow_left.png',
            label: 'YES',
            delay: Duration(milliseconds: 0),
            direction: Axis.horizontal,
            position: Alignment.centerRight, // New property for positioning
            animationController: _rightSwipeArrowController, // Pass controller
          ),
          // Bottom (SKIP) arrow
          AnimatedArrow(
            imagePath: 'assets/arrow_downward.png',
            label: 'SKIP',
            delay: Duration(milliseconds: 0),
            bottom: 16,
            direction: Axis.vertical,
            position: Alignment.bottomCenter, // New property for positioning
            animationController: _bottomSwipeArrowController, // Pass controller
          ),
          // Top (MAYBE YES) arrow
          AnimatedArrow(
            imagePath: 'assets/arrow_upward.png',
            label: 'MAYBE YES',
            delay: Duration(milliseconds: 0),
            top: 10,
            direction: Axis.vertical,
            position: Alignment.topCenter, // New property for positioning
            animationController: _topSwipeArrowController, // Pass controller
          ),
          Positioned(
            bottom: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Undoボタン（背景黒、アイコン白）
                RotationTransition(
                  turns: _undoRotationAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      _undoAnimationController.forward(from: 0);
                      _swiperController.undo();
                      ref.read(questionViewModelProvider.notifier).undo();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(
                      Icons.undo,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Resetボタン（背景白、アイコン黒）
                RotationTransition(
                  turns: _resetRotationAnimation,
                  child: ElevatedButton(
                    onPressed: () {
                      _resetAnimationController.forward(from: 0);
                      ref.read(questionViewModelProvider.notifier).reset();
                      ref
                          .read(questionViewModelProvider.notifier)
                          .fetchFirstQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                    ),
                    child: const Icon(
                      Icons.refresh,
                      size: 35,
                      color: Colors.black,
                    ),
                  ),
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
