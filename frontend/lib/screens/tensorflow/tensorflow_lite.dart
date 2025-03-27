import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tectags/logic/tensorflow/photo_viewer.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'dart:ui' as ui;

import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class TensorflowLite extends StatefulWidget {
  const TensorflowLite({super.key});

  @override
  State<TensorflowLite> createState() => _TensorflowLiteState();
}

class _TensorflowLiteState extends State<TensorflowLite> {
  ScreenshotController screenshotController = ScreenshotController();
  // Image galler and camera variables
  File? _selectedImage;
  late ImagePicker imagePicker;
  // EXPLANATION about ui.Image:
  // In Flutter, ui.Image (from dart:ui) is an in-memory representation of an image that allows direct manipulation in a Canvas via CustomPainter. Unlike Image.file or Image.asset, which are widgets for displaying images in the UI, ui.Image is specifically used for low-level drawing operations.
  ui.Image? imageForDrawing;

  // initialize object detector
  late ObjectDetector objectDetector;
  // detected objects array
  List<DetectedObject> objects = [];
  List<Rect> editableBoundingBoxes = []; // Editable list of bounding boxes
  bool isAddingBox = false;
  bool isRemovingBox = false;

  // FOR LABELS
  String timestamp = "";
  // variable for whatever is typed in the TextField
  final TextEditingController titleController = TextEditingController();

  // FOR THE DROPDOWN
  List<String> stockList = [];
  String? _selectedStock;

  @override
  void initState() {
    super.initState();
    loadStockData();
    imagePicker = ImagePicker();
    // USE DEFAULT PRETRAINED MODEL: load initial pretrained object detector
    // EXPLANATION: https://pub.dev/packages/google_mlkit_object_detection#create-an-instance-of-objectdetector
    final options = ObjectDetectorOptions(
        mode: DetectionMode.single,
        classifyObjects: true,
        multipleObjects: true);
    // initialize object detector inside initState (REQUIRED)
    objectDetector = ObjectDetector(options: options);
    // loadModel();
  }

  // SEND OBJECT COUNT TO THE BACKEND
  void logObjectCount(String userId, String item, int countedAmount) async {
    var response = await API.logStockCurrentCount(userId, item, countedAmount);

    if (response != null) {
      debugPrint("✅ OBJECT COUNT LOGGED successfully: $response");
    } else {
      debugPrint("❌ Failed to log object count.");
    }
  }

  void updateDatabaseWithObjectCount(String userId, String item) {
    debugPrint(
        "📌 Updating Database: User = $userId, Item = $item, Count = ${editableBoundingBoxes.length}");
    int detectedCount = editableBoundingBoxes.length;
    logObjectCount(userId, item, detectedCount);
  }

  // STOCK DATA FOR THE DROPDOWN
  Future<void> loadStockData() async {
    var fetchedStocks = await API.fetchStockFromMongoDB();

    if (fetchedStocks != null) {
      setState(() {
        stockList = fetchedStocks.keys.toList();
      });
    }
  }

  Future<void> loadImageForDrawing(File imageFile) async {
    final data = await imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    imageForDrawing = frame.image;
  }

  // OBJECT DETECTION
  // loadModel() async {
  //   final modelPath = await getModelPath('assets/ml/checkpoint_epoch_1.tflite');
  //   final options = LocalObjectDetectorOptions(
  //     mode: DetectionMode.single,
  //     modelPath: modelPath,
  //     classifyObjects: true,
  //     multipleObjects: true,
  //   );
  //   objectDetector = ObjectDetector(options: options);
  // }

