// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:tectags/models/detected_objects_model.dart';

// class PhotoViewer extends StatefulWidget {
//   final File imageFile;
//   final List<DetectedObject> editableBoundingBoxes;
//   final bool isRemovingBox;
//   final void Function(int index) onRemoveBox;
//   final void Function(int index, DetectedObject newBox) onMoveBox;
//   final void Function(DetectedObject newBox)?
//       onNewBox; // Optional if adding a new box
//   final bool isAddingBox; // Optional if you're adding boxes
//   final String timestamp;
//   final TextEditingController titleController;

//   const PhotoViewer({
//     required this.imageFile,
//     required this.editableBoundingBoxes,
//     required this.onRemoveBox,
//     required this.onMoveBox,
//     this.onNewBox,
//     this.isAddingBox = false,
//     this.isRemovingBox = false,
//     required this.timestamp,
//     required this.titleController,
//     super.key,
//   });

//   @override
//   // ignore: library_private_types_in_public_api
//   _PhotoViewerState createState() => _PhotoViewerState();
// }

// class _PhotoViewerState extends State<PhotoViewer> {
//   // Track the initial offset when dragging starts
//   late Rect initialBox;
//   late Offset dragStartPosition;
//   int? draggingBoxIndex;

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double factorX = constraints.maxWidth;
//         final double factorY = constraints.maxHeight;

//         return Stack(
//           children: [
//             Positioned.fill(
//               child: Image.file(widget.imageFile, fit: BoxFit.fill),
//             ),
//             ...widget.editableBoundingBoxes.asMap().entries.map((entry) {
//               final int index = entry.key;
//               final DetectedObject detectedObject = entry.value;
//               final Rect box =
//                   detectedObject.rect; // Accessing rect from DetectedObject

//               // Apply scaling
//               final double left = box.left * factorX;
//               final double top = box.top * factorY;
//               final double width = box.width * factorX;
//               final double height = box.height * factorY;

//               return Positioned(
//                 left: left,
//                 top: top,
//                 width: width,
//                 height: height,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () {
//                         if (widget.isRemovingBox) {
//                           widget.onRemoveBox(index);
//                         }
//                       },
//                       onPanStart: (details) {
//                         setState(() {
//                           draggingBoxIndex = index;
//                           initialBox = box;
//                           dragStartPosition = details.localPosition;
//                         });
//                       },
//                       onPanUpdate: (details) {
//                         if (draggingBoxIndex == null) return;

//                         final dx =
//                             details.localPosition.dx - dragStartPosition.dx;
//                         final dy =
//                             details.localPosition.dy - dragStartPosition.dy;

//                         final updatedLeft = initialBox.left + dx / factorX;
//                         final updatedTop = initialBox.top + dy / factorY;

//                         final updatedBox = Rect.fromLTWH(
//                           updatedLeft,
//                           updatedTop,
//                           box.width,
//                           box.height,
//                         );

//                         widget.onMoveBox(
//                             index,
//                             DetectedObject(
//                               rect: updatedBox,
//                               label: detectedObject.label,
//                               score: detectedObject.score,
//                             ));
//                       },
//                       onPanEnd: (_) {
//                         setState(() {
//                           draggingBoxIndex = null;
//                         });
//                       },
//                       child: Container(
//                         decoration: BoxDecoration(
//                           border:
//                               Border.all(color: Colors.lightGreen, width: 2),
//                           color:
//                               Colors.lightGreen.withAlpha((0.4 * 255).toInt()),
//                         ),
//                       ),
//                     ),
//                     Text(
//                       '${index + 1}',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     // Optionally display the label or score
//                     Positioned(
//                       top: 5,
//                       left: 5,
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 6, vertical: 3),
//                         child: Text(
//                           '${detectedObject.label}${(detectedObject.score * 100).toStringAsFixed(1)}%',
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }),

//             // For adding a new box
//             if (widget.isAddingBox && widget.onNewBox != null)
//               Positioned.fill(
//                 child: GestureDetector(
//                   onTapDown: (details) {
//                     setState(() {
//                       final RenderBox renderBox =
//                           context.findRenderObject() as RenderBox;
//                       final localPosition =
//                           renderBox.globalToLocal(details.globalPosition);

//                       double boxWidth = 0.1; // 10% width
//                       double boxHeight = 0.1; // 10% height

//                       if (widget.editableBoundingBoxes.isNotEmpty) {
//                         boxWidth =
//                             widget.editableBoundingBoxes.first.rect.width;
//                         boxHeight =
//                             widget.editableBoundingBoxes.first.rect.height;
//                       }

//                       final newBox = Rect.fromLTWH(
//                         (localPosition.dx / factorX) - (boxWidth / 2),
//                         (localPosition.dy / factorY) - (boxHeight / 2),
//                         boxWidth,
//                         boxHeight,
//                       );

//                       // Create DetectedObject and pass it
//                       final newDetectedObject = DetectedObject(
//                         rect: newBox,
//                         label:
//                             'New Object', // You can add logic to choose the label
//                         score: 0.0, // You can also adjust the score as needed
//                       );

//                       widget.onNewBox!(newDetectedObject);
//                     });
//                   },
//                   child: Container(color: Colors.transparent),
//                 ),
//               ),

//             // Title (Upper Left)
//             if (widget.titleController.text.isNotEmpty)
//               Positioned(
//                 top: 10,
//                 left: 10,
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: const Color.fromRGBO(0, 0, 0, 0.7),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.titleController.text,
//                     style: const TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                 ),
//               ),

//             // Total Count (Upper Right)
//             Positioned(
//               top: 10,
//               right: 10,
//               child: Container(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withAlpha((0.7 * 255).toInt()),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   'Total Count: ${widget.editableBoundingBoxes.length}',
//                   style: const TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//               ),
//             ),

//             // Timestamp (Lower Left)
//             if (widget.timestamp.isNotEmpty)
//               Positioned(
//                 bottom: 10,
//                 left: 10,
//                 child: Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withAlpha((0.7 * 255).toInt()),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     widget.timestamp,
//                     style: const TextStyle(color: Colors.white, fontSize: 14),
//                   ),
//                 ),
//               ),
//           ],
//         );
//       },
//     );
//   }
// }
