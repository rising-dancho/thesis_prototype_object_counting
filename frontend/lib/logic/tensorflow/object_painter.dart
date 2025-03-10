import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ObjectPainter extends CustomPainter {
  final List<Rect> editableBoundingBoxes; 
  final ui.Image imageFile;

  ObjectPainter({
    required this.imageFile,
    required this.editableBoundingBoxes, 
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Get the aspect ratio of the image and the canvas
    double imageAspect = imageFile.width / imageFile.height;
    double canvasAspect = size.width / size.height;

    double drawWidth, drawHeight, offsetX, offsetY;

    if (imageAspect > canvasAspect) {
      // Image is wider than canvas -> fit width
      drawWidth = size.width;
      drawHeight = size.width / imageAspect;
      offsetX = 0;
      offsetY = (size.height - drawHeight) / 2;
    } else {
      // Image is taller than canvas -> fit height
      drawHeight = size.height;
      drawWidth = size.height * imageAspect;
      offsetY = 0;
      offsetX = (size.width - drawWidth) / 2;
    }

    double scaleX = drawWidth / imageFile.width;
    double scaleY = drawHeight / imageFile.height;

    canvas.drawImageRect(
      imageFile,
      Rect.fromLTWH(0, 0, imageFile.width.toDouble(), imageFile.height.toDouble()),
      Rect.fromLTWH(offsetX, offsetY, drawWidth, drawHeight),
      Paint()..filterQuality = FilterQuality.high, // Ensure high-quality scaling
    );

    // Dynamic stroke width calculation
    final double minStroke = 2.0;
    final double maxStroke = 10.0;
    final double strokeWidth = ((size.width + size.height) / 200).clamp(minStroke, maxStroke);

    final manualBoxPaint = Paint()
      ..color = Colors.red // Manually added boxes in red
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 🎯 **Draw only manually added bounding boxes**
    for (Rect box in editableBoundingBoxes) {
      final scaledBox = Rect.fromLTRB(
        offsetX + (box.left * scaleX),
        offsetY + (box.top * scaleY),
        offsetX + (box.right * scaleX),
        offsetY + (box.bottom * scaleY),
      );
      canvas.drawRect(scaledBox, manualBoxPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ObjectPainter oldDelegate) {
    return oldDelegate.imageFile != imageFile ||
        oldDelegate.editableBoundingBoxes != editableBoundingBoxes; // 👈 Only check editable boxes
  }
}
