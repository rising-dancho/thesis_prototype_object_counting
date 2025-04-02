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
      userName: json['userId']['fullName'],
      action: json['action'],
      objectCount: json['objectCount'],
      timestamp: json['timestamp'],
    );
  }
}
