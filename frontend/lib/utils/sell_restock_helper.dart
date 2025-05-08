import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';

class SellRestockHelper {
  /// Handles restocking by updating the stockCounts map.
  static void updateStock(
    Map<String, Map<String, int>> stockCounts,
    String item,
    int restockAmount,
  ) {
    if (stockCounts.containsKey(item)) {
      int currentTotalStock = stockCounts[item]?["totalStock"] ?? 0;
      int currentAvailableStock = stockCounts[item]?["availableStock"] ?? 0;

      stockCounts[item]?["totalStock"] = currentTotalStock + restockAmount;
      stockCounts[item]?["availableStock"] =
          currentAvailableStock + restockAmount;

      // sold remains unchanged
      debugPrint("🔁 Restocking $item: +$restockAmount");
      debugPrint(
          "➡️ New total: ${stockCounts[item]?["totalStock"]}, available: ${stockCounts[item]?["availableStock"]}");
      API.saveStockToMongoDB(stockCounts);
    }
  }

  /// Handles selling and returns a boolean to indicate success or failure.
  static bool updateStockForSale(
    Map<String, Map<String, int>> stockCounts,
    String item,
    int sellAmount,
  ) {
    if (stockCounts.containsKey(item)) {
      int currentAvailableStock = stockCounts[item]?["availableStock"] ?? 0;

      if (sellAmount > currentAvailableStock) {
        return false; // Not enough stock
      }

      stockCounts[item]?["availableStock"] = currentAvailableStock - sellAmount;
      stockCounts[item]?["sold"] =
          (stockCounts[item]?["sold"] ?? 0) + sellAmount;

      // totalStock remains unchanged
      debugPrint("🔁 Selling $item: -$sellAmount");
      debugPrint(
          "➡️ Remaining: ${stockCounts[item]?["availableStock"]}, sold: ${stockCounts[item]?["sold"]}");
      API.saveStockToMongoDB(stockCounts);
      return true;
    }
    return false;
  }
}
