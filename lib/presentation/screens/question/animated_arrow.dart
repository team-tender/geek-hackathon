// animated_arrow.dart
import 'package:flutter/material.dart';

class AnimatedArrow extends StatefulWidget {
  final String imagePath;
  final String label;
  final Duration delay;
  final double? top;
  final double? bottom;
  final Axis direction;
  final AlignmentGeometry? position; // New: for easier positioning
  final AnimationController? animationController; // New: external controller

  const AnimatedArrow({
    super.key,
    required this.imagePath,
    required this.label,
    required this.delay,
    this.top,
    this.bottom,
    this.direction = Axis.horizontal,
    this.position, // Add to constructor
    this.animationController, // Add to constructor
  });

  @override
  State<AnimatedArrow> createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController
  _internalController; // Now internal or external
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _internalController =
        widget.animationController ??
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 800),
        );

    _animation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _internalController, curve: Curves.easeInOut),
    );

    if (widget.animationController == null) {
      // Only repeat if it's an internal controller
      Future.delayed(widget.delay, () {
        if (mounted) {
          _internalController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedArrow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animationController != widget.animationController) {
      // If controller changes, stop old one and potentially start new one
      oldWidget.animationController?.stop();
      if (widget.animationController == null) {
        // If it reverts to internal, restart repeat
        _internalController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    if (widget.animationController == null) {
      // Only dispose if it's an internal controller
      _internalController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      // Use Positioned.fill for alignment
      child: Align(
        alignment:
            widget.position ?? Alignment.center, // Use new position property
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.translate(
              offset: widget.direction == Axis.horizontal
                  ? Offset(_animation.value, 0)
                  : Offset(0, _animation.value),
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min, // Wrap content tightly
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
      ),
    );
  }
}
