import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class SwipeActionButtons extends StatefulWidget {
  final CardSwiperController controller;

  const SwipeActionButtons({super.key, required this.controller});

  @override
  State<SwipeActionButtons> createState() => _SwipeActionButtonsState();
}

class _SwipeActionButtonsState extends State<SwipeActionButtons>
    with TickerProviderStateMixin {
  late AnimationController _likeController;
  late AnimationController _skipController;

  @override
  void initState() {
    super.initState();
    _likeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: 1.0,
      upperBound: 1.3, // 少し大きく
      vsync: this,
    );
    _skipController = AnimationController(
      duration: const Duration(milliseconds: 100),
      lowerBound: 1.0,
      upperBound: 1.3,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeController.dispose();
    _skipController.dispose();
    super.dispose();
  }

  Future<void> _onLike() async {
    await _likeController.forward();
    await _likeController.reverse();
    widget.controller.swipe(CardSwiperDirection.right);
  }

  Future<void> _onSkip() async {
    await _skipController.forward();
    await _skipController.reverse();
    widget.controller.swipe(CardSwiperDirection.left);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ScaleTransition(
            scale: _skipController,
            child: FloatingActionButton(
              heroTag: 'skip',
              backgroundColor: Colors.white,
              foregroundColor: Colors.red,
              elevation: 6,
              onPressed: _onSkip,
              child: const Icon(Icons.close, size: 30),
            ),
          ),
          ScaleTransition(
            scale: _likeController,
            child: FloatingActionButton(
              heroTag: 'like',
              backgroundColor: Colors.white,
              foregroundColor: Colors.green,
              elevation: 6,
              onPressed: _onLike,
              child: const Icon(Icons.favorite, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}
