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


// class ActivityLog {
//   final String id;
//   final String userId;
//   final String fullName;
//   final String action;
//   final int? countedAmount;
//   final String timestamp;
//   final String stockName; // ✅ Add stockName
//   final int totalStock; // ✅ Add totalStock
//   final int availableStock; // ✅ Add availableStock

//   ActivityLog({
//     required this.id,
//     required this.userId,
//     required this.fullName,
//     required this.action,
//     this.countedAmount,
//     required this.timestamp,
//     required this.stockName, // ✅ Required now
//     required this.totalStock,
//     required this.availableStock,
//   });

//   factory ActivityLog.fromJson(Map<String, dynamic> json) {
//     return ActivityLog(
//       id: json['_id'] ?? 'Unknown ID',
//       userId: json['userId'] ?? 'Unknown ID',
//       fullName: json['fullName'] ?? 'Unknown User',
//       action: json['action'] ?? 'Unknown Action',
//       countedAmount: json['countedAmount'] ?? 0,
//       timestamp: json['createdAt'] ?? 'Unknown Time',
//       stockName: json['stockName'] ?? 'Unknown Stock', // ✅ Fix missing key
//       totalStock: json['totalStock'] ?? 0, // ✅ Default to 0 if missing
//       availableStock: json['availableStock'] ?? 0, // ✅ Default to 0 if missing
//     );
//   }
// }
