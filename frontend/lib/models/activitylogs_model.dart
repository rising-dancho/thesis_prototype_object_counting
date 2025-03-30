class ActivityLog {
  final String fullName;
  final String action;
  final int countedAmount;
  final String timestamp;

  ActivityLog({
    required this.fullName,
    required this.action,
    required this.countedAmount,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      fullName: json['fullName'] ?? 'Unknown User',
      action: json['action'] ?? 'Unknown Action',
      countedAmount:
          json.containsKey('countedAmount') && json['countedAmount'] != null
              ? json['countedAmount'] as int
              : 0,
      timestamp: json['createdAt'] ?? 'Unknown Time',
    );
  }
}
