class ActivityLog {
  final String userName;
  final String action;
  final int countedAmount;
  final String timestamp;

  ActivityLog({
    required this.userName,
    required this.action,
    required this.countedAmount,
    required this.timestamp,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      userName: json['fullName'] ?? 'Unknown User', 
      action: json['action'] ?? 'Unknown Action',
      countedAmount: json['countedAmount'] ?? 0, 
      timestamp: json['createdAt'] ?? 'Unknown Time', 
    );
  }
}