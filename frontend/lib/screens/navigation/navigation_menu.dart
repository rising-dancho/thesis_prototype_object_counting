import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tectags/screens/activity_logs/activity_logs.dart';
import 'package:tectags/screens/inventory/stock_manager.dart';
import 'package:tectags/screens/pytorch/pytorch_mobile.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  Future<NavigationController> _initController() async {
    final controller = Get.put(NavigationController());
    await controller.setup(); // move setup code here
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NavigationController>(
      future: _initController(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final controller = snapshot.data!;
        return Scaffold(
          body: Obx(() => controller.screens[controller.selectedIndex.value]),
          bottomNavigationBar: Obx(
            () => NavigationBarTheme(
              data: NavigationBarThemeData(
                indicatorColor: Colors.blue.withAlpha((0.2 * 255).toInt()),
                labelTextStyle: WidgetStateProperty.all(
                  const TextStyle(color: Colors.white),
                ),
              ),
              child: NavigationBar(
                height: 80,
                elevation: 0,
                backgroundColor: const Color.fromARGB(255, 5, 45, 90),
                selectedIndex: controller.selectedIndex.value,
                onDestinationSelected: (index) =>
                    controller.selectedIndex.value = index,
                destinations: controller.destinations,
              ),
            ),
          ),
        );
      },
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxList<Widget> screens = <Widget>[].obs;
  final RxList<NavigationDestination> destinations =
      <NavigationDestination>[].obs;

  Future<void> setup() async {
    final role = await SharedPrefsService.getRole() ?? 'employee';
    debugPrint("Fetched role: $role");

    final tempScreens = [
      PytorchMobile(),
      StockManager(),
    ];

    final tempDestinations = [
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
      const NavigationDestination(
        icon: Icon(Icons.inventory_sharp, color: Colors.grey),
        selectedIcon: Icon(Icons.inventory_sharp, color: Colors.white),
        label: "Inventory",
      ),
    ];

    if (role == 'manager') {
      tempScreens.add(ActivityLogs());
      tempDestinations.add(
        const NavigationDestination(
          icon: Icon(Icons.list_alt, color: Colors.grey),
          selectedIcon: Icon(Icons.list_alt, color: Colors.white),
          label: "Activity Logs",
        ),
      );
    }

    screens.value = tempScreens;
    destinations.value = tempDestinations;
  }
}
