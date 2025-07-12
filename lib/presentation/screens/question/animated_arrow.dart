// animated_arrow.dart
import 'package:flutter/material.dart';

class AnimatedArrow extends StatefulWidget {
  final String imagePath;
  final String label;
  final Duration delay;
  final double? top;
  final double? bottom;
  final Axis direction; // ← 追加：揺れる向き（横 or 縦）

  const AnimatedArrow({
    super.key,
    required this.imagePath,
    required this.label,
    required this.delay,
    this.top,
    this.bottom,
    this.direction = Axis.horizontal, // ← デフォルトは横方向
  });

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.label == 'NO' ? 16 : null,
      right: widget.label == 'YES' ? 16 : null,
      top: widget.top,
      bottom: widget.bottom,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.translate(
            offset: widget.direction == Axis.horizontal
                ? Offset(_animation.value, 0)
                : Offset(0, _animation.value), // ← 方向に応じて動かす
            child: child,
          );
        },
        child: Column(
          children: [
            Image.asset(widget.imagePath, height: 60),
            const SizedBox(height: 4),
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 25,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromRGBO(0, 0, 0, 0.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
