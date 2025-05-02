import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';
import 'package:tectags/logic/pytorch/photo_viewer.dart';
// import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:tectags/models/detected_objects_model.dart';
import 'dart:ui' as ui;

import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';

// SAVING IMAGE TO GALLERY [import dependencies]
import 'package:saver_gallery/saver_gallery.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'package:intl/intl.dart';

// PYTORCH
import 'package:pytorch_lite/pytorch_lite.dart';
import 'package:tectags/utils/label_formatter.dart';
import 'package:tectags/widgets/products/add_new_product.dart';

class PytorchMobile extends StatefulWidget {
  const PytorchMobile({super.key});

  @override
  State<PytorchMobile> createState() => _PytorchMobileState();
}

class _PytorchMobileState extends State<PytorchMobile> {
  ScreenshotController screenshotController = ScreenshotController();
  // Image galler and camera variables
  File? _selectedImage;
  late ImagePicker imagePicker;
  // EXPLANATION about ui.Image:
  // In Flutter, ui.Image (from dart:ui) is an in-memory representation of an image that allows direct manipulation in a Canvas via CustomPainter. Unlike Image.file or Image.asset, which are widgets for displaying images in the UI, ui.Image is specifically used for low-level drawing operations.
  ui.Image? imageForDrawing;

  // FOR LABELS
  String timestamp = "";
  // variable for whatever is typed in the TextField
  final TextEditingController titleController = TextEditingController();

  // FOR THE DROPDOWN
  String? _selectedStock;

  // PYTORCH OBJECT DETECTION
  // initialize object detector
  late ModelObjectDetection _objectModelYoloV8;
  // List<Rect> editableBoundingBoxes = []; // Editable list of bounding boxes
  List<DetectedObject> editableBoundingBoxes = [];
  bool isAddingBox = false;
  bool isRemovingBox = false;
  // for inference speed checking
  String? textToShow;

  // toggle bounding box, labels, and scores except the number tag
  bool showBoundingInfo = true;

  // auto populate detected stocks from doObjectDetection method
  List<String> stockList = []; // Your fixed list
  List<String> detectedStockList = []; // Dynamic from detection
  List<String> allStocks = []; // Merged unique values
  Map<String, Map<String, int>> stockCounts = {};

  @override
  void initState() {
    super.initState();
    loadStockData();
    imagePicker = ImagePicker();
    _requestPermission(); // [gain permission]
    loadModel();
  }

  Future loadModel() async {
    String pathObjectDetectionModelYolov8 = "assets/models/best.torchscript";
    String pathCustomLabels = "assets/labels/custom_labels.txt";

    try {
      _objectModelYoloV8 = await PytorchLite.loadObjectDetectionModel(
        pathObjectDetectionModelYolov8,
        7,
        640,
        640,
        labelPath: pathCustomLabels,
        objectDetectionModelType: ObjectDetectionModelType.yolov8,
      );
    } catch (e) {
      if (e is PlatformException) {
        print("only supported for android, Error is $e");
      } else {
        print("Error is $e");
      }
    }
  }

  // INFO DISPLAYED IN THE CARDS PULLED FROM THE STOCKS COLLECTION
  Future<void> fetchStockData() async {
    Map<String, Map<String, int>>? data = await API.fetchStockFromMongoDB();
    debugPrint("Fetched Stock Data: $data");
    debugPrint("STOCK COUNTS Data: $stockCounts");

    if (data == null) {
      debugPrint("⚠️ No stock data fetshed.");
      return; // Exit early if data is null
    }

    if (mounted) {
      setState(() {
        stockCounts = data.map((key, value) => MapEntry(key, {
              "availableStock": value["availableStock"] ?? 0,
              "totalStock": value["totalStock"] ?? 0,
              "sold": value["sold"] ?? 0,
            }));
      });
      debugPrint("Updated StockCounts: $stockCounts");
    }
  }

