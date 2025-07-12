import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

enum ApiStatus { initial, loading, success, error }

class Destination {
  final String name;
  final String? imageUrl;
  final String description;

  Destination({required this.name, this.imageUrl, required this.description});
}

class QuestionState {
  final String question;
  final ApiStatus status;
  final String? errorMessage;
  final Destination? destination;

  // コンストラクタ
  const QuestionState({
    this.question = '',
    this.status = ApiStatus.initial,
    this.errorMessage,
    this.destination,
  });

  // copyWith メソッド
  QuestionState copyWith({
    String? question,
    ApiStatus? status,
    // errorMessage と destination を null にリセットできるようにする
    ValueGetter<String?>? errorMessage,
    ValueGetter<Destination?>? destination,
  }) {
    return QuestionState(
      question: question ?? this.question,
      status: status ?? this.status,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      destination: destination != null ? destination() : this.destination,
    );
  }
}

class QuestionViewModel extends StateNotifier<QuestionState> {
  final List<QuestionState> _previousStates = []; // 過去の状態を保存するリスト

  QuestionViewModel() : super(const QuestionState());

  bool get canUndo => _previousStates.isNotEmpty;

  /// 状態を完全に初期化する
  void reset() {
    _previousStates.clear();
    state = const QuestionState();
  }

  /// 最初の質問を取得する
  Future<void> fetchFirstQuestion() async {
    _previousStates.clear();
    state = state.copyWith(
      status: ApiStatus.loading,
      question: '最初の質問を準備中です...',
      // reset時にdestinationが残らないようにnullでリセット
      destination: () => null,
    );
    await Future.delayed(const Duration(seconds: 1));
    try {
      state = state.copyWith(
        status: ApiStatus.success,
        question: 'あなたはアウトドア派ですか？',
      );
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// 回答を送信し、次の質問または結果を取得する
  Future<void> submitAnswer(String question, String answer) async {
    _saveState(); // 現在の状態を保存
    state = state.copyWith(
      status: ApiStatus.loading,
      question: '次の質問を考えています...',
    );
    await Future.delayed(const Duration(seconds: 1));

    // デモ用の単純なロジック
    try {
      if (question == 'あなたはアウトドア派ですか？') {
        if (answer == 'はい') {
          state = state.copyWith(
            status: ApiStatus.success,
            question: '山と海、どちらが好きですか？',
          );
        } else {
          state = state.copyWith(
            status: ApiStatus.success,
            question: '美術館巡りは好きですか？',
          );
        }
      } else if (question == '山と海、どちらが好きですか？') {
        state = state.copyWith(
          status: ApiStatus.success,
          destination: () => Destination(
            name: answer == '山' ? '富士山' : '沖縄の海',
            imageUrl: answer == '山'
                ? 'https://cdn.pixabay.com/photo/2016/11/29/05/45/mount-fuji-1867117_1280.jpg'
                : 'https://cdn.pixabay.com/photo/2017/01/20/00/30/okinawa-1993796_1280.jpg',
            description: answer == '山'
                ? '日本一の山、富士山での壮大なハイキングをお楽しみください。'
                : '美しいビーチと透き通った海が広がる沖縄でリラックスしましょう。',
          ),
        );
      } else if (question == '美術館巡りは好きですか？') {
        state = state.copyWith(
          status: ApiStatus.success,
          destination: () => Destination(
            name: answer == 'はい' ? '国立新美術館' : 'お家で映画鑑賞',
            imageUrl: answer == 'はい'
                ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/The_National_Art_Center%2C_Tokyo_01.jpg/1280px-The_National_Art_Center%2C_Tokyo_01.jpg'
                : 'https://cdn.pixabay.com/photo/2014/09/27/13/44/notebook-463533_1280.jpg',
            description: answer == 'はい'
                ? '東京にある国立新美術館で、現代アートの世界に触れてみませんか。'
                : '家でのんびりと好きな映画を観るのが最高のリフレッシュです。',
          ),
        );
      } else {
        // フォールバック（ありえないルート）
        state = state.copyWith(
          status: ApiStatus.success,
          question: '診断が完了しました！',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ApiStatus.error,
        errorMessage: () => e.toString(),
      );
    }
  }

  /// 現在の状態を保存する
  void _saveState() {
    _previousStates.add(state);
  }

  /// 一つ前の状態に戻る
  void undo() {
    if (_previousStates.isNotEmpty) {
      state = _previousStates.removeLast();
    }
  }
}

final questionViewModelProvider =
    StateNotifierProvider<QuestionViewModel, QuestionState>(
      (ref) => QuestionViewModel(),
    );

// --- UI (View) の定義 ---

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
            // 初期状態: スタートボタンを表示
            if (state.status == ApiStatus.initial)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                ),
                onPressed: () => viewModel.fetchFirstQuestion(),
                child: const Text('診断スタート！', style: TextStyle(fontSize: 18)),
              )
            // 質問中: スワイプカードを表示
            else
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
                    viewModel.submitAnswer(state.question, answer);
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
                                    'assets/headUp.png', // TODO: あなたの画像パスに置き換えてください
                                    height: 200,
                                    width: 200,
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
                                          onPressed: () =>
                                              _swiperController.swipe(
                                                CardSwiperDirection.bottom,
                                              ),
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
