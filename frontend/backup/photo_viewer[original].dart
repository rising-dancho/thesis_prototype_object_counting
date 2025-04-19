import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';

class PhotoViewer extends StatefulWidget {
  final String timestamp;
  final File imageFile;
  final ui.Image? imageForDrawing; // ✅ Add this parameter
  final List<Rect> editableBoundingBoxes;
  final Function(Rect) onNewBox;
  final Function(int) onRemoveBox;
  final bool isAddingBox;
  final bool isRemovingBox;
  final TextEditingController titleController;

  const PhotoViewer({
    super.key,
    required this.imageFile,
    required this.imageForDrawing,
    required this.editableBoundingBoxes,
    required this.onNewBox,
    required this.onRemoveBox,
    required this.isAddingBox,
    required this.isRemovingBox,
    required this.timestamp,
    required this.titleController,
  });

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late List<Rect> boundingBoxes;
  int? draggingBoxIndex;
  Offset? dragStart;

  // FOR LABELS
  late String timestamp;

  double scaleX = 1.0; // ✅ Scaling factors
  double scaleY = 1.0;
  double offsetX = 0.0; // ✅ Offset for centering image
  double offsetY = 0.0;

  @override
  void initState() {
    super.initState();
    boundingBoxes = List.from(widget.editableBoundingBoxes);
    timestamp = widget.timestamp; // ✅ Initialize from widget
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _calculateScaling()); // ✅ Run after layout
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            /// Background Image Viewer
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: ImageWithBoxesPainter(
                  image: widget.imageForDrawing!,
                  boxes: boundingBoxes,
                  scaleX: scaleX,
                  scaleY: scaleY,
                  offsetX: offsetX,
                  offsetY: offsetY,
                ),
                child: Container(), // Ensures layout constraints apply
              ),
            ),

            /// Bounding Boxes Over the Image
            ...boundingBoxes.asMap().entries.map((entry) {
              int index = entry.key;
              Rect box = entry.value;

              return Positioned(
                left: box.left * scaleX + offsetX,
                top: box.top * scaleY + offsetY,
                width: box.width * scaleX,
                height: box.height * scaleY,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GestureDetector(
                      onPanStart: (details) {
                        setState(() {
                          draggingBoxIndex = index;
                          dragStart = details.globalPosition;
                        });
                      },
                      onPanUpdate: (details) {
                        if (draggingBoxIndex != null && dragStart != null) {
                          _moveBox(draggingBoxIndex!, details.globalPosition);
                        }
                      },
                      onPanEnd: (_) {
                        setState(() {
                          draggingBoxIndex = null;
                          dragStart = null;
                        });
                      },
                      onTap: () {
                        if (widget.isRemovingBox) {
                          setState(() {
                            boundingBoxes.removeAt(index);
                            widget.onRemoveBox(index);
                          });
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green, width: 2),
                          color: Colors.green.withAlpha((0.4 * 255)
                              .toInt()), // Change this to your preferred highlight color,
                        ),
                      ),
                    ),
                    Positioned(
                      child: Text(
                        '${index + 1}', // Display box number
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            /// Add a New Bounding Box
            if (widget.isAddingBox)
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      double boxWidth = 100, boxHeight = 100;

                      if (boundingBoxes.isNotEmpty) {
                        // Copy size from first box
                        boxWidth = boundingBoxes.first.width;
                        boxHeight = boundingBoxes.first.height;
                      }

                      final newBox = Rect.fromLTWH(
                        ((details.localPosition.dx - offsetX) / scaleX) -
                            (boxWidth / 2),
                        ((details.localPosition.dy - offsetY) / scaleY) -
                            (boxHeight / 2),
                        boxWidth,
                        boxHeight,
                      );

                      boundingBoxes.add(newBox);
                      widget.onNewBox(newBox);
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

            /// **Title (Upper Left)**
            if (widget.titleController.text.isNotEmpty)
              Positioned(
                top: 10, // Adjust as needed
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.titleController.text, // Display input text
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

            /// **Total Bounding Boxes Counter (Upper Right)**
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.7 * 255)
                      .toInt()), // Change this to your preferred highlight color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total Count: ${boundingBoxes.length}',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            /// **Timestamp (Lower Left)**
            if (timestamp.isNotEmpty)
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255)
                        .toInt()), // Change this to your preferred highlight color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.timestamp, // ✅ Display timestamp
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  /// Move a bounding box by the drag delta
  void _moveBox(int index, Offset newGlobalPosition) {
    if (dragStart == null) return;
    Offset delta = newGlobalPosition - dragStart!;

    setState(() {
      boundingBoxes[index] =
          boundingBoxes[index].translate(delta.dx / scaleX, delta.dy / scaleY);
      dragStart = newGlobalPosition;
    });
  }

  void _calculateScaling() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox != null && widget.imageForDrawing != null) {
      final originalWidth = widget.imageForDrawing!.width.toDouble();
      final originalHeight = widget.imageForDrawing!.height.toDouble();

      final displayedWidth = renderBox.size.width;
      final displayedHeight = renderBox.size.height;

      // Maintain aspect ratio
      double aspectRatio = originalWidth / originalHeight;
      double viewAspectRatio = displayedWidth / displayedHeight;

      if (viewAspectRatio > aspectRatio) {
        // Image is constrained by height
        scaleY = displayedHeight / originalHeight;
        scaleX = scaleY;
        offsetX = (displayedWidth - (originalWidth * scaleX)) / 2;
        offsetY = 0;
      } else {
        // Image is constrained by width
        scaleX = displayedWidth / originalWidth;
        scaleY = scaleX;
        offsetY = (displayedHeight - (originalHeight * scaleY)) / 2;
        offsetX = 0;
      }

      setState(() {
        scaleX = scaleX;
        scaleY = scaleY;
        offsetX = offsetX;
        offsetY = offsetY;
      });

      debugPrint(
          "ScaleX: $scaleX, ScaleY: $scaleY, OffsetX: $offsetX, OffsetY: $offsetY");
    }
  }
}

class ImageWithBoxesPainter extends CustomPainter {
  final ui.Image image;
  final List<Rect> boxes;
  final double scaleX, scaleY, offsetX, offsetY;

  ImageWithBoxesPainter({
    required this.image,
    required this.boxes,
    required this.scaleX,
    required this.scaleY,
    required this.offsetX,
    required this.offsetY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    canvas.drawImage(image, Offset(offsetX, offsetY), paint);

    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.green;

    for (int i = 0; i < boxes.length; i++) {
      final scaledBox = Rect.fromLTWH(
        boxes[i].left * scaleX + offsetX,
        boxes[i].top * scaleY + offsetY,
        boxes[i].width * scaleX,
        boxes[i].height * scaleY,
      );
      canvas.drawRect(scaledBox, boxPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
