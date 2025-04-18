import 'dart:io';
import 'package:flutter/material.dart';

class PhotoViewer extends StatefulWidget {
  final File imageFile;
  final List<Rect> editableBoundingBoxes;
  final bool isRemovingBox;
  final void Function(int index) onRemoveBox;
  final void Function(int index, Rect newBox) onMoveBox;
  final void Function(Rect newBox)? onNewBox; // Optional if adding a new box
  final bool isAddingBox; // Optional if you're adding boxes

  const PhotoViewer({
    required this.imageFile,
    required this.editableBoundingBoxes,
    required this.isRemovingBox,
    required this.onRemoveBox,
    required this.onMoveBox,
    this.onNewBox,
    this.isAddingBox = false,
    super.key,
  });

  @override
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  // Track the initial offset when dragging starts
  late Rect initialBox;
  late Offset dragStartPosition;
  int? draggingBoxIndex;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double factorX = constraints.maxWidth;
        final double factorY = constraints.maxHeight;

        return Stack(
          children: [
            Positioned.fill(
              child: Image.file(widget.imageFile, fit: BoxFit.fill),
            ),
            ...widget.editableBoundingBoxes.asMap().entries.map((entry) {
              final int index = entry.key;
              final Rect box = entry.value;

              // Apply scaling
              final double left = box.left * factorX;
              final double top = box.top * factorY;
              final double width = box.width * factorX;
              final double height = box.height * factorY;

              return Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: GestureDetector(
                  onTap: () {
                    if (widget.isRemovingBox) {
                      widget.onRemoveBox(index); // Remove box on tap if `isRemovingBox` is true
                    }
                  },
                  onPanStart: (details) {
                    // Save the initial position of the bounding box when drag starts
                    setState(() {
                      draggingBoxIndex = index;
                      initialBox = box;
                      dragStartPosition = details.localPosition;
                    });
                  },
                  onPanUpdate: (details) {
                    if (draggingBoxIndex == null) return;

                    final dx = details.localPosition.dx - dragStartPosition.dx;
                    final dy = details.localPosition.dy - dragStartPosition.dy;

                    final updatedLeft = initialBox.left + dx / factorX;
                    final updatedTop = initialBox.top + dy / factorY;

                    final updatedBox = Rect.fromLTWH(
                      updatedLeft,
                      updatedTop,
                      box.width,
                      box.height,
                    );

                    widget.onMoveBox(index, updatedBox); // Update box position
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                  ),
                ),
              );
            }),

            // Optionally, if you're adding a new box
            if (widget.isAddingBox && widget.onNewBox != null)
              Positioned(
                left: 50, // Example for new box placement (can be dynamic)
                top: 50,
                width: 100, // Example width
                height: 100, // Example height
                child: GestureDetector(
                  onTap: () {
                    final newBox = Rect.fromLTWH(50, 50, 100, 100); // Example new box
                    widget.onNewBox!(newBox); // Call the `onNewBox` callback
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
