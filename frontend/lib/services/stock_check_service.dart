import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/utils/stock_notifier.dart';

class StockCheckService {
  static Future<void> checkStocks() async {
    final stockData = await API.fetchStockFromMongoDB();

    if (stockData != null) {
      for (var entry in stockData.entries) {
        String stockName = entry.key;
        int availableStock = entry.value["availableStock"] ?? 0;
        int totalStock = entry.value["totalStock"] ?? 0;

        StockNotifier.checkStockAndNotify(
            availableStock, totalStock, stockName);
      }
    } else {
      debugPrint("Failed to fetch stock data.");
    }
  }
}
