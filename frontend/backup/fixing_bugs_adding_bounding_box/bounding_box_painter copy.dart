import 'package:flutter/material.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<Rect> boxes;

  BoundingBoxPainter({required this.boxes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (final box in boxes) {
      canvas.drawRect(box, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