  /// **Save Screenshot to Gallery**
  /// THIS WOULD ALSO SAVE COUNTED OBJECT TO THE DATABASE (WILL SHOW IN THE ACTIVITY LOGS)
  Future<void> saveImage(BuildContext context) async {
    try {
      final Uint8List? screenShot = await screenshotController.capture();
      if (!mounted) return;

      if (screenShot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to capture screenshot")),
        );
        return;
      }

      final result = await ImageGallerySaverPlus.saveImage(
        screenShot,
        name: "screenshot_${DateTime.now().millisecondsSinceEpoch}.png",
      );

      if (result["isSuccess"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image saved in gallery")),
        );

        // 🔥 Log detected object count to the backend
        if (_selectedStock != null) {
          String? userId =
              await SharedPrefsService.getUserId(); // ✅ Directly get the userId

          if (userId != null) {
            var response = await API.logStockCurrentCount(
              userId,
              _selectedStock!,
              editableBoundingBoxes.length, // Detected count
            );

            if (response != null) {
              debugPrint("✅ Object count logged: $response");
            } else {
              debugPrint("❌ Failed to log object count.");
            }
          } else {
            debugPrint("❌ User ID not found, cannot log data.");
          }
        } else {
          debugPrint("⚠️ No stock selected, skipping log.");
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image not saved")),
        );
      }
    } catch (e) {
      debugPrint("Error saving image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred while saving")),
      );
    }
  }

  Future<String> getModelPath(String asset) async {
    final path = '${(await getApplicationSupportDirectory()).path}/$asset';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(asset);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  doObjectDetection() async {
    if (_selectedImage == null) {
      debugPrint("No image selected!");
      return;
    }

    debugPrint("Starting object detection...");
    InputImage inputImage = InputImage.fromFile(_selectedImage!);

    // Get detected objects
    List<DetectedObject> detectedObjects =
        await objectDetector.processImage(inputImage);
    debugPrint("Objects detected: ${detectedObjects.length}");

    // debugPrint all bounding boxes BEFORE adding them to the list
    debugPrint("\nBounding Boxes BEFORE Processing:");
    for (int i = 0; i < detectedObjects.length; i++) {
      final rect = detectedObjects[i].boundingBox;
      debugPrint(
          "Box $i: Left=${rect.left}, Top=${rect.top}, Right=${rect.right}, Bottom=${rect.bottom}");
    }

    setState(() {
      objects = detectedObjects;
      editableBoundingBoxes = detectedObjects
          .map((obj) => obj.boundingBox)
          .toList(); // ✅ Ensure ML-detected boxes are editable
    });

    // debugPrint bounding boxes AFTER being added to editableBoundingBoxes
    debugPrint("\nBounding Boxes AFTER Processing:");
    for (int i = 0; i < editableBoundingBoxes.length; i++) {
      final rect = editableBoundingBoxes[i];
      debugPrint(
          "Editable Box $i: Left=${rect.left}, Top=${rect.top}, Right=${rect.right}, Bottom=${rect.bottom}");
    }

    drawRectanglesAroundObjects();
  }

  Future<void> drawRectanglesAroundObjects() async {
    if (_selectedImage == null) return;

    // Read image bytes
    Uint8List imageBytes = await _selectedImage!.readAsBytes();

    // Decode image
    ui.Image decodedImage = await decodeImageFromList(imageBytes);

    setState(() {
      imageForDrawing = decodedImage; // Now image is a ui.Image
    });
  }
  // END

  @override
  void dispose() {
    super.dispose();
  }

  imageGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      setState(() {
        _selectedImage;
        timestamp = DateTime.now().toString(); // Store timestamp
      });
      doObjectDetection();
    }
  }

  useCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      setState(() {
        _selectedImage;
        timestamp = DateTime.now().toString(); // Store timestamp
      });
      doObjectDetection();
    }
  }

  void reset() {
    setState(() {
      _selectedImage = null;
      imageForDrawing = null; // Clear this to prevent null check errors
      objects = []; // Also clear detected objects
      isAddingBox = false;
      titleController.clear();
      timestamp = "";
    });
  }

  void toggleAddingMode() {
    setState(() {
      isAddingBox = !isAddingBox;
      if (isAddingBox) {
        isRemovingBox = false; // Disable removing mode
      }
    });
  }

  void toggleRemovingMode() {
    setState(() {
      isRemovingBox = !isRemovingBox;
      if (isRemovingBox) {
        isAddingBox = false; // Disable adding mode
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Tegtags AutoCount"),
          backgroundColor: const Color.fromARGB(255, 5, 45, 90),
          foregroundColor: const Color.fromARGB(255, 255, 255, 255),
          automaticallyImplyLeading: false,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
          ],
        ),
        endDrawer: const SideMenu(),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/tectags_bg.png"),
              fit: BoxFit
                  .cover, // Ensures the image covers the entire background
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  width: double
                      .infinity, // Makes the container expand horizontally
                  margin: const EdgeInsets.fromLTRB(22, 40, 22, 42),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color.fromARGB(255, 223, 223, 223),
                  ),
                  child: imageForDrawing == null
                      ? Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 120,
                          color: Colors.grey[500],
                        )
                      : Screenshot(
                          controller: screenshotController, // Wrap entire Stack
                          child: PhotoViewer(
                            imageFile: _selectedImage!,
                            imageForDrawing: imageForDrawing,
                            editableBoundingBoxes: editableBoundingBoxes,
                            onNewBox: (Rect box) {
                              setState(() {
                                editableBoundingBoxes.add(box);
                              });
                            },
                            onRemoveBox: (int index) {
                              setState(() {
                                editableBoundingBoxes.removeAt(index);
                              });
                            },
                            isAddingBox: isAddingBox,
                            isRemovingBox: isRemovingBox,
                            timestamp: timestamp,
                            titleController: titleController,
                          ),
                        ),
                ),
              ),
              if (_selectedImage == null) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 16, // Optionally adjust the font size
                    ),
                    backgroundColor: const Color.fromARGB(255, 10, 125,
                        170), // Set your desired background color here
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    shadowColor: Colors.grey,
                    padding:
                        EdgeInsets.symmetric(horizontal: 118, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: const Color.fromARGB(
                            255, 3, 130, 168), // Set the border color
                        width: 2,
                      ),
                    ),
                  ),
                  onPressed: useCamera,
                  child: const Text("Capture"),
                ),
              ],
              const SizedBox(height: 15.0),
              if (_selectedImage == null) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      fontSize: 16, // Optionally adjust the font size
                    ),
                    backgroundColor: const Color.fromARGB(255, 255, 255,
                        255), // Set your desired background color here
                    foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                    shadowColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: 85, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: const Color.fromARGB(
                            255, 3, 130, 168), // Set the border color
                        width: 2,
                      ),
                    ),
                  ),
                  onPressed: imageGallery,
                  child: const Text("Choose an image"),
                ),
                SizedBox(height: 15.0), // <-- Adds spacing below the button
              ],
              if (_selectedImage != null) ...[
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    // DROPDOWN THAT FETCHES STOCKS FROM MONGODB
                    child: DropdownButtonFormField<String>(
                      value: _selectedStock,
                      onChanged: (newValue) {
                        setState(() {
                          _selectedStock = newValue!;
                          titleController.text = _selectedStock!;
                        });
                        debugPrint("✅ Selected Stock: $_selectedStock");
                      },
                      items: stockList
                          .map<DropdownMenuItem<String>>((String stock) {
                        return DropdownMenuItem<String>(
                          value: stock,
                          child: Text(stock),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        hintText: "Select a stock",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    )),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: Icon(Icons.refresh), onPressed: reset),
                    IconButton(
                      icon: Icon(Icons.add), // Change dynamically
                      onPressed: toggleAddingMode,
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: toggleRemovingMode,
                    ),
                    IconButton(
                        icon: Icon(Icons.save),
                        onPressed: () => saveImage(context)),
                  ],
                ),
              ]
            ],
          ),
        ));
  }
}
