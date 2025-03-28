import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';

class ActivityLog {
  final String id; // FOR FETCHING SINGLE ACTIVITY BY USER
  final String userId; // ✅ Store userId
  final String fullName; // ✅ Store fullName
  final String action;
  final int? countedAmount;
  final String
      timestamp; // Now holds: intl: ^0.18.1 a more human readable formatted time

  ActivityLog({
    required this.id, // FOR FETCHING SINGLE ACTIVITY BY USER
    required this.userId,
    required this.fullName,
    required this.action,
    this.countedAmount,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    // Parse the timestamp into DateTime
    DateTime rawTimestamp =
        DateTime.parse(json['timestamp'] ?? json['createdAt']);

    // CONVERT TO MANILA TIME ZONE (UTC+8)
    DateTime manilaTime = rawTimestamp.toLocal(); // Ensure it's local first

    // HUMAN READABLE TIMESTAMP
    // Example output: "Mar 20, 2025 • 06:22 PM"
    String formattedTimestamp =
        // DateFormat('MMM d, y • hh:mm a').format(manilaTime);
        DateFormat.yMEd().add_jms().format(manilaTime);

    return ActivityLog(
      id: json['_id'] ?? 'Unknown ID', // ✅ Fix: Use _id instead of id
      userId: json['userId'] ?? 'Unknown ID',
      fullName: json['fullName'] ?? 'Unknown User',
      action: json['action'] ?? 'Unknown Action',
      countedAmount: json['countedAmount'] ?? 0, // ✅ Fallback to 0 if null
      timestamp: formattedTimestamp,
    );
  }

  // WHAT IS A FACTORY: https://chatgpt.com/share/67e6097f-8c94-8000-940d-5ecd8c54bb09
  // THIS FACTORY HELPS CONVERT THE JSON RECEIVED FROM API RESPONSE INTO A FLUTTER OBJECT
}

class ActivityLogs extends StatefulWidget {
  const ActivityLogs({super.key});

  @override
  State<ActivityLogs> createState() => _ActivityLogsState();
}

class _ActivityLogsState extends State<ActivityLogs> {
  List<ActivityLog> activityLogs = []; // ACTIVITY LOGS ARE SAVED IN THIS ARRAY
  bool showAllLogs = false; // Default: Show only current user's logs

  @override
  void initState() {
    super.initState();
    _loadActivityLogs();
  }

  Future<String?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // Returns null if not found
  }

  // FETCH SINGLE ACTIVITY BY A USER
  Future<void> fetchActivityDetails(String activityId) async {
    var activity = await API.fetchActivityById(activityId);
    if (activity != null) {
      debugPrint("Activity Details: $activity");
    } else {
      debugPrint("Failed to fetch activity details.");
    }
  }

  // ACTIVITY LOGS ARE FETCHED FROM THE BACKEND USING THE USERID SAVED IN THE LOCAL STORAGE
  Future<void> _loadActivityLogs() async {
    final userId = await getUserId(); // Await the userId
    debugPrint(" Retrieved userId: $userId");

    if (userId == null) {
      debugPrint("❌ User ID not found in SharedPreferences");
      return;
    }

    debugPrint("Fetching logs... Show all logs: $showAllLogs");

    // FETCH ALL ACTIVITY LOGS OR PER USER
    final logsData = showAllLogs
        ? await API.fetchAllActivityLogs() // Fetch all users' logs
        : await API.fetchActivityLogs(userId); // Fetch only current user's logs

    if (logsData != null) {
      if (mounted) {
        // ✅ Prevent updating state if widget is disposed
        setState(() {
          activityLogs = logsData
              .map((log) {
                try {
                  // Ensure countedAmount is properly parsed
                  final parsedLog = ActivityLog.fromJson(log);
                  debugPrint("RAW LOG DATA: $log");

                  // Log object count for debugging
                  debugPrint(
                      "COUNTED OBJECT Parsed log: ID=${parsedLog.id}, Object Count=${parsedLog.countedAmount}");

                  return parsedLog;
                } catch (e) {
                  debugPrint("❌ Error parsing log: $log \n Exception: $e");
                  return null;
                }
              })
              .whereType<ActivityLog>()
              .toList();
        });
        debugPrint("✅ Logs updated: ${activityLogs.length} logs");
      }
    } else {
      debugPrint("❌ No logs retrieved");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Activity Logs"),
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
      endDrawer: const SideMenu(), // Using the extracted drawer
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24, top: 12, bottom: 0),
            child: Row(
              children: [
                const Text("Show All Users' Logs"),
                const SizedBox(width: 10),
                Switch(
                  value: showAllLogs,
                  onChanged: (value) {
                    setState(() {
                      showAllLogs = value;
                      _loadActivityLogs(); // Reload data when toggling
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.green,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor:
                      Colors.black54.withAlpha((0.25 * 255).toInt()),
                ),
              ],
            ),
          ),

          // ✅ Scrollable content stays below
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DataTable(
                      columns: const [
                        DataColumn(label: Text('User ID')),
                        DataColumn(label: Text('Full Name')),
                        DataColumn(label: Text('Action')),
                        DataColumn(label: Text('Objects Counted')),
                        DataColumn(label: Text('Timestamp')),
                      ],
                      rows: activityLogs.map((log) {
                        return DataRow(cells: [
                          DataCell(Text(log.userId)),
                          DataCell(Text(log.fullName)),
                          DataCell(Text(log.action)),
                          DataCell(Text(log.countedAmount == 0 ? ' ' : log.countedAmount.toString())),
                          DataCell(Text(log.timestamp)),
                        ]);
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                textStyle: TextStyle(fontSize: 16),
                backgroundColor: const Color.fromARGB(255, 10, 125, 170),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 118, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                      color: const Color.fromARGB(255, 3, 130, 168), width: 2),
                ),
              ),
              onPressed: () {},
              child: const Text("Generate"),
            ),
          ),
        ],
      ),
    );
  }
}
