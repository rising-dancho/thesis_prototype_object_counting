import 'dart:ui';

class DetectedObject {
  final Rect rect;
  final String label;
  final double score;

  DetectedObject(
      {required this.rect, required this.label, required this.score});
}
