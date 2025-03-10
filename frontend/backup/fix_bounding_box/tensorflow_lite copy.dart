// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:techtags/logic/tensorflow/photo_viewer.dart';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'dart:ui' as ui;

// class TensorflowLite extends StatefulWidget {
//   const TensorflowLite({super.key});

//   @override
//   State<TensorflowLite> createState() => _TensorflowLiteState();
// }

// class _TensorflowLiteState extends State<TensorflowLite> {
//   // Image galler and camera variables
//   File? _selectedImage;
//   late ImagePicker imagePicker;
//   // EXPLANATION about ui.Image:
//   // In Flutter, ui.Image (from dart:ui) is an in-memory representation of an image that allows direct manipulation in a Canvas via CustomPainter. Unlike Image.file or Image.asset, which are widgets for displaying images in the UI, ui.Image is specifically used for low-level drawing operations.
//   ui.Image? image_for_drawing;

//   // initialize object detector
//   late ObjectDetector objectDetector;
//   // detected objects array
//   List<DetectedObject> objects = [];
//   List<Rect> editableBoundingBoxes = []; // Editable list of bounding boxes
//   bool isAddingBox = false;
//   bool isRemovingBox = false;

//   @override
//   void initState() {
//     super.initState();
//     imagePicker = ImagePicker();
//     // USE DEFAULT PRETRAINED MODEL: load initial pretrained object detector
//     // EXPLANATION: https://pub.dev/packages/google_mlkit_object_detection#create-an-instance-of-objectdetector
//     final options = ObjectDetectorOptions(
//         mode: DetectionMode.single,
//         classifyObjects: true,
//         multipleObjects: true);
//     // initialize object detector inside initState (REQUIRED)
//     objectDetector = ObjectDetector(options: options);
//     // loadModel();
//   }

//   Future<void> loadImageForDrawing(File imageFile) async {
//     final data = await imageFile.readAsBytes();
//     final codec = await ui.instantiateImageCodec(data);
//     final frame = await codec.getNextFrame();
//     image_for_drawing = frame.image;
//   }

//   // OBJECT DETECTION
//   // loadModel() async {
//   //   final modelPath = await getModelPath('assets/ml/checkpoint_epoch_1.tflite');
//   //   final options = LocalObjectDetectorOptions(
//   //     mode: DetectionMode.single,
//   //     modelPath: modelPath,
//   //     classifyObjects: true,
//   //     multipleObjects: true,
//   //   );
//   //   objectDetector = ObjectDetector(options: options);
//   // }

//   Future<String> getModelPath(String asset) async {
//     final path = '${(await getApplicationSupportDirectory()).path}/$asset';
//     await Directory(dirname(path)).create(recursive: true);
//     final file = File(path);
//     if (!await file.exists()) {
//       final byteData = await rootBundle.load(asset);
//       await file.writeAsBytes(byteData.buffer
//           .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
//     }
//     return file.path;
//   }

//   doObjectDetection() async {
//     if (_selectedImage == null) {
//       print("No image selected!");
//       return;
//     }

//     print("Starting object detection...");
//     InputImage inputImage = InputImage.fromFile(_selectedImage!);

//     // Get detected objects
//     List<DetectedObject> detectedObjects =
//         await objectDetector.processImage(inputImage);
//     print("Objects detected: ${detectedObjects.length}");

//     // Print all bounding boxes BEFORE adding them to the list
//     print("\nBounding Boxes BEFORE Processing:");
//     for (int i = 0; i < detectedObjects.length; i++) {
//       final rect = detectedObjects[i].boundingBox;
//       print(
//           "Box $i: Left=${rect.left}, Top=${rect.top}, Right=${rect.right}, Bottom=${rect.bottom}");
//     }

//     setState(() {
//       objects = detectedObjects;
//       editableBoundingBoxes = detectedObjects
//           .map((obj) => obj.boundingBox)
//           .toList(); // ✅ Ensure ML-detected boxes are editable
//     });

