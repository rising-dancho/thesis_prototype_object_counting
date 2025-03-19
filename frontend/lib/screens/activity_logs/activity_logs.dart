import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      appBar: AppBar(title: const Text("Activity Logs")),
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
