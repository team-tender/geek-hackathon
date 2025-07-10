import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

// ホーム画面のウィジェット
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 表示する画像URLのリスト（旅行先）
  final List<String> imageUrls = [
    'https://source.unsplash.com/featured/400x600/?beach',
    'https://source.unsplash.com/featured/400x600/?mountain',
    'https://source.unsplash.com/featured/400x600/?city',
  ];

  // カードの操作用コントローラー（ボタン操作にも使う）
  final CardSwiperController controller = CardSwiperController();

  // 画面が破棄されるときにコントローラーも破棄
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // スワイプが完了したときの処理（いいね／スキップ）
  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    if (direction == CardSwiperDirection.left) {
      debugPrint("スキップ: $previousIndex");
    } else if (direction == CardSwiperDirection.right) {
      debugPrint("いいね！: $previousIndex");
    }
    return true; // trueでスワイプ動作を許可
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 上部：スワイプカード部分（画像表示）
            Expanded(
              child: CardSwiper(
                controller: controller,
                cardsCount: imageUrls.length, // カード枚数
                numberOfCardsDisplayed: 3, // 表示中のカード数
                backCardOffset: const Offset(10, 10), // 後ろのカードの位置ずらし
                padding: const EdgeInsets.all(24), // カード全体の余白
                // カード1枚の中身（画像＋タイトル）
                cardBuilder: (context, index, percentX, percentY) {
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(imageUrls[index], fit: BoxFit.cover),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            color: Colors.black54,
                            child: Text(
                              '旅行先 #${index + 1}', // 下に表示されるテキスト
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
                onSwipe: _onSwipe, // スワイプ時の処理
                onEnd: () => debugPrint('カードがなくなりました'), // 最後のカードまでスワイプしたとき
              ),
            ),
          ],
        ),
      ),
    );
  }
}
