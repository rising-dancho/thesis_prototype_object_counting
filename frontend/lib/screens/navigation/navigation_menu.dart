import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techtags/screens/activity_logs/activity_logs.dart';
import 'package:techtags/screens/logout_screen.dart';
import 'package:techtags/screens/opencv/opencv.dart';
import 'package:techtags/screens/tensorflow/tensorflow_lite.dart';
// import '../../../backup/crud_test/crud.dart';
// import 'package:techtags/screens/opencv/opencv.dart';

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
            indicatorColor: Colors.blue.withAlpha((0.5 * 255)
                .toInt()), // Change this to your preferred highlight color
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.polyline, color: Colors.grey),
                label: "Tensorflow Lite",
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart, color: Colors.grey),
                label: "Activity Logs",
                // label: "OpenCV",
              ),
              NavigationDestination(
                icon: Icon(Icons.logout, color: Colors.grey),
                label: "Logout",
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

  // final screens = [TensorflowLite(), Crud()];
  final screens = [TensorflowLite(), ActivityLogs(), LogoutScreen()];
}
