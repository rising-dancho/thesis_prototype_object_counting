// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'dart:ui' as ui;

// void main() {
//   runApp(const MyHomePage());
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   late ImagePicker imagePicker;
//   File? _image;
//   ui.Image? image_for_drawing;
//   // initialize object detector
//   late ObjectDetector objectDetector;

//   @override
//   void initState() {
//     super.initState();
//     imagePicker = ImagePicker();
//     // USE DEFAULT PRETRAINED MODEL: load initial pretrained object detector
//     final options = ObjectDetectorOptions(
//         mode: DetectionMode.single,
//         classifyObjects: true,
//         multipleObjects: true);
//     objectDetector = ObjectDetector(options: options);
//     // loadModel();
//   }

//   loadModel() async {
//     final modelPath = await getModelPath('assets/ml/checkpoint_epoch_1.tflite');
//     final options = LocalObjectDetectorOptions(
//       mode: DetectionMode.single,
//       modelPath: modelPath,
//       classifyObjects: true,
//       multipleObjects: true,
//     );
//     objectDetector = ObjectDetector(options: options);
//   }

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

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   _imgFromCamera() async {
//     XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       doObjectDetection();
//     }
//   }

//   _imgFromGallery() async {
//     XFile? pickedFile =
//         await imagePicker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       _image = File(pickedFile.path);
//       doObjectDetection();
//     }
//   }

//   // detected objects array
//   List<DetectedObject> objects = [];
//   doObjectDetection() async {
//     if (_image == null) {
//       debugPrint("No image selected!");
//       return;
//     }

//     debugPrint("Starting object detection...");
//     InputImage inputImage = InputImage.fromFile(_image!);

//     objects = await objectDetector.processImage(inputImage);
//     debugPrint("Objects detected: ${objects.length}");

//     for (DetectedObject detectedObject in objects) {
//       final rect = detectedObject.boundingBox;
//       final trackingId = detectedObject.trackingId;

//       for (Label label in detectedObject.labels) {
//         debugPrint(
//             'RESPONSE: ${label.text} ${label.confidence} $rect $trackingId!!!');
//       }
//     }

//     setState(() {
//       _image;
//     });
//     drawRectanglesAroundObjects();
//   }

//   Future<void> drawRectanglesAroundObjects() async {
//     if (_image == null) return;

//     // Read image bytes
//     Uint8List imageBytes = await _image!.readAsBytes();

//     // Decode image
//     ui.Image decodedImage = await decodeImageFromList(imageBytes);

//     setState(() {
//       image_for_drawing = decodedImage; // Now image is a ui.Image
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//           body: Container(
//         // decoration: const BoxDecoration(
//         //   image: DecorationImage(
//         //       image: AssetImage('images/bg.jpg'), fit: BoxFit.cover),
//         // ),
//         child: Column(
//           children: [
//             const SizedBox(
//               width: 100,
//             ),
//             Container(
//               margin: const EdgeInsets.only(top: 100),
//               child: Stack(children: <Widget>[
//                 Center(
//                   child: ElevatedButton(
//                     onPressed: _imgFromGallery,
//                     onLongPress: _imgFromCamera,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent),
//                     child: Container(
//                       width: 350,
//                       height: 350,
//                       margin: const EdgeInsets.only(
//                         top: 45,
//                       ),
//                       child: image_for_drawing != null
//                           ? Center(
//                               child: FittedBox(
//                                 child: SizedBox(
//                                   width: image_for_drawing?.width.toDouble() ?? 0,
//                                   height: image_for_drawing?.height.toDouble() ?? 0,
//                                   child: CustomPaint(
//                                     painter: ObjectPainter(
//                                         objectList: objects, imageFile: image_for_drawing),
//                                   ),
//                                 ),
//                               ),
//                             )
//                           : Container(
//                               color: Colors.pinkAccent,
//                               width: 350,
//                               height: 350,
//                               child: const Icon(
//                                 Icons.camera_alt,
//                                 color: Colors.black,
//                                 size: 53,
//                               ),
//                             ),
//                     ),
//                   ),
//                 ),
//               ]),
//             ),
//           ],
//         ),
//       )),
//     );
//   }
// }

// class ObjectPainter extends CustomPainter {
//   List<DetectedObject> objectList;
//   dynamic imageFile;
//   ObjectPainter({required this.objectList, @required this.imageFile});

//   @override
//   void paint(Canvas canvas, Size size) {
//     if (imageFile != null) {
//       canvas.drawImage(imageFile, Offset.zero, Paint());
//     }
//     Paint paint = Paint();
//     paint.color = Colors.green;
//     paint.style = PaintingStyle.stroke;
//     paint.strokeWidth = 6;

//     for (DetectedObject rectangle in objectList) {
//       canvas.drawRect(rectangle.boundingBox, paint);
//       var list = rectangle.labels;
//       for (Label label in list) {
//         debugPrint("${label.text}   ${label.confidence.toStringAsFixed(2)}");
//         TextSpan span = TextSpan(
//             text: "${label.text} ${label.confidence.toStringAsFixed(2)}",
//             style: const TextStyle(fontSize: 25, color: Colors.blue));
//         TextPainter tp = TextPainter(
//             text: span,
//             textAlign: TextAlign.left,
//             textDirection: TextDirection.ltr);
//         tp.layout();
//         tp.paint(canvas,
//             Offset(rectangle.boundingBox.left, rectangle.boundingBox.top));
//         break;
//       }
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
