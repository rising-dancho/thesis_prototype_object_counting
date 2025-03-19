import 'package:flutter/material.dart';

class ActivityLogs extends StatefulWidget {
  const ActivityLogs({super.key});

  @override
  State<ActivityLogs> createState() => _ActivityLogsState();
}

class _ActivityLogsState extends State<ActivityLogs> {
  get activityLogs => null;

  @override
  Widget build(BuildContext context) {
    TableRow tableRow = const TableRow(children: <Widget>[
      Padding(
        padding: EdgeInsets.all(8),
        child: Text("cell 1"),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: Text("cell 2"),
      ),
      Padding(
        padding: EdgeInsets.all(8),
        child: Text("cell 3"),
      ),
    ]);
    return Scaffold(
      appBar: AppBar(title: Text("Activity Logs")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            width: double.infinity, // Makes the container full-width
            color: Colors.grey[200],
            alignment: Alignment.center,
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
