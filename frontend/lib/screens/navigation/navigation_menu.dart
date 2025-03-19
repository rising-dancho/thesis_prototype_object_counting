import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:techtags/screens/activity_logs/activity_logs.dart';
import 'package:techtags/screens/logout_screen.dart';
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
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.blue.withOpacity(0.2),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255));
                }

                return const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255));
              },
            ),
          ),
          child: NavigationBar(
            height: 80,
            elevation: 0,
            backgroundColor: const Color.fromARGB(255, 5, 45, 90),
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) =>
                controller.selectedIndex.value = index,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.polyline),
                label: "Tensorflow Lite",
              ),
              NavigationDestination(
                icon: Icon(Icons.spoke),
                label: "OpenCV",
              ),
            ],
          ),
        ),
      ),
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
