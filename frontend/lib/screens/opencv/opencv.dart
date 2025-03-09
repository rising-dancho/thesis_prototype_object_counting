import 'package:flutter/material.dart';
import 'package:image_picker_demo/logic/opencv/opencv_photo_viewer.dart';
import 'dart:io';
import 'package:screenshot/screenshot.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class OpenCV extends StatefulWidget {
  const OpenCV({super.key});

  @override
  State<OpenCV> createState() => _OpenCVState();
}

class _OpenCVState extends State<OpenCV> {
  File? _selectedImage;
  late ImagePicker imagePicker;

  // FOR BOUNDING BOXES
  bool isAddingBox = false;
  var uuid = Uuid();
  List<Map<String, dynamic>> boxes = [];

  // FOR LABELS
  String timestamp = "";
  // variable for whatever is typed in the TextField
  final TextEditingController titleController = TextEditingController();
  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  void reset() {
    setState(() {
      _selectedImage = null;
      boxes.clear();
      isAddingBox = false;
      timestamp = "";
      titleController.clear(); // Clear the text field
    });
  }

  void addBoundingBox(TapUpDetails details) {
    if (isAddingBox && _selectedImage != null) {
      setState(() {
        double boxWidth = 75;
        double boxHeight = 75;

        boxes.add({
          "id": uuid.v4(),
          "x": details.localPosition.dx - (boxWidth / 2), // Center horizontally
          "y": details.localPosition.dy - (boxHeight / 2), // Center vertically
          "width": boxWidth,
          "height": boxHeight,
        });

        // isAddingBox = false; // Disable adding mode after placing the box
      });
    }
  }

  void removeBoundingBox(TapUpDetails details) {
    if (!isAddingBox && _selectedImage != null) {
      setState(() {
        boxes.removeWhere((box) =>
            details.localPosition.dx >= box["x"] &&
            details.localPosition.dx <= box["x"] + box["width"] &&
            details.localPosition.dy >= box["y"] &&
            details.localPosition.dy <= box["y"] + box["height"]);
      });
    }
  }

  imageGallery() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);

    if (selectedImage != null) {
      setState(() {
        _selectedImage = File(selectedImage.path);
        timestamp = DateTime.now().toString(); // Store timestamp
        boxes.clear(); // Reset boxes when a new image is selected
      });
    }
  }

  useCamera() async {
    XFile? selectedImage =
        await imagePicker.pickImage(source: ImageSource.camera);

    if (selectedImage != null) {
      setState(() {
        _selectedImage = File(selectedImage.path);
        timestamp = DateTime.now().toString(); // Store timestamp
        boxes.clear(); // Reset boxes when a new image is selected
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OpenCV")),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.green[300],
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                children: [
                  if (_selectedImage == null)
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 120,
                          color: Colors.grey[500],
                        ),
                      ),
                    )
                  else
                    GestureDetector(
                      onTapUp: (details) {
                        if (isAddingBox) {
                          addBoundingBox(details); // Add box if in add mode
                        } else {
                          removeBoundingBox(
                              details); // Remove box if in remove mode
                        }
                      },
                      child: Screenshot(
                        controller: screenshotController,
                        child: Stack(
                          children: [
                            // Image and bounding boxes
                            Center(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  child:
                                      PhotoViewer(imageFile: _selectedImage!),
                                ),
                              ),
                            ),

                            // Bounding boxes overlay
                            ...boxes.map((box) => Positioned(
                                  left: box["x"].toDouble(),
                                  top: box["y"].toDouble(),
                                  child: GestureDetector(
                                    onPanUpdate: (details) {
                                      setState(() {
                                        box["x"] += details.delta.dx;
                                        box["y"] += details.delta.dy;
                                      });
                                    },
                                    child: Container(
                                      width: box["width"].toDouble(),
                                      height: box["height"].toDouble(),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.red, width: 2),
                                      ),
                                    ),
                                  ),
                                )),

                            // ** Title (Upper Left) **
                            if (titleController.text.isNotEmpty)
                              Positioned(
                                top: 10, // Adjust as needed
                                left: 10,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(titleController.text, // Display input text
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            // ** Total Bounding Boxes Counter (Upper Right) **
                            Positioned(
                              top: 10, // Adjust for positioning
                              right: 10,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(0, 0, 0, 0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Total Count: ${boxes.length}',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            // ** Timestamp (Lower Left) **
                            if (timestamp.isNotEmpty)
                              Positioned(
                                bottom: 10, // Adjust as needed
                                left: 10,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Color.fromRGBO(0, 0, 0, 0.7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    timestamp, // Display timestamp
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedImage == null) ...[
              ElevatedButton(
                onPressed: imageGallery,
                onLongPress: useCamera,
                child: const Text("Choose/Capture"),
              ),
            ],
            if (_selectedImage != null) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: titleController, // Assign controller
                  onChanged: (value) {
                    setState(() {}); // Update UI when text changes
                  },
                  decoration: InputDecoration(
                    hintText: "Enter file name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: Icon(Icons.refresh), onPressed: reset),
                  IconButton(
                    icon: Icon(Icons.add), // Change icon dynamically
                    onPressed: () {
                      setState(() {
                        isAddingBox = !isAddingBox; // Toggle adding mode
                      });
                    },
                  ),
                  IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          isAddingBox =
                              !isAddingBox; // Switch between add & remove mode
                        });
                      }),
                  IconButton(icon: Icon(Icons.save), onPressed: () {}),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
