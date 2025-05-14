import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';

class SellRestockHelper {
  /// Handles restocking by updating the stockCounts map.
  static void updateStock(
    Map<String, Map<String, int>> stockCounts,
    String initialName,
    int restockAmount,
  ) {
    if (stockCounts.containsKey(initialName)) {
      int currentTotalStock = stockCounts[initialName]?["totalStock"] ?? 0;
      int currentAvailableStock =
          stockCounts[initialName]?["availableStock"] ?? 0;

      stockCounts[initialName]?["totalStock"] =
          currentTotalStock + restockAmount;
      stockCounts[initialName]?["availableStock"] =
          currentAvailableStock + restockAmount;

      // sold remains unchanged
      debugPrint("🔁 Restocking $initialName: +$restockAmount");
      debugPrint(
          "➡️ New total: ${stockCounts[initialName]?["totalStock"]}, available: ${stockCounts[initialName]?["availableStock"]}");
      API.saveSingleStockToMongoDB(initialName, stockCounts[initialName]!);
    }
  }

  /// Handles selling and returns a boolean to indicate success or failure.
  static bool updateStockForSale(
    Map<String, Map<String, int>> stockCounts,
    String initialName,
    int sellAmount,
  ) {
    if (stockCounts.containsKey(initialName)) {
      int currentAvailableStock =
          stockCounts[initialName]?["availableStock"] ?? 0;

      if (sellAmount > currentAvailableStock) {
        return false; // Not enough stock
      }

      stockCounts[initialName]?["availableStock"] =
          currentAvailableStock - sellAmount;
      stockCounts[initialName]?["sold"] =
          (stockCounts[initialName]?["sold"] ?? 0) + sellAmount;

      // totalStock remains unchanged
      debugPrint("🔁 Selling $initialName: -$sellAmount");
      debugPrint(
          "➡️ Remaining: ${stockCounts[initialName]?["availableStock"]}, sold: ${stockCounts[initialName]?["sold"]}");
      API.saveSingleStockToMongoDB(initialName, stockCounts[initialName]!);
      return true;
    }
    return false;
  }
}
