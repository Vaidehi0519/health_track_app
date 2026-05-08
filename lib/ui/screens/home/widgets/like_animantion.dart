import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  const LikeAnimation({
    super.key,
    required this.isAnimating,
    required this.child,
    this.duration = const Duration(milliseconds: 180),
    this.onEnd,
  });

  final bool isAnimating;
  final Widget child;
  final Duration duration;
  final VoidCallback? onEnd;

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation> {
  double _scale = 1;

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating && widget.isAnimating) {
      setState(() => _scale = 1.18);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: widget.duration,
      curve: Curves.easeOutBack,
      onEnd: () {
        if (_scale == 1.18) {
          setState(() => _scale = 1);
        } else {
          widget.onEnd?.call();
        }
      },
      child: widget.child,
    );
  }
}
