import 'package:flutter/material.dart';

class AppBarLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // AI Circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xFF6464FF), width: 2),
              borderRadius: BorderRadius.circular(20),
              color: Color(0xFF141428).withOpacity(0.5),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF6464FF).withOpacity(0.3),
                  blurRadius: 15,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                          blurRadius: 5,
                          color: Color(0xFF6464FF).withOpacity(0.7),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bird/Phoenix
                Positioned(
                  right: -5,
                  top: 12,
                  child: Container(
                    width: 24,
                    height: 16,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Color(0xFF6464FF).withOpacity(0.7),
                          Colors.transparent,
                        ],
                        stops: [0.4, 0.5, 0.6],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _BirdPainter(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10),
          // ISWAR Text with Chakra
          Row(
            children: [
              Text('ISW', style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Color(0xFF6464FF).withOpacity(0.5),
                  ),
                ],
              )),
              // Chakra
              Container(
                width: 20,
                height: 20,
                margin: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  gradient: SweepGradient(
                    colors: [
                      Color(0xFF6464FF),
                      Color(0xFF9664FF),
                      Color(0xFF6464FF),
                      Color(0xFF9664FF),
                      Color(0xFF6464FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF6464FF).withOpacity(0.7),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Color(0xFF1e1e2f),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Center(
                      child: Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Color(0xFF6464FF).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text('R', style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: Color(0xFF6464FF).withOpacity(0.5),
                  ),
                ],
              )),
            ],
          ),
        ],
      ),
    );
  }
}

class _BirdPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF6464FF)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height / 2);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}