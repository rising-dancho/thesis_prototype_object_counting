// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:screenshot/screenshot.dart';
// import 'package:tectags/logic/pytorch/photo_viewer.dart';
// // import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
// import 'package:flutter/services.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:path/path.dart';
// import 'package:tectags/models/detected_objects_model.dart';
// import 'dart:ui' as ui;

// import 'package:tectags/screens/navigation/side_menu.dart';
// import 'package:tectags/services/api.dart';

// // SAVING IMAGE TO GALLERY [import dependencies]
// import 'package:saver_gallery/saver_gallery.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:tectags/services/shared_prefs_service.dart';
// import 'package:intl/intl.dart';

// // PYTORCH
// import 'package:pytorch_lite/pytorch_lite.dart';

// class PytorchMobile extends StatefulWidget {
//   const PytorchMobile({super.key});

//   @override
//   State<PytorchMobile> createState() => _PytorchMobileState();
// }

// class _PytorchMobileState extends State<PytorchMobile> {
//   ScreenshotController screenshotController = ScreenshotController();
//   // Image galler and camera variables
//   File? _selectedImage;
//   late ImagePicker imagePicker;
//   // EXPLANATION about ui.Image:
//   // In Flutter, ui.Image (from dart:ui) is an in-memory representation of an image that allows direct manipulation in a Canvas via CustomPainter. Unlike Image.file or Image.asset, which are widgets for displaying images in the UI, ui.Image is specifically used for low-level drawing operations.
//   ui.Image? imageForDrawing;

//   // FOR LABELS
//   String timestamp = "";
//   // variable for whatever is typed in the TextField
//   final TextEditingController titleController = TextEditingController();

//   // FOR THE DROPDOWN
//   List<String> stockList = [];
//   String? _selectedStock;

//   // PYTORCH OBJECT DETECTION
//   // initialize object detector
//   late ModelObjectDetection _objectModelYoloV8;
//   // List<Rect> editableBoundingBoxes = []; // Editable list of bounding boxes
//   List<DetectedObject> editableBoundingBoxes = [];
//   bool isAddingBox = false;
//   bool isRemovingBox = false;
//   // for inference speed checking
//   String? textToShow;

//   @override
//   void initState() {
//     super.initState();
//     loadStockData();
//     imagePicker = ImagePicker();
//     _requestPermission(); // [gain permission]
//     loadModel();
//   }

//   Future loadModel() async {
//     String pathObjectDetectionModelYolov8 = "assets/models/best.torchscript";
//     String pathCustomLabels = "assets/labels/custom_labels.txt";

//     try {
//       _objectModelYoloV8 = await PytorchLite.loadObjectDetectionModel(
//         pathObjectDetectionModelYolov8,
//         7,
//         640,
//         640,
//         labelPath: pathCustomLabels,
//         objectDetectionModelType: ObjectDetectionModelType.yolov8,
//       );
//     } catch (e) {
//       if (e is PlatformException) {
//         print("only supported for android, Error is $e");
//       } else {
//         print("Error is $e");
//       }
//     }
//   }

//   Future doObjectDetection() async {
//     if (_selectedImage == null) {
//       debugPrint("No image selected!");
//       return;
//     }

//     debugPrint("Running YOLOv8 object detection...");

//     Stopwatch stopwatch = Stopwatch()..start();
//     debugPrint('Detection completed in ${stopwatch.elapsed.inMilliseconds} ms');
//     List<ResultObjectDetection?> objDetect =
//         await _objectModelYoloV8.getImagePrediction(
//       await _selectedImage!.readAsBytes(),
//       minimumScore: 0.1,
//       iOUThreshold: 0.3,
//     );
//     textToShow = inferenceTimeAsString(stopwatch);

//     debugPrint('object executed in ${stopwatch.elapsed.inMilliseconds} ms');
//     for (var element in objDetect) {
//       if (element != null) {
//         debugPrint({
//           "score": element.score,
//           "className": element.className,
//           "class": element.classIndex,
//           "rect": {
//             "left": element.rect.left,
//             "top": element.rect.top,
//             "width": element.rect.width,
//             "height": element.rect.height,
//             "right": element.rect.right,
//             "bottom": element.rect.bottom,
//           },
//         }.toString());
//       }
//     }

//     setState(() {
//       editableBoundingBoxes = objDetect
//           .where((e) => e != null)
//           .map((e) => DetectedObject(
//                 rect: Rect.fromLTWH(
//                     e!.rect.left, e.rect.top, e.rect.width, e.rect.height),
//                 label: e.className ?? 'Unknown',
//                 score: e.score,
//               ))
//           .toList();

//       debugPrint("📌 DETECTED COUNT: ${editableBoundingBoxes.length}");
//     });
//     drawRectanglesAroundObjects();
//   }

//   String inferenceTimeAsString(Stopwatch stopwatch) =>
//       "Inference Took ${stopwatch.elapsed.inMilliseconds} ms";

//   /// Requests necessary permissions based on the platform. [gain permission]
//   Future<void> _requestPermission() async {
//     bool statuses;
//     if (Platform.isAndroid) {
//       final deviceInfoPlugin = DeviceInfoPlugin();
//       final deviceInfo = await deviceInfoPlugin.androidInfo;
//       final sdkInt = deviceInfo.version.sdkInt;
//       statuses =
//           sdkInt < 29 ? await Permission.storage.request().isGranted : true;
//     } else {
//       statuses = await Permission.photosAddOnly.request().isGranted;
//     }
//     debugPrint('Permission Request Result: $statuses');
//   }

//   imageGallery() async {
//     XFile? pickedFile =
//         await imagePicker.pickImage(source: ImageSource.gallery);

//     if (pickedFile != null) {
//       _selectedImage = File(pickedFile.path);
//       setState(() {
//         _selectedImage;
//         timestamp = DateFormat('MMM d, y • hh:mm a')
//             .format(DateTime.parse(DateTime.now().toString()).toLocal());
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
//         timestamp = DateFormat('MMM d, y • hh:mm a')
//             .format(DateTime.parse(DateTime.now().toString()).toLocal());
//       });
//       doObjectDetection();
//     }
//   }

//   // STOCK DATA FOR THE DROPDOWN
//   Future<void> loadStockData() async {
//     var fetchedStocks = await API.fetchStockFromMongoDB();

//     if (fetchedStocks != null) {
//       setState(() {
//         stockList = fetchedStocks.keys.toList();
//       });
//     }
//   }

//   /// **Save Screenshot to Gallery**
//   /// THIS WOULD ALSO SAVE COUNTED OBJECT TO THE DATABASE (WILL SHOW IN THE ACTIVITY LOGS)
//   Future<void> saveImage(BuildContext context) async {
//     try {
//       // ✅ PREVENT SAVING IF THE STOCK SELECTION DROPDOWN IS EMPTY
//       if (_selectedStock == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Please select a stock before saving"),
//             duration: Duration(milliseconds: 1000),
//           ),
//         );
//         return;
//       }

//       final Uint8List? screenShot = await screenshotController.capture();
//       if (!mounted) return;

//       if (screenShot == null) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Failed to capture screenshot")),
//         );
//         return;
//       }

//       final result = await SaverGallery.saveImage(
//         screenShot,
//         fileName: "screenshot_${DateTime.now().millisecondsSinceEpoch}.png",
//         skipIfExists: false,
//       ); // [save your actual image] screenShot is my image

//       debugPrint("Result: $result"); // [check structure of: result]

//       if (result.isSuccess) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Image saved in gallery")),
//         );

//         // 🔥 Log detected object count to the backend
//         if (_selectedStock != null) {
//           debugPrint("⚠️ No stock selected, skipping log.");
//           String? userId =
//               await SharedPrefsService.getUserId(); // ✅ Directly get the userId
//           if (userId == null) {
//             debugPrint("❌ User ID not found, cannot log data.");
//           }

//           if (userId != null) {
//             debugPrint(
//                 "📌 Updating Database: USER = $userId, ITEM = $_selectedStock, Count = ${editableBoundingBoxes.length}");
//             var response = await API.logStockCurrentCount(
//               userId,
//               _selectedStock!,
//               editableBoundingBoxes.length, // Detected count
//             );

//             if (response != null) {
//               debugPrint("✅ Object count logged: $response");
//             } else {
//               debugPrint("❌ Failed to log object count.");
//             }
//           } else {
//             debugPrint("❌ User ID not found, cannot log data.");
//           }
//         } else {
//           debugPrint("⚠️ No stock selected, skipping log.");
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text("Image not saved")),
//         );
//       }
//     } catch (e) {
//       debugPrint("Error saving image: $e");
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("An error occurred while saving")),
//       );
//     }
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

//   Future<void> drawRectanglesAroundObjects() async {
//     if (_selectedImage == null) return;

//     // Read image bytes
//     Uint8List imageBytes = await _selectedImage!.readAsBytes();

//     // Decode image
//     ui.Image decodedImage = await decodeImageFromList(imageBytes);

//     setState(() {
//       imageForDrawing = decodedImage; // Now image is a ui.Image
//     });
//   }
//   // END

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void reset() {
//     setState(() {
//       _selectedImage = null;
//       imageForDrawing = null; // Clear this to prevent null check errors
//       editableBoundingBoxes = []; // Also clear detected objects
//       isAddingBox = false;
//       titleController.clear();
//       timestamp = "";
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
//         appBar: AppBar(
//           title: Row(mainAxisSize: MainAxisSize.min, children: [
//             RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: 'Tec',
//                     style: TextStyle(
//                       color: const Color.fromARGB(255, 27, 211, 224),
//                       fontSize: 25.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextSpan(
//                     text: 'Tags',
//                     style: TextStyle(
//                       color: const Color.fromARGB(255, 29, 118, 235),
//                       fontSize: 25.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 2),
//             Image.asset(
//               'assets/images/tectags_icon.png',
//               height: 40.0,
//             ),
//           ]),
//           backgroundColor: const Color.fromARGB(255, 5, 45, 90),
//           foregroundColor: const Color.fromARGB(255, 255, 255, 255),
//           automaticallyImplyLeading: false,
//           actions: [
//             Builder(
//               builder: (context) => IconButton(
//                 icon: Icon(Icons.menu),
//                 onPressed: () {
//                   Scaffold.of(context).openEndDrawer();
//                 },
//               ),
//             ),
//           ],
//         ),
//         endDrawer: const SideMenu(),
//         body: Container(
//           padding: const EdgeInsets.fromLTRB(
//               42, 40, 42, 42), // Overall outer padding
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: AssetImage("assets/images/tectags_bg.png"),
//               fit: BoxFit
//                   .cover, // Ensures the image covers the entire background
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Container(
//                   width: double
//                       .infinity, // Makes the container expand horizontally
//                   margin: const EdgeInsets.fromLTRB(0, 40, 0, 0),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(12),
//                     color: const Color.fromARGB(255, 223, 223, 223),
//                   ),
//                   child: imageForDrawing == null
//                       ? Icon(
//                           Icons.add_photo_alternate_outlined,
//                           size: 120,
//                           color: Colors.grey[500],
//                         )
//                       : Screenshot(
//                           controller: screenshotController, // Wrap entire Stack
//                           child: PhotoViewer(
//                             imageFile: _selectedImage!,
//                             editableBoundingBoxes: editableBoundingBoxes,
//                             onMoveBox: (int index, DetectedObject newBox) {
//                               setState(() {
//                                 editableBoundingBoxes[index] = newBox;
//                               });
//                             },
//                             onRemoveBox: (int index) {
//                               setState(() {
//                                 editableBoundingBoxes.removeAt(index);
//                               });
//                             },
//                             onNewBox: (DetectedObject newBox) {
//                               setState(() {
//                                 editableBoundingBoxes.add(newBox);
//                               });
//                             },
//                             isRemovingBox: isRemovingBox,
//                             isAddingBox: isAddingBox,
//                             timestamp: timestamp,
//                             titleController: titleController,
//                           ),
//                         ),
//                 ),
//               ),
//               const SizedBox(height: 35.0),
//               if (_selectedImage == null) ...[
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     textStyle: const TextStyle(fontSize: 16),
//                     backgroundColor: const Color.fromARGB(255, 22, 165, 221),
//                     foregroundColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 95, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: useCamera,
//                   icon: const Icon(Icons.camera_alt),
//                   label: const Text("Capture Photo"),
//                 ),
//               ],
//               const SizedBox(height: 15.0),
//               if (_selectedImage == null) ...[
//                 ElevatedButton.icon(
//                   style: ElevatedButton.styleFrom(
//                     textStyle: const TextStyle(fontSize: 16),
//                     backgroundColor: Colors.white,
//                     foregroundColor: const Color(0xFF052D5A),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 84, vertical: 15),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   onPressed: imageGallery,
//                   icon: const Icon(Icons.image),
//                   label: const Text("Choose an Image"),
//                 ),
//                 SizedBox(height: 15.0),
//               ],
//               if (_selectedImage != null) ...[
//                 textToShow != null
//                     ? Text(
//                         textToShow!,
//                         style: const TextStyle(
//                             fontSize: 16.0,
//                             fontWeight: FontWeight.w500,
//                             color: Colors.lightGreenAccent),
//                       )
//                     : const SizedBox(height: 15.0),
//                 // DROPDOWN THAT FETCHES STOCKS FROM MONGODB
//                 DropdownButtonFormField<String>(
//                   value: _selectedStock,
//                   onChanged: (newValue) {
//                     setState(() {
//                       _selectedStock = newValue!;
//                       titleController.text = _selectedStock!;
//                     });
//                     debugPrint("✅ Selected Stock: $_selectedStock");
//                   },
//                   items:
//                       stockList.map<DropdownMenuItem<String>>((String stock) {
//                     return DropdownMenuItem<String>(
//                       value: stock,
//                       child: Text(stock),
//                     );
//                   }).toList(),
//                   decoration: InputDecoration(
//                     hintText: "Select a stock",
//                     filled: true,
//                     fillColor: Colors.white,
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 15.0),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white, // White background
//                     borderRadius: BorderRadius.circular(10),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 4,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       IconButton(icon: Icon(Icons.refresh), onPressed: reset),
//                       IconButton(
//                         onPressed: toggleAddingMode,
//                         icon: Container(
//                           decoration: BoxDecoration(
//                             color: isAddingBox
//                                 ? Colors.grey[300]
//                                 : Colors.transparent,
//                             shape: BoxShape.rectangle,
//                             borderRadius:
//                                 BorderRadius.circular(10), // Rounded corners
//                           ),
//                           padding: const EdgeInsets.all(8),
//                           child: Icon(
//                             Icons.add,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         onPressed: toggleRemovingMode,
//                         icon: Container(
//                           decoration: BoxDecoration(
//                             color: isRemovingBox
//                                 ? Colors.grey[300]
//                                 : Colors.transparent,
//                             shape: BoxShape.rectangle,
//                             borderRadius:
//                                 BorderRadius.circular(10), // Rounded corners
//                           ),
//                           padding: const EdgeInsets.all(8),
//                           child: Icon(
//                             Icons.close,
//                             color: Colors.black,
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.save),
//                         onPressed: () => saveImage(context),
//                       ),
//                     ],
//                   ),
//                 ),
//               ]
//             ],
//           ),
//         ));
//   }
// }
