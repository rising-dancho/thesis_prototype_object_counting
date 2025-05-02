import 'dart:ui';

class DetectedObject {
  final Rect rect;
  final String label;
  final double score;
  final Color color;

  DetectedObject({
    required this.rect,
    required this.label,
    required this.score,
    required this.color,
  });
}