  Future doObjectDetection() async {
    if (_selectedImage == null) {
      debugPrint("No image selected!");
      return;
    }

    debugPrint("Running YOLOv8 object detection...");

    Stopwatch stopwatch = Stopwatch()..start();
    debugPrint('Detection completed in ${stopwatch.elapsed.inMilliseconds} ms');
    List<ResultObjectDetection?> objDetect =
        await _objectModelYoloV8.getImagePrediction(
      await _selectedImage!.readAsBytes(),
      minimumScore: 0.4,
      iOUThreshold: 0.3,
    );
    textToShow = inferenceTimeAsString(stopwatch);

    debugPrint('object executed in ${stopwatch.elapsed.inMilliseconds} ms');
    for (var element in objDetect) {
      if (element != null) {
        debugPrint({
          "score": element.score,
          "className": element.className,
          "class": element.classIndex,
          "rect": {
            "left": element.rect.left,
            "top": element.rect.top,
            "width": element.rect.width,
            "height": element.rect.height,
            "right": element.rect.right,
            "bottom": element.rect.bottom,
          },
        }.toString());
      }
    }

    // Show Snackbar warning for confidence scores between 50% and 70%
    bool hasMidConfidence = objDetect.any((element) {
      final score = element?.score ?? 0.0;

      const upperLimit = 0.50;
      return score >= 0.4 && score < upperLimit;
    });

    if (hasMidConfidence && mounted) {
      void showTopSnackBar(BuildContext context, Widget title, Widget message) {
        final overlay = Overlay.of(context);
        OverlayEntry? overlayEntry;

        overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 12,
            right: 12,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
                decoration: BoxDecoration(
                  // color: Color(0xFFF8D7DA),
                  color: Colors.red[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          SizedBox(height: 4),
                          message,
                        ],
                      ),
                    ),
                    IconButton(
                      // icon: Icon(Icons.close, color: Colors.grey[800]),
                      icon: Icon(
                        Icons.close,
                        color: Colors.grey[900],
                      ),
                      onPressed: () {
                        overlayEntry?.remove();
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );

        overlay.insert(overlayEntry);

        // Future.delayed(Duration(seconds: 10)).then((_) {
        //   overlayEntry?.remove();
        // });
      }

      if (hasMidConfidence && mounted) {
        showTopSnackBar(
          this.context,
          Row(
            children: [
              Icon(
                Icons.warning, // Or use your custom icon widget here
                color: Colors.red[700],
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'WARNING:',
                style: TextStyle(
                  // color: Color(0xFF6A1A21),
                  color: Colors.grey[900],
                  // color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            'There may be objects detected that are not part of the scope!',
            style: TextStyle(color: Colors.grey[900], fontSize: 18),
          ),
        );
      }
    }

    setState(() {
      editableBoundingBoxes = objDetect.where((e) => e != null).map((e) {
        final score = e!.score;
        // final boxColor = score < 0.7 ? Colors.red : Colors.lightGreen;

        return DetectedObject(
          rect: Rect.fromLTWH(
              e.rect.left, e.rect.top, e.rect.width, e.rect.height),
          label: e.className ?? 'Unknown',
          score: score,
          color: Colors.primaries[e.classIndex % Colors.primaries.length],
        );
      }).toList();

      // Title case the detected labels before saving them into the inventory
      detectedStockList = editableBoundingBoxes
          .map((e) => LabelFormatter.titleCase(e.label))
          .toSet()
          .toList();

      allStocks = {...stockList, ...detectedStockList}.toList();

      // // ✅ Ensure _selectedStock is valid
      // if (!allStocks.contains(_selectedStock)) {
      //   _selectedStock = null;
      //   titleController.clear(); // optional: also clear the text field
      // }

      // Auto-select the most common label
      final labelCounts = <String, int>{};
      for (var label in detectedStockList) {
        labelCounts[label] = (labelCounts[label] ?? 0) + 1;
      }
      String? mostCommonLabel;
      int maxCount = 0;
      labelCounts.forEach((label, count) {
        if (count > maxCount) {
          mostCommonLabel = label;
          maxCount = count;
        }
      });
      _selectedStock = mostCommonLabel;
      titleController.text = mostCommonLabel ?? '';

      debugPrint("DETECTED COUNT: ${editableBoundingBoxes.length}");
      debugPrint("Auto-populated Dropdown: $detectedStockList");
      debugPrint("Combined List (allStocks): $allStocks");
    });
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

  String inferenceTimeAsString(Stopwatch stopwatch) =>
      "Speed: ${stopwatch.elapsed.inMilliseconds} ms";

  /// Requests necessary permissions based on the platform. [gain permission]
  Future<void> _requestPermission() async {
    bool statuses;
    if (Platform.isAndroid) {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final deviceInfo = await deviceInfoPlugin.androidInfo;
      final sdkInt = deviceInfo.version.sdkInt;
      statuses =
          sdkInt < 29 ? await Permission.storage.request().isGranted : true;
    } else {
      statuses = await Permission.photosAddOnly.request().isGranted;
    }
    debugPrint('Permission Request Result: $statuses');
  }

  imageGallery() async {
    XFile? pickedFile =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _selectedImage = File(pickedFile.path);
      setState(() {
        _selectedImage;
        timestamp = DateFormat('MMM d, y • hh:mm a')
            .format(DateTime.parse(DateTime.now().toString()).toLocal());
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
        timestamp = DateFormat('MMM d, y • hh:mm a')
            .format(DateTime.parse(DateTime.now().toString()).toLocal());
      });
      doObjectDetection();
    }
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

  /// **Save Screenshot to Gallery**
  /// THIS WOULD ALSO SAVE COUNTED OBJECT TO THE DATABASE (WILL SHOW IN THE ACTIVITY LOGS)
  Future<void> saveImage(BuildContext context) async {
    try {
      // ✅ PREVENT SAVING IF THE STOCK SELECTION DROPDOWN IS EMPTY
      if (_selectedStock == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please select a stock before saving"),
            duration: Duration(milliseconds: 1000),
          ),
        );
        return;
      }

      final Uint8List? screenShot = await screenshotController.capture();
      if (!mounted) return;

      if (screenShot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to capture screenshot")),
        );
        return;
      }

      final result = await SaverGallery.saveImage(
        screenShot,
        fileName: "screenshot_${DateTime.now().millisecondsSinceEpoch}.png",
        skipIfExists: false,
      ); // [save your actual image] screenShot is my image

      debugPrint("Result: $result"); // [check structure of: result]

      if (result.isSuccess) {
        // ✅ If selected stock is NOT in the cached stock list, open modal to add it
        if (!stockList.contains(_selectedStock)) {
          debugPrint(
              "🆕 $_selectedStock not found in stock list. Opening modal to add.");
          _openAddProductModal(
            context,
            initialName: _selectedStock,
            sold: editableBoundingBoxes.length,
          );
          return; // Exit early — let the user add the product before logging
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Stock and Image saved successfully!")),
        );

        // 🔥 Log detected object count to the backend
        if (_selectedStock != null) {
          debugPrint("⚠️ No stock selected, skipping log.");
          String? userId =
              await SharedPrefsService.getUserId(); // ✅ Directly get the userId
          if (userId == null) {
            debugPrint("❌ User ID not found, cannot log data.");
          }

          if (userId != null) {
            debugPrint(
                "📌 Updating Database: USER = $userId, ITEM = $_selectedStock, Count = ${editableBoundingBoxes.length}");
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

  Future<void> _openAddProductModal(BuildContext context,
      {String? initialName, int? sold}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(modalContext).viewInsets.bottom),
          child: SingleChildScrollView(
            child: AddNewProduct(
              initialName: initialName,
              initialSold: sold,
              onAddStock: (String name, int count, int sold) async {
                setState(() {
                  stockCounts[name] = {
                    "availableStock": count,
                    "totalStock": count,
                    "sold": sold,
                  };
                });
                await API.saveStockToMongoDB(stockCounts);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text("Stock and Image saved successfully!")),
                );

                // 🔥 Log detected object count to the backend
                // if (_selectedStock == null) {
                //   debugPrint("⚠️ No stock selected, skipping log.");
                // } else {
                //   String? userId = await SharedPrefsService.getUserId();
                //   debugPrint("User ID: $userId");

                //   if (userId == null) {
                //     debugPrint("❌ User ID not found, cannot log data.");
                //     if (!modalContext.mounted) return;
                //     ScaffoldMessenger.of(modalContext).showSnackBar(
                //       const SnackBar(
                //           content:
                //               Text('User ID not found. Please log in again.')),
                //     );
                //     return;
                //   }

                //   debugPrint(
                //       "📌 Updating Database: USER = $userId, ITEM = $_selectedStock, Count = ${editableBoundingBoxes.length}");
                //   var response = await API.logStockCurrentCount(
                //     userId,
                //     _selectedStock!,
                //     editableBoundingBoxes.length, // Detected count
                //   );

                //   if (response != null && !response.containsKey('error')) {
                //     debugPrint("✅ Object count logged: $response");
                //   } else {
                //     debugPrint(
                //         "❌ Failed to log object count: ${response?['error']}");
                //   }
                // }
              },
            ),
          ),
        );
      },
    );
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

  // END

  @override
  void dispose() {
    super.dispose();
  }

  void reset() {
    setState(() {
      _selectedImage = null;
      imageForDrawing = null; // Clear this to prevent null check errors
      editableBoundingBoxes = []; // Also clear detected objects
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
          title: Row(mainAxisSize: MainAxisSize.min, children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Tec',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 27, 211, 224),
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: 'Tags',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 29, 118, 235),
                      fontSize: 25.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2),
            Image.asset(
              'assets/images/tectags_icon.png',
              height: 40.0,
            ),
          ]),
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
          padding: _selectedImage == null
              ? const EdgeInsets.fromLTRB(12, 16, 12, 32)
              : const EdgeInsets.all(5), // Overall outer padding
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
                  margin: _selectedImage == null
                      ? const EdgeInsets.fromLTRB(0, 16, 0, 24)
                      : const EdgeInsets.all(0),
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
                            editableBoundingBoxes: editableBoundingBoxes,
                            onMoveBox: (int index, DetectedObject newBox) {
                              setState(() {
                                editableBoundingBoxes[index] = newBox;
                              });
                            },
                            onRemoveBox: (int index) {
                              setState(() {
                                editableBoundingBoxes.removeAt(index);
                              });
                            },
                            onNewBox: (DetectedObject newBox) {
                              setState(() {
                                editableBoundingBoxes.add(newBox);
                              });
                            },
                            isRemovingBox: isRemovingBox,
                            isAddingBox: isAddingBox,
                            showBoundingInfo: showBoundingInfo,
                            timestamp: timestamp,
                            titleController: titleController,
                          ),
                        ),
                ),
              ),
              if (_selectedImage == null) ...[
                Container(
                    width: double
                        .infinity, // Makes the button take all horizontal space
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor:
                            const Color.fromARGB(255, 22, 165, 221),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 95, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: useCamera,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Capture Photo"),
                    )),
                const SizedBox(height: 10.0),
                Container(
                    width: double
                        .infinity, // Makes the button take all horizontal space
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF052D5A),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 84, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: imageGallery,
                      icon: const Icon(Icons.image),
                      label: const Text("Choose an Image"),
                    )),
              ],
              if (_selectedImage != null) ...[
                Container(
                  // color: Colors.red, // Debug background
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Bounding Boxes: ",
                        style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.lightGreenAccent),
                      ),
                      Switch(
                        value: showBoundingInfo,
                        onChanged: (value) {
                          setState(() {
                            showBoundingInfo = value;
                            debugPrint(showBoundingInfo.toString());
                          });
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.green,
                        inactiveThumbColor: Colors.white,
                        inactiveTrackColor:
                            const Color.fromARGB(255, 243, 243, 243)
                                .withAlpha((0.25 * 255).toInt()),
                      ),
                      const Spacer(),
                      textToShow != null
                          ? Text(
                              textToShow!,
                              style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.lightGreenAccent),
                            )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),
                // SizedBox(height: 5.0),
                // DROPDOWN THAT FETCHES STOCKS FROM MONGODB
                DropdownButtonFormField<String>(
                  value: _selectedStock,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedStock = newValue!;
                      titleController.text = _selectedStock!;
                    });
                    debugPrint("✅ Selected Stock: $_selectedStock");
                  },
                  items:
                      allStocks.map<DropdownMenuItem<String>>((String stock) {
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
                ),
                const SizedBox(height: 5.0),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // White background
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: Icon(Icons.refresh), onPressed: reset),
                      IconButton(
                        onPressed: toggleAddingMode,
                        icon: Container(
                          decoration: BoxDecoration(
                            color: isAddingBox
                                ? Colors.grey[300]
                                : Colors.transparent,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.add,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: toggleRemovingMode,
                        icon: Container(
                          decoration: BoxDecoration(
                            color: isRemovingBox
                                ? Colors.grey[300]
                                : Colors.transparent,
                            shape: BoxShape.rectangle,
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.save),
                        onPressed: () => saveImage(context),
                      ),
                    ],
                  ),
                ),
              ]
            ],
          ),
        ));
  }
}
