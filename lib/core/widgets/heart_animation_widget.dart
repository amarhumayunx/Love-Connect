import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Heart animation widget for liking/completing actions
class HeartAnimationWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final double size;
  final Color color;

  const HeartAnimationWidget({
    super.key,
    this.onComplete,
    this.size = 60.0,
    this.color = Colors.red,
  });

  @override
  State<HeartAnimationWidget> createState() => _HeartAnimationWidgetState();
}

class _HeartAnimationWidgetState extends State<HeartAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 0.3),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 0.7),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    ));

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Icon(
                Icons.favorite,
                size: widget.size,
                color: widget.color,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Show heart animation overlay
void showHeartAnimation(
    BuildContext context, {
      VoidCallback? onComplete,
      Color color = Colors.red,
    }) {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (_) => Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: HeartAnimationWidget(
            color: color,
            onComplete: () {
              overlayEntry?.remove();
              onComplete?.call();
            },
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);
}