//     // Print bounding boxes AFTER being added to editableBoundingBoxes
//     print("\nBounding Boxes AFTER Processing:");
//     for (int i = 0; i < editableBoundingBoxes.length; i++) {
//       final rect = editableBoundingBoxes[i];
//       print(
//           "Editable Box $i: Left=${rect.left}, Top=${rect.top}, Right=${rect.right}, Bottom=${rect.bottom}");
//     }

//     drawRectanglesAroundObjects();
//   }

//   Future<void> drawRectanglesAroundObjects() async {
//     if (_selectedImage == null) return;

//     // Read image bytes
//     Uint8List imageBytes = await _selectedImage!.readAsBytes();

//     // Decode image
//     ui.Image decodedImage = await decodeImageFromList(imageBytes);

//     setState(() {
//       image_for_drawing = decodedImage; // Now image is a ui.Image
//     });
//   }
//   // END

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   imageGallery() async {
//     XFile? pickedFile =
//         await imagePicker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _selectedImage = File(pickedFile.path);
//       setState(() {
//         _selectedImage;
//       });
//       doObjectDetection();
//     }
//   }

//   useCamera() async {
//     XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

//     if (pickedFile != null) {
//       _selectedImage = File(pickedFile.path);
//       setState(() {
//         _selectedImage;
//       });
//       doObjectDetection();
//     }
//   }

//   void reset() {
//     setState(() {
//       _selectedImage = null;
//       image_for_drawing = null; // Clear this to prevent null check errors
//       objects = []; // Also clear detected objects
//       isAddingBox = false;
//     });
//   }

//   void toggleAddingMode() {
//     setState(() {
//       isAddingBox = !isAddingBox;
//       if (isAddingBox) {
//         isRemovingBox = false; // Disable removing mode
//       }
//     });
//   }

//   void toggleRemovingMode() {
//     setState(() {
//       isRemovingBox = !isRemovingBox;
//       if (isRemovingBox) {
//         isAddingBox = false; // Disable adding mode
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: const Text("Tensorflow Lite")),
//         body: Container(
//           padding: EdgeInsets.all(16),
//           color: Colors.blue[300],
//           width: double.infinity,
//           height: double.infinity,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Container(
//                   width: double
//                       .infinity, // Makes the container expand horizontally
//                   margin: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors
//                         .white, // Adds a background to prevent weird scaling issues
//                   ),
//                   child: image_for_drawing == null
//                       ? Icon(
//                           Icons.add_photo_alternate_outlined,
//                           size: 120,
//                           color: Colors.grey[500],
//                         )
//                       : PhotoViewer(
//                           imageFile: _selectedImage!,
//                           imageForDrawing: image_for_drawing,
//                           editableBoundingBoxes: editableBoundingBoxes,
//                           onNewBox: (Rect box) {
//                             setState(() {
//                               editableBoundingBoxes.add(box);
//                             });
//                           },
//                           onRemoveBox: (int index) {
//                             setState(() {
//                               editableBoundingBoxes.removeAt(index);
//                             });
//                           },
//                           isAddingBox: isAddingBox,
//                           isRemovingBox: isRemovingBox,
//                         ),
//                 ),
//               ),
//               if (_selectedImage == null) ...[
//                 ElevatedButton(
//                   onPressed: imageGallery,
//                   onLongPress: useCamera,
//                   child: const Text("Choose/Capture"),
//                 ),
//               ],
//               if (_selectedImage != null) ...[
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextField(
//                     decoration: InputDecoration(
//                       hintText: "Enter file name",
//                       filled: true,
//                       fillColor: Colors.white,
//                       border: OutlineInputBorder(),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     IconButton(icon: Icon(Icons.refresh), onPressed: reset),
//                     IconButton(
//                       icon: Icon(Icons.add), // Change dynamically
//                       onPressed: toggleAddingMode,
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close),
//                       onPressed: toggleRemovingMode,
//                     ),
//                     IconButton(icon: Icon(Icons.save), onPressed: () {}),
//                   ],
//                 ),
//               ]
//             ],
//           ),
//         ));
//   }
// }
