import 'package:flutter/material.dart';
import 'package:love_connect/core/colors/app_colors.dart';

class SplashLoadingIndicator extends StatefulWidget {
  final double size;
  final double dotSpacing;

  const SplashLoadingIndicator({
    super.key,
    required this.size,
    this.dotSpacing = 12.0,
  });

  @override
  State<SplashLoadingIndicator> createState() => _SplashLoadingIndicatorState();
}

class _SplashLoadingIndicatorState extends State<SplashLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 4.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Calculate which dot should be active based on animation value
        // The animation cycles from 0.0 to 4.0, wrapping around
        final animationValue = _animation.value;
        final activeIndex = animationValue.floor() % 4;
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final isActive = index == activeIndex;
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.dotSpacing / 2),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? AppColors.primaryRed // Bright red for active dot
                    : AppColors.primaryDark, // Dark red/maroon for inactive dots
              ),
            );
          }),
        );
      },
    );
  }
}
