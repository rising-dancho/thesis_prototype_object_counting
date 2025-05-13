class StockData {
  int totalStock;
  int availableStock;
  int sold;
  double price;

  StockData({
    required this.totalStock,
    required this.availableStock,
    required this.sold,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'totalStock': totalStock,
        'availableStock': availableStock,
        'sold': sold,
        'price': price,
      };
}
