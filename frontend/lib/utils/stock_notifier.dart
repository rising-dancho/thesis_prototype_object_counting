
import 'package:tectags/services/notif_service.dart';

class StockNotifier {
  static void checkStockAndNotify(int stockAmount, String stockName) {
    if (stockAmount == 0) {
      NotifService().showNotification(
        title: "Out of Stock",
        body: "$stockName is out of stock!",
      );
    } else if (stockAmount < 5) {
      NotifService().showNotification(
        title: "Low Stock Warning",
        body: "$stockName is running low. Only $stockAmount left!",
      );
    }
  }
}