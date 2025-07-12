import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:geek_hackathon/data/models/destination.dart';

import 'package:go_router/go_router.dart';
import 'package:geek_hackathon/presentation/screens/question/question_viewmodel.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen({super.key});

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends ConsumerState<QuestionScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(questionViewModelProvider.notifier).fetchFirstQuestion();
    });
  }

  Future<void> handleAnswer(String answer) async {
    final viewModel = ref.read(questionViewModelProvider.notifier);
    final currentState = ref.read(questionViewModelProvider);

    await viewModel.submitAnswer(currentState.question, answer);

    if (!mounted) return;
    if (viewModel.answers.length >= 5 && context.mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(questionViewModelProvider);
    final viewModel = ref.read(questionViewModelProvider.notifier);

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _buildBody(context, state, viewModel),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    QuestionState state,
    QuestionViewModel viewModel,
  ) {
    // 1. 最終結果が表示された場合
    if (state.destination != null) {
      return DestinationResult(
        destination: state.destination!,
        onRestart: () {
          viewModel.reset();
          viewModel.fetchFirstQuestion();
        },
      );
    }

    // 2. 読み込み中の場合
    if (state.status == ApiStatus.loading) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          Text(state.question, textAlign: TextAlign.center),
        ],
      );
    }

    // 3. エラーが発生した場合
    if (state.status == ApiStatus.error) {
      return Column(
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
      );
    }

    // 4. 質問中または初期状態の場合
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 質問中: スワイプカードを表示
            SizedBox(
              // CardSwiperのサイズを親に合わせる
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: CardSwiper(
                controller: _swiperController,
                cardsCount: 1, // 常に1つの質問を表示
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
                                  'assets/laughing.gif', // TODO: あなたの画像パスに置き換えてください
                                  height: 280,
                                  width: 280,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                state.question,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                '右にスワイプ: はい / 左にスワイプ: いいえ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_right,
                                          size: 40,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _swiperController
                                            .swipe(CardSwiperDirection.right),
                                      ),
                                      const Text(
                                        'Yes',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_left,
                                          size: 40,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _swiperController
                                            .swipe(CardSwiperDirection.left),
                                      ),
                                      const Text(
                                        'Mo',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_upward,
                                          size: 40,
                                          color: Colors.orange,
                                        ),
                                        onPressed: () => _swiperController
                                            .swipe(CardSwiperDirection.top),
                                      ),
                                      const Text(
                                        'Skip',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.arrow_downward,
                                          size: 40,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => _swiperController
                                            .swipe(CardSwiperDirection.bottom),
                                      ),
                                      const Text(
                                        'Maybe yes',
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              ),
            ),
          ],
        ),
        // 「元に戻す」ボタン
        if (viewModel.canUndo)
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: () {
                viewModel.undo();
                // CardSwiperのundoはUI上の動きのため、
                // stateが更新されれば自動で再描画されるので不要
              },
              heroTag: 'undoButton',
              child: const Icon(Icons.undo),
            ),
          ),
      ],
    );
  }
}

/// 診断結果を表示するウィジェット
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
          const Text('あなたへのおすすめは...', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            destination.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
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
