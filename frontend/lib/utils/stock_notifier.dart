import 'package:tectags/services/notif_service.dart';

class StockNotifier {
  static const List<int> percentageThresholds = [50, 25, 15, 10, 5];
  static final Map<String, String?> _lastNotifiedThreshold = {};

  static Future<void> checkStockAndNotify(
    int availableStock,
    int totalStock,
    String stockName,
  ) async {
    if (totalStock == 0) return; // Avoid division by zero

    final percentage = (availableStock / totalStock) * 100;
    final stockKey = stockName.toLowerCase();

    // 1. Handle Out of Stock (0 units left)
    if (availableStock == 0) {
      if (_lastNotifiedThreshold[stockKey] != 'critical') {
        await NotifService().showNotification(
          title: "Out of Stock",
          body: "$stockName is out of stock!",
        );
        _lastNotifiedThreshold[stockKey] = 'critical';
      }
      return;
    }

    // 2. Find the closest matching threshold
    int? closestThreshold;
    for (int threshold in percentageThresholds) {
      if (percentage <= threshold) {
        closestThreshold = threshold;
      }
    }

    // 3. Notify for that closest threshold only if it hasn’t been already
    if (closestThreshold != null) {
      final key = 'pct_$closestThreshold';
      if (_lastNotifiedThreshold[stockKey] != key) {
        await NotifService().showNotification(
          title: "Very Low Stock",
          body:
              "$stockName has only $availableStock left! (stocks are below $closestThreshold%)",
        );
        _lastNotifiedThreshold[stockKey] = key;
      }
    } else {
      // Reset if stock is healthy again
      _lastNotifiedThreshold[stockKey] = null;
    }
  }
}

// import 'package:tectags/services/notif_service.dart';

// class StockNotifier {
//   static const List<int> percentageThresholds = [50, 25, 15, 10, 5];
//   static const int lowAmountThreshold = 5;

//   static Future<void> checkStockAndNotify(
//     int availableStock,
//     int totalStock,
//     String stockName,
//   ) async {
//     if (totalStock == 0) return; // Avoid division by zero

//     final percentage = (availableStock / totalStock) * 100;

//     // 1. Find the lowest matching threshold (closest to actual %)
//     int? closestThreshold;
//     for (int threshold in percentageThresholds) {
//       if (percentage <= threshold) {
//         closestThreshold = threshold;
//       }
//     }

//     if (closestThreshold != null) {
//       await NotifService().showNotification(
//         title: "Stock Warning",
//         body:
//             "$stockName is at ${percentage.toStringAsFixed(0)}% of total stock",
//       );
//     }

//     // 2. Notify if availableStock is critically low or zero
//     if (availableStock == 0) {
//       await NotifService().showNotification(
//         title: "Out of Stock",
//         body: "$stockName is out of stock!",
//       );
//     } else if (availableStock <= lowAmountThreshold) {
//       await NotifService().showNotification(
//         title: "Very Low Stock",
//         body: "$stockName has only $availableStock left!",
//       );
//     }
//   }
// }
