import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Confetti animation widget for surprise reveals
class ConfettiWidget extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;

  const ConfettiWidget({
    super.key,
    this.onComplete,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    // Create confetti particles
    for (int i = 0; i < 50; i++) {
      _particles.add(ConfettiParticle(
        x: _random.nextDouble(),
        y: -0.1,
        color: _getRandomColor(),
        size: 4.0 + _random.nextDouble() * 6.0,
        speed: 0.3 + _random.nextDouble() * 0.5,
        angle: _random.nextDouble() * 2 * math.pi,
      ));
    }

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getRandomColor() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.blue,
      Colors.yellow,
      Colors.orange,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ConfettiPainter(
            particles: _particles,
            progress: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class ConfettiParticle {
  double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  final double angle;

  ConfettiParticle({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double progress;

  ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()..color = particle.color;
      
      // Update position
      final newY = particle.y + (particle.speed * progress);
      final newX = particle.x + (math.sin(particle.angle) * 0.1 * progress);
      
      // Draw particle
      canvas.drawCircle(
        Offset(newX * size.width, newY * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Show confetti overlay
void showConfetti(
    BuildContext context, {
      VoidCallback? onComplete,
      Duration duration = const Duration(seconds: 2),
    }) {
  final overlay = Overlay.of(context);

  OverlayEntry? overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: ConfettiWidget(
        duration: duration,
        onComplete: () {
          overlayEntry?.remove();
          onComplete?.call();
        },
      ),
    ),
  );

  overlay.insert(overlayEntry);
}
