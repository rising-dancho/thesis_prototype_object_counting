import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tectags/screens/activity_logs/activity_logs.dart';
import 'package:tectags/screens/inventory/stock_manager.dart';
import 'package:tectags/screens/pytorch/pytorch_mobile.dart';
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
            indicatorColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
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
            destinations: [
              NavigationDestination(
                icon: Transform.scale(
                  scale: 1.9,
                  child: SvgPicture.asset(
                    'assets/icons/count_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Color.fromRGBO(158, 158, 158, 1),
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                selectedIcon: Transform.scale(
                  scale: 1.9,
                  child: SvgPicture.asset(
                    'assets/icons/count_icon.svg',
                    width: 24,
                    height: 24,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                label: "Count",
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_sharp, color: Colors.grey),
                selectedIcon:
                    const Icon(Icons.inventory_sharp, color: Colors.white),
                label: "Inventory",
              ),
              NavigationDestination(
                icon: const Icon(Icons.list_alt, color: Colors.grey),
                selectedIcon:
                    const Icon(Icons.list_alt, color: Colors.white),
                label: "Activity Logs",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  // final screens = [TensorflowLite(), Crud()];
  final screens = [PytorchMobile(), StockManager(), ActivityLogs()];
  // final screens = [RunModelByImageDemo(), StockManager(), ActivityLogs()];
}
