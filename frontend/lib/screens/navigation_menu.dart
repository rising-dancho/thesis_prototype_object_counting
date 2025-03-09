import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker_demo/screens/tensorflow/tensorflow_lite.dart';
import 'package:image_picker_demo/screens/opencv/opencv.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(() => NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.polyline, color: Colors.grey),
                label: "Tensorflow Lite",
              ),
              NavigationDestination(
                icon: Icon(Icons.spoke, color: Colors.grey),
                label: "OpenCV",
              ),
            ],
          )),
    );
  }
}

// dl getx package:  flutter pub add get
// manage navigation menu without using Stateful widget classes
class NavigationController extends GetxController {
  final Rx<int> selectedIndex =
      0.obs; // would only rerender whatever is inside obx

  final screens = [TensorflowLite(), OpenCV()];
}
