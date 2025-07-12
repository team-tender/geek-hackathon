import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geek_hackathon/data/models/destination.dart';
import 'package:geek_hackathon/presentation/screens/home/widgets/card_back.dart';
import 'package:geek_hackathon/presentation/screens/home/widgets/card_front.dart';

/// カード全体のUIとフリップアニメーションを管理するウィジェット
class DestinationCard extends StatelessWidget {
  const DestinationCard({
    super.key,
    required this.destination,
    required this.isFlipped,
    required this.onTap,
  });

  final Destination destination;
  final bool isFlipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, widget) {
              final angle = rotate.value;
              // 回転の後半（90度未満）でウィジェットを表示するよう修正
              return Transform(
                transform: Matrix4.rotationY(angle),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        // isFlippedの状態に応じて、表示するウィジェットを切り替える
        child: isFlipped
            ? CardBack(destination: destination)
            : CardFront(destination: destination),
      ),
    );
  }
}
