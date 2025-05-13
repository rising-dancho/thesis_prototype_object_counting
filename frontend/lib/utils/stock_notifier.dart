import 'package:tectags/services/notif_service.dart';

class StockNotifier {
  static const List<int> percentageThresholds = [50, 25, 15, 10, 5];
  static final Map<String, String?> _lastNotifiedThreshold = {};

  static Future<void> checkStockAndNotify(
    int availableStock,
    int totalStock,
    String stockName,
    String stockId,
  ) async {
    if (totalStock == 0) return; // Avoid division by zero

    final percentage = (availableStock / totalStock) * 100;
    final stockKey = stockName.toLowerCase();
    final notificationId = stockId.hashCode & 0x7FFFFFFF; // 🔹 Generate safe ID

    // 1. Handle Out of Stock (0 units left)
    if (availableStock == 0) {
      if (_lastNotifiedThreshold[stockKey] != 'critical') {
        await NotifService().showNotification(
          id: notificationId,
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
          id: notificationId,
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