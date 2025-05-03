import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tectags/models/detected_objects_model.dart';

class PhotoViewer extends StatefulWidget {
  final File imageFile;
  final List<DetectedObject> editableBoundingBoxes;
  final void Function(int index) onRemoveBox;
  final void Function(int index, DetectedObject newBox) onMoveBox;
  final void Function(DetectedObject newBox)?
      onNewBox; // Optional if adding a new box
  final bool isAddingBox; // Optional if you're adding boxes
  final bool isRemovingBox;
  final bool showBoundingInfo;
  final String timestamp;
  final TextEditingController titleController;

  const PhotoViewer({
    required this.imageFile,
    required this.editableBoundingBoxes,
    required this.onRemoveBox,
    required this.onMoveBox,
    this.onNewBox,
    this.isAddingBox = false,
    this.isRemovingBox = false,
    this.showBoundingInfo = true,
    required this.timestamp,
    required this.titleController,
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _PhotoViewerState createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  // Track the initial offset when dragging starts
  late Rect initialBox;
  late Offset dragStartPosition;
  int? draggingBoxIndex;

  @override
  Widget build(BuildContext context) {
    // FOR CHANGING THE COLOR OF BOUNDING BOX BASED ON CONFIDENCE SCORE
    const upperLimit = 0.50;

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
              final DetectedObject detectedObject = entry.value;
              final Rect box =
                  detectedObject.rect; // Accessing rect from DetectedObject

              // ENFORCE A MINIMUM SIZE FOR THE BOUNDING BOXES
              //- so that numbers can still display properly even when the detected object is smaller than the number
              const double minBoxSize = 20.0;
              // Apply scaling
              final double left = box.left * factorX;
              final double top = box.top * factorY;

              // ENFORCING A MINIMUM WIDTH AND HEIGHT
              final double width =
                  (box.width * factorX).clamp(minBoxSize, double.infinity);
              final double height =
                  (box.height * factorY).clamp(minBoxSize, double.infinity);

              return Positioned(
                left: left,
                top: top,
                width: width,
                height: height,
                child: GestureDetector(
                  onTap: () {
                    if (widget.isRemovingBox) {
                      widget.onRemoveBox(index);
                    }
                  },
                  onPanStart: (details) {
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

                    widget.onMoveBox(
                        index,
                        DetectedObject(
                            rect: updatedBox,
                            label: detectedObject.label,
                            score: detectedObject.score,
                            color: detectedObject.color));
                  },
                  onPanEnd: (_) {
                    setState(() {
                      draggingBoxIndex = null;
                    });
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (widget
                          .showBoundingInfo) // Show the bounding box background only if toggled
                        Container(
                          // decoration: BoxDecoration(
                          //   border: Border.all(
                          //     color: detectedObject.score < upperLimit
                          //         ? Colors.red
                          //         : Colors.lightGreen,
                          //     width: 2,
                          //   ),
                          // ),
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: detectedObject.score < upperLimit
                                    ? Colors.red
                                    : Colors.lightGreen,
                                width: 2,
                              ),
                              // color: Colors.lightGreen
                              //     .withAlpha((0.4 * 255).toInt()),
                              color: detectedObject.score < upperLimit
                                  ? Colors.red.withAlpha((0.4 * 255).toInt())
                                  : Colors.lightGreen
                                      .withAlpha((0.4 * 255).toInt())),
                          child: widget.showBoundingInfo
                              ? Align(
                                  alignment: Alignment.topLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                  ),
                                )
                              : null,
                        ),
                      if (!widget
                          .showBoundingInfo) // Transparent container if info is hidden
                        Container(color: Colors.transparent),

                      // Always show the index number
                      Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: widget.showBoundingInfo
                              ? Colors.white
                              : Colors.yellowAccent,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // Only show label & score when toggled
                      if (widget.showBoundingInfo)
                        Positioned(
                          top: 5,
                          left: 5,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 3),
                            child: Text(
                              '${detectedObject.label}${(detectedObject.score * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),

            // For adding a new box
            if (widget.isAddingBox && widget.onNewBox != null)
              Positioned.fill(
                child: GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition =
                          renderBox.globalToLocal(details.globalPosition);

                      double defaultBoxWidth = 0.1; // 10% width of image
                      double defaultBoxHeight = 0.1; // 10% height of image

                      if (widget.editableBoundingBoxes.isNotEmpty) {
                        defaultBoxWidth =
                            widget.editableBoundingBoxes.first.rect.width;
                        defaultBoxHeight =
                            widget.editableBoundingBoxes.first.rect.height;
                      }

                      // Convert relative sizes to absolute pixel values if necessary
                      final double absBoxWidth = defaultBoxWidth * factorX;
                      final double absBoxHeight = defaultBoxHeight * factorY;

                      // Apply minimum size constraints
                      final double minWidth = 40.0;
                      final double minHeight = 30.0;
                      final double adjustedWidth =
                          absBoxWidth < minWidth ? minWidth : absBoxWidth;
                      final double adjustedHeight =
                          absBoxHeight < minHeight ? minHeight : absBoxHeight;

                      // Convert back to scaled values for Rect (relative to factorX/factorY)
                      final newBox = Rect.fromLTWH(
                        (localPosition.dx / factorX) -
                            (adjustedWidth / factorX / 2),
                        (localPosition.dy / factorY) -
                            (adjustedHeight / factorY / 2),
                        adjustedWidth / factorX,
                        adjustedHeight / factorY,
                      );

                      // Count the frequency of each label
                      final labelFrequency = <String, int>{};
                      for (var box in widget.editableBoundingBoxes) {
                        labelFrequency[box.label] =
                            (labelFrequency[box.label] ?? 0) + 1;
                      }

                      String mostCommonLabel = 'New Object'; // fallback
                      if (labelFrequency.isNotEmpty) {
                        mostCommonLabel = labelFrequency.entries
                            .reduce((a, b) => a.value >= b.value ? a : b)
                            .key;
                      }

                      final newDetectedObject = DetectedObject(
                          rect: newBox,
                          label: mostCommonLabel,
                          score: upperLimit,
                          color: Colors.lightGreen);

                      widget.onNewBox!(newDetectedObject);
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),

            // Title (Upper Left)
            if (widget.titleController.text.isNotEmpty)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.titleController.text,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),

            // Total Count (Upper Right)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha((0.7 * 255).toInt()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Total Count: ${widget.editableBoundingBoxes.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),

            // Timestamp (Lower Left)
            if (widget.timestamp.isNotEmpty)
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.7 * 255).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.timestamp,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
