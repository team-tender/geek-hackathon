import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

/// スワイプ操作ボタンのUI
class SwipeActionButtons extends StatelessWidget {
  const SwipeActionButtons({super.key, required this.controller});

  final CardSwiperController controller;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, // 位置を少し調整
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'skip',
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            onPressed: () => controller.swipe(CardSwiperDirection.left),
            child: const Icon(Icons.close, size: 30),
          ),
          FloatingActionButton(
            heroTag: 'like',
            backgroundColor: Colors.white,
            foregroundColor: Colors.green,
            onPressed: () => controller.swipe(CardSwiperDirection.right),
            child: const Icon(Icons.favorite, size: 30),
          ),
        ],
      ),
    );
  }
}
