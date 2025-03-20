import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techtags/screens/login_screen.dart';
import 'package:techtags/screens/navigation/navigation_menu.dart';
import 'package:techtags/services/api.dart';

class ActivityLog {
  final String userName;
  final String action;
  final int? objectCount;
  final String timestamp;

  ActivityLog({
    required this.userName,
    required this.action,
    this.objectCount,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      userName: json['userId'] is Map<String, dynamic>
          ? json['userId']['fullName']
          : "Unknown User",
      action: json['action'],
      objectCount: json['objectCount'],
      timestamp: json['timestamp'] ??
          json['createdAt'], // ✅ Use `createdAt` as fallback
    );
  }
}

class ActivityLogs extends StatefulWidget {
  const ActivityLogs({super.key});

  @override
  State<ActivityLogs> createState() => _ActivityLogsState();
}

class _ActivityLogsState extends State<ActivityLogs> {
  List<ActivityLog> activityLogs = [];

  @override
  void initState() {
    super.initState();
    _loadActivityLogs();
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Returns null if not found
  }

  Future<void> _loadActivityLogs() async {
    final userId = await getUserId(); // Await the userId
    debugPrint(" Retrieved userId: $userId");

    if (userId == null) {
      debugPrint("❌ User ID not found in SharedPreferences");
      return;
    }
    // FETCH USER DATA AND DISPLAY ON THE ACTIVITY LOGS SCREEN
    final logsData = await API.fetchActivityLogs(userId);
    if (logsData != null) {
      setState(() {
        activityLogs = logsData
            .map((log) {
              try {
                return ActivityLog.fromJson(log);
              } catch (e) {
                debugPrint("❌ Error parsing log: $log \n Exception: $e");
                return null;
              }
            })
            .whereType<ActivityLog>()
            .toList();
      });
    } else {
      debugPrint("❌ No logs retrieved");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Logs"),
        backgroundColor: const Color.fromARGB(255, 5, 158, 133),
        titleTextStyle: TextStyle(
          color: const Color.fromARGB(
              255, 255, 255, 255), // Set your desired color here
          fontSize: 20, // Optionally adjust the font size
        ),
        automaticallyImplyLeading: false,
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 5, 45, 90),
              ),
              child: Container(
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/tectags_logo_nobg.png', // Replace with your logo's asset path

                  width: 120, // Set your desired width

                  height: 120, // Set your desired height

                  fit: BoxFit
                      .contain, // Adjusts the image to fit within the specified dimensions
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NavigationMenu()),
                );
              },
            ),
            const Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Color.fromARGB(255, 82, 81, 81),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Activity Logs'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NavigationMenu()),
                );
              },
            ),
            const Divider(
              height: 20,
              thickness: 1,
              indent: 20,
              endIndent: 20,
              color: Color.fromARGB(255, 82, 81, 81),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Action')),
                DataColumn(label: Text('Objects Counted')),
                DataColumn(label: Text('Timestamp')),
              ],
              rows: activityLogs.map((log) {
                return DataRow(cells: [
                  DataCell(Text(log.userName)),
                  DataCell(Text(log.action)),
                  DataCell(Text(log.objectCount?.toString() ?? 'N/A')),
                  DataCell(Text(log.timestamp)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
