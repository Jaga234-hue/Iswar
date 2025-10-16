import 'package:flutter/material.dart';

class CosmicBackground extends StatefulWidget {
  final Widget child;

  const CosmicBackground({Key? key, required this.child}) : super(key: key);

  @override
  _CosmicBackgroundState createState() => _CosmicBackgroundState();
}

class _CosmicBackgroundState extends State<CosmicBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();
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
        return CustomPaint(
          painter: CosmicPainter(_controller.value),
          child: widget.child,
        );
      },
    );
  }
}

class CosmicPainter extends CustomPainter {
  final double animationValue;

  CosmicPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw cosmic background with stars and network lines
    final paint = Paint()
      ..color = Color(0xFF6464FF).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw stars
    for (int i = 0; i < 50; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 73) % size.height;
      final radius = (i % 3 + 1) * 0.5;
      final opacity = 0.2 + (i % 10) * 0.08;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = Colors.white.withOpacity(opacity)
          ..style = PaintingStyle.fill,
      );
    }

    // Draw network lines
    for (int i = 0; i < 10; i++) {
      final startX = 0.0;
      final startY = (i * 50 + animationValue * 100) % size.height;
      final endX = size.width;
      final endY = ((i * 30) + animationValue * 50) % size.height;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint..color = Color(0xFF6464FF).withOpacity(0.05),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}