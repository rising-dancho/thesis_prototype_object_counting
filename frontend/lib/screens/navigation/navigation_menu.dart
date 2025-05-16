import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tectags/screens/activity_logs/activity_logs.dart';
import 'package:tectags/screens/inventory/stock_manager.dart';
import 'package:tectags/screens/pytorch/pytorch_mobile.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      body: Obx(() => controller.screens.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : controller.screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => controller.destinations.isEmpty
            ? const SizedBox.shrink()
            : NavigationBarTheme(
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
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;
  final RxList<Widget> screens = <Widget>[].obs;
  final RxList<NavigationDestination> destinations =
      <NavigationDestination>[].obs;

  @override
  void onInit() {
    super.onInit();
    _setupNavigation();
  }

  Future<void> _setupNavigation() async {
    final role = await API.fetchUserRole();

    if (role.isEmpty) {
      debugPrint("⚠️ Role is empty! Cannot determine permissions.");
    }

    debugPrint("ROLE fetched from API: $role");

    // ✅ Save the role in SharedPreferences
    await SharedPrefsService.setRole(role);

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
      debugPrint("🔐 Adding Activity Logs for MANAGER role");
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

    if (selectedIndex.value >= screens.length) {
      selectedIndex.value = 0;
    }
  }
}
