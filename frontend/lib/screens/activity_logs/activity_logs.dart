import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';

class ActivityLog {
  final String userId; // ✅ Store userId
  final String fullName; // ✅ Store fullName
  final String action;
  final int? objectCount;
  final String
      timestamp; // Now holds: intl: ^0.18.1 a more human readable formatted time

  ActivityLog({
    required this.userId,
    required this.fullName,
    required this.action,
    this.objectCount,
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
      userId: json['userId'] ?? 'Unknown ID', // ✅ Handle missing userId
      fullName: json['fullName'] ?? 'Unknown User', // ✅ Handle missing fullName
      action: json['action'],
      objectCount: json['objectCount'],
      timestamp:
          formattedTimestamp, // Use formatted time ?? json['createdAt'], // ✅ Fallback to createdAt
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

  Future<void> _loadActivityLogs() async {
    final userId = await getUserId(); // Await the userId
    debugPrint(" Retrieved userId: $userId");

    if (userId == null) {
      debugPrint("❌ User ID not found in SharedPreferences");
      return;
    }

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
                  return ActivityLog.fromJson(log);
                } catch (e) {
                  debugPrint("❌ Error parsing log: $log \n Exception: $e");
                  return null;
                }
              })
              .whereType<ActivityLog>()
              .toList();
        });
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
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Row(children: [
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
                      ]),
                    ),
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
                          DataCell(Text(log.objectCount?.toString() ?? 'N/A')),
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
              child: const Text("Generate Reports"),
            ),
          ),
        ],
      ),
    );
  }
}
