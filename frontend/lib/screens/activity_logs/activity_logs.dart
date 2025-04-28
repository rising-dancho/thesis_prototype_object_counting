import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tectags/page/pdf_page.dart';
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

    debugPrint("🧾 RAW COUNT AMOUNT in JSON: ${json['countedAmount']}");

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
        title: const Text(
          "Activity Logs",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Color.fromARGB(255, 27, 211, 224),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const SideMenu(), // Using the extracted drawer
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/tectags_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 12, bottom: 0),
              child: Row(
                children: [
                  Text(
                    "Show All Users' Logs",
                    style: TextStyle(
                      color:
                          Colors.white, // Change this to any color you prefer
                      fontSize: 15, // Optional: Adjust the font size
                    ),
                  ),
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
                    inactiveTrackColor: const Color.fromARGB(255, 243, 243, 243)
                        .withAlpha((0.25 * 255).toInt()),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 50),
            // ✅ White Table for Logs
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DataTable(
                        dataRowHeight: 60, // Adjust row height
                        headingRowHeight: 56, // Adjust header row height
                        columnSpacing: 20, // Adjust space between columns
                        decoration: BoxDecoration(
                          color: Colors
                              .white, // Set white background color for the table
                          borderRadius: BorderRadius.circular(
                              15), // Rounded corners for the table
                          boxShadow: [
                            // Optional: Add shadow for a 3D effect
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        columns: [
                          DataColumn(
                            label: Text(
                              'User ID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Full Name',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Action',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Total Sold',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Timestamp',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                        rows: activityLogs.map((log) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(log.userId),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(log.fullName),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(log.action),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(log.countedAmount == 0
                                      ? ' '
                                      : log.countedAmount.toString()),
                                ),
                              ),
                              DataCell(
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(log.timestamp),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                  width: double
                      .infinity, // Makes the button take all horizontal space
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => PdfPage()),
                      );
                    },
                    child: const Text(
                      'Generate Reports',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 15.0,
                      ),
                    ),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
