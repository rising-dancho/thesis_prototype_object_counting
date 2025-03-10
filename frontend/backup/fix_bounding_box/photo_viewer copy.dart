// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:techtags/logic/tensorflow/object_painter.dart';
// import 'package:photo_view/photo_view.dart';
// import 'dart:ui' as ui; // Import ui for image handling
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';

// class PhotoViewer extends StatefulWidget {
//   final File imageFile;
//   final ui.Image? imageForDrawing;
//   final List objects;
//   final List<Rect> editableBoundingBoxes;
//   final Function(Rect) onNewBox;
//   final bool isAddingBox;
//   final bool isRemovingBox;

//   const PhotoViewer({
//     super.key,
//     required this.imageFile,
//     required this.imageForDrawing,
//     required this.objects,
//     required this.editableBoundingBoxes,
//     required this.onNewBox,
//     required this.isAddingBox,
//     required this.isRemovingBox,
//   });
//   @override
//   State<PhotoViewer> createState() => _PhotoViewerState();
// }

// class _PhotoViewerState extends State<PhotoViewer> {
//   Offset? boxStart;
//   Offset? boxEnd;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTapUp: (TapUpDetails details) {
//         if (widget.imageForDrawing == null) return;

//         // Get render box size
//         RenderBox renderBox = context.findRenderObject() as RenderBox;
//         Size widgetSize = renderBox.size;

//         // Calculate image scale and offset
//         double imageAspect =
//             widget.imageForDrawing!.width / widget.imageForDrawing!.height;
//         double widgetAspect = widgetSize.width / widgetSize.height;

//         double scaleX, scaleY, offsetX = 0, offsetY = 0;

//         if (imageAspect > widgetAspect) {
//           // Image is wider -> fit width
//           scaleX = widget.imageForDrawing!.width / widgetSize.width;
//           scaleY = scaleX;
//           offsetY =
//               (widgetSize.height - (widget.imageForDrawing!.height / scaleY)) /
//                   2;
//         } else {
//           // Image is taller -> fit height
//           scaleY = widget.imageForDrawing!.height / widgetSize.height;
//           scaleX = scaleY;
//           offsetX =
//               (widgetSize.width - (widget.imageForDrawing!.width / scaleX)) / 2;
//         }

//         // Convert tap coordinates to image space
//         double imageX = (details.localPosition.dx - offsetX) * scaleX;
//         double imageY = (details.localPosition.dy - offsetY) * scaleY;

//         if (imageX < 0 ||
//             imageY < 0 ||
//             imageX > widget.imageForDrawing!.width ||
//             imageY > widget.imageForDrawing!.height) {
//           return; // Tap was outside the image area
//         }

//         setState(() {
//           if (widget.isRemovingBox) {
//             // ✅ Remove box if tapped inside ANY bounding box
//             widget.editableBoundingBoxes
//                 .removeWhere((box) => box.contains(Offset(imageX, imageY)));
//           } else if (widget.isAddingBox) {
//             // ✅ Add new box if in adding mode
//             double boxWidth = widget.imageForDrawing!.width * 0.18;
//             double boxHeight = widget.imageForDrawing!.height * 0.18;

//             Rect newBox = Rect.fromLTWH(
//               imageX - (boxWidth / 2),
//               imageY - (boxHeight / 2),
//               boxWidth,
//               boxHeight,
//             );

//             widget.onNewBox(newBox);
//           }
//         });
//       },
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: PhotoView.customChild(
//           minScale: PhotoViewComputedScale.contained,
//           maxScale: PhotoViewComputedScale.covered * 2.0,
//           backgroundDecoration: BoxDecoration(color: Colors.white),
//           child: widget.imageForDrawing == null
//               ? Center(child: CircularProgressIndicator())
//               : CustomPaint(
//                   painter: ObjectPainter(
//                     objectList: widget.objects.cast<DetectedObject>(),
//                     imageFile: widget.imageForDrawing!,
//                     editableBoundingBoxes: widget.editableBoundingBoxes,
//                   ),
//                 ),
//         ),
//       ),
//     );
//   }
// }
