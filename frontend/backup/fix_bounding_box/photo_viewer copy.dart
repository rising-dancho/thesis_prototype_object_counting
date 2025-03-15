// import 'dart:io';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:photo_view/photo_view.dart';

// class PhotoViewer extends StatefulWidget {
//   final File imageFile;
//   final ui.Image? imageForDrawing; // ✅ Add this parameter
//   final List<Rect> editableBoundingBoxes;
//   final Function(Rect) onNewBox;
//   final Function(int) onRemoveBox;
//   final bool isAddingBox;
//   final bool isRemovingBox;

//   const PhotoViewer({
//     super.key,
//     required this.imageFile,
//     required this.imageForDrawing,
//     required this.editableBoundingBoxes,
//     required this.onNewBox,
//     required this.onRemoveBox,
//     required this.isAddingBox,
//     required this.isRemovingBox,
//   });

//   @override
//   State<PhotoViewer> createState() => _PhotoViewerState();
// }

// class _PhotoViewerState extends State<PhotoViewer> {
//   late List<Rect> boundingBoxes;
//   int? draggingBoxIndex;
//   Offset? dragStart;

//   double scaleX = 1.0; // ✅ Scaling factors
//   double scaleY = 1.0;
//   double offsetX = 0.0; // ✅ Offset for centering image
//   double offsetY = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     boundingBoxes = List.from(widget.editableBoundingBoxes);
//     WidgetsBinding.instance
//         .addPostFrameCallback((_) => _calculateScaling()); // ✅ Run after layout
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         return Stack(
//           children: [
//             /// Background Image Viewer
//             ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: PhotoView(
//                 imageProvider: FileImage(widget.imageFile),
//                 minScale: PhotoViewComputedScale.contained,
//                 maxScale: PhotoViewComputedScale.covered * 2.0,
//                 backgroundDecoration: BoxDecoration(color: Colors.white),
//               ),
//             ),

//             /// Bounding Boxes Over the Image
//             // Bounding Boxes Over the Image
//             ...boundingBoxes.asMap().entries.map((entry) {
//               int index = entry.key;
//               Rect box = entry.value;

//               return Positioned(
//                 left: box.left * scaleX + offsetX,
//                 top: box.top * scaleY + offsetY,
//                 width: box.width * scaleX,
//                 height: box.height * scaleY,
//                 child: Stack(
//                   alignment: Alignment.center, // Center the text inside the box
//                   children: [
//                     GestureDetector(
//                       onPanStart: (details) {
//                         setState(() {
//                           draggingBoxIndex = index;
//                           dragStart = details.globalPosition;
//                         });
//                       },
//                       onPanUpdate: (details) {
//                         if (draggingBoxIndex != null && dragStart != null) {
//                           _moveBox(draggingBoxIndex!, details.globalPosition);
//                         }
//                       },
//                       onPanEnd: (_) {
//                         setState(() {
//                           draggingBoxIndex = null;
//                           dragStart = null;
//                         });
//                       },
//                       onTap: () {
//                         if (widget.isRemovingBox) {
//                           setState(() {
//                             boundingBoxes.removeAt(index);
//                             widget.onRemoveBox(index);
//                           });
//                         }
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border: Border.all(color: Colors.green, width: 2),
//                           color: Colors.green.withOpacity(0.2),
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       child: Text(
//                         '${index + 1}', // Display box number (1-based index)
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           // backgroundColor: Colors.black.withOpacity(0.5),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),

//             /// Add a New Bounding Box
//             if (widget.isAddingBox)
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTapDown: (details) {
//                     setState(() {
//                       double boxWidth = 100, boxHeight = 100; // Default size

//                       if (boundingBoxes.isNotEmpty) {
//                         // Copy the size of the first detected box
//                         boxWidth = boundingBoxes.first.width;
//                         boxHeight = boundingBoxes.first.height;
//                       }

//                       final newBox = Rect.fromLTWH(
//                         ((details.localPosition.dx - offsetX) / scaleX) -
//                             (boxWidth / 2), // Centered X
//                         ((details.localPosition.dy - offsetY) / scaleY) -
//                             (boxHeight / 2), // Centered Y
//                         boxWidth, // Match existing box width
//                         boxHeight, // Match existing box height
//                       );

//                       boundingBoxes.add(newBox);
//                       widget.onNewBox(newBox);
//                     });
//                   },
//                   child: Container(color: Colors.transparent),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }

//   /// Move a bounding box by the drag delta
//   void _moveBox(int index, Offset newGlobalPosition) {
//     if (dragStart == null) return;
//     Offset delta = newGlobalPosition - dragStart!;

//     setState(() {
//       boundingBoxes[index] =
//           boundingBoxes[index].translate(delta.dx / scaleX, delta.dy / scaleY);
//       dragStart = newGlobalPosition;
//     });
//   }

//   void _calculateScaling() {
//     final renderBox = context.findRenderObject() as RenderBox?;
//     if (renderBox != null && widget.imageForDrawing != null) {
//       final originalWidth = widget.imageForDrawing!.width.toDouble();
//       final originalHeight = widget.imageForDrawing!.height.toDouble();

//       final displayedWidth = renderBox.size.width;
//       final displayedHeight = renderBox.size.height;

//       // Maintain aspect ratio
//       double aspectRatio = originalWidth / originalHeight;
//       double viewAspectRatio = displayedWidth / displayedHeight;

//       if (viewAspectRatio > aspectRatio) {
//         // Image is constrained by height
//         scaleY = displayedHeight / originalHeight;
//         scaleX = scaleY;
//         offsetX = (displayedWidth - (originalWidth * scaleX)) / 2;
//         offsetY = 0;
//       } else {
//         // Image is constrained by width
//         scaleX = displayedWidth / originalWidth;
//         scaleY = scaleX;
//         offsetY = (displayedHeight - (originalHeight * scaleY)) / 2;
//         offsetX = 0;
//       }

//       setState(() {
//         scaleX = scaleX;
//         scaleY = scaleY;
//         offsetX = offsetX;
//         offsetY = offsetY;
//       });

//       print(
//           "ScaleX: $scaleX, ScaleY: $scaleY, OffsetX: $offsetX, OffsetY: $offsetY");
//     }
//   }
// }
