import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/utils/stock_notifier.dart';
import 'package:tectags/services/notif_service.dart'; // needed for grouped notification

class StockCheckService {
  static Future<void> checkStocks() async {
    final stockData = await API.fetchStockFromMongoDB();

    if (stockData != null) {
      await checkAllStocks(stockData);
    } else {
      debugPrint("Failed to fetch stock data.");
    }
  }

  static Future<void> checkAllStocks(
      Map<String, Map<String, dynamic>> stockData) async {
    final List<String> notifiedItems = [];

    for (var entry in stockData.entries) {
      String stockName = entry.key;
      int availableStock = entry.value["availableStock"] ?? 0;
      int totalStock = entry.value["totalStock"] ?? 0;
      String stockId = entry.value["_id"].toString(); // 👈 Ensure this is included in your API

      bool shouldNotify = await StockNotifier.checkStockAndNotify(
        availableStock,
        totalStock,
        stockName,
        stockId,
      );

      if (shouldNotify) {
        notifiedItems.add(stockName);
      }
    }

    if (notifiedItems.length > 1) {
      await NotifService().showGroupedSummaryNotification();
    }
  }
}
