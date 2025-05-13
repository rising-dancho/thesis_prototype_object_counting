import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/stock_check_service.dart';
import 'package:tectags/utils/stock_notifier.dart';
import 'package:tectags/widgets/products/add_product.dart';
import 'package:tectags/widgets/products/restock_product.dart';
import 'package:tectags/widgets/products/sell_product.dart';

class StockManager extends StatefulWidget {
  const StockManager({super.key});

  @override
  State<StockManager> createState() => _StockManagerState();
}

class _StockManagerState extends State<StockManager> {
  Map<String, Map<String, int>> stockCounts = {};
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchStockData();
    StockCheckService
        .checkStocks(); // Trigger fresh stock check when inventory screen opens
  }

  void _openAddProductModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
                child: AddProduct(
              stockCounts: stockCounts,
              onAddStock: (String initialName, int count) {
                setState(() {
                  stockCounts[initialName] = {
                    "availableStock": count,
                    "totalStock": count,
                    "sold": 0,
                  };
                });
                API.saveStockToMongoDB(stockCounts);
              },
            )));
      },
    );
  }

  void _openSellStockModal(BuildContext context, String item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: SellProduct(
              itemName: item,
              onSell: (sellAmount) {
                updateStockForSale(item, sellAmount);
              },
              isSelling: true,
            ),
          ),
        );
      },
    );
  }

  void updateStockForSale(String item, int sellAmount) {
    if (stockCounts.containsKey(item)) {
      int currentAvailableStock = stockCounts[item]?["availableStock"] ?? 0;
      int totalStock = stockCounts[item]?["totalStock"] ?? 0;
      String stockId = stockCounts[item]?["_id"].toString() ?? "";

      if (sellAmount > currentAvailableStock) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insufficient stocks to sell')),
        );
        return;
      }

      setState(() {
        stockCounts[item]?["availableStock"] =
            currentAvailableStock - sellAmount;
        stockCounts[item]?["sold"] =
            (stockCounts[item]?["sold"] ?? 0) + sellAmount;
      });

      int updatedStock = stockCounts[item]?["availableStock"] ?? 0;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Sold $sellAmount $item(s). Remaining stock: $updatedStock'),
        ),
      );

      // 🔄 Save updated stock to DB
      API.saveStockToMongoDB(stockCounts);

      // ✅ Call centralized stock checker
      StockNotifier.checkStockAndNotify(
        updatedStock,
        totalStock,
        item,
        stockId,
      );
    }
  }

  void _openRestockStockModal(BuildContext context, String item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: RestockProduct(
              itemName: item,
              initialAmount: 0,
              onRestock: (restockAmount) {
                updateStock(item, restockAmount);
              },
            ),
          ),
        );
      },
    );
  }

  void updateStock(String item, int restockAmount) {
    if (stockCounts.containsKey(item)) {
      setState(() {
        int currentTotalStock = stockCounts[item]?["totalStock"] ?? 0;
        int currentAvailableStock = stockCounts[item]?["availableStock"] ?? 0;

        stockCounts[item]?["totalStock"] = currentTotalStock + restockAmount;
        stockCounts[item]?["availableStock"] =
            currentAvailableStock + restockAmount;
        // 🔥 sold does NOT change
      });

      API.saveStockToMongoDB(stockCounts);
    }
  }

  // INFO DISPLAYED IN THE CARDS PULLED FROM THE STOCKS COLLECTION
  Future<void> fetchStockData() async {
    Map<String, Map<String, dynamic>>? data = await API.fetchStockFromMongoDB();
    debugPrint("Fetched Stock Data: $data");
    debugPrint("STOCK COUNTS Data: $stockCounts");

    if (data == null) {
      debugPrint("⚠️ No stock data fetshed.");
      return; // Exit early if data is null
    }

    if (mounted) {
      setState(() {
        stockCounts = data.map((key, value) => MapEntry(key, {
              "availableStock": value["availableStock"] ?? 0,
              "totalStock": value["totalStock"] ?? 0,
              "sold": value["sold"] ?? 0,
            }));
      });
      debugPrint("Updated StockCounts: $stockCounts");
    }
  }

  void deleteStockItem(String item) {
    setState(() => stockCounts.remove(item));
    API.deleteStockFromMongoDB(item);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("🔄 Rebuilding StockManager UI");
    final filteredItems = stockCounts.keys
        .where((key) => key.toLowerCase().contains(searchQuery))
        .toList();

    debugPrint("Filtered items: $filteredItems");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Inventory Management",
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Color.fromARGB(255, 27, 211, 224),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        // MODIFY FOR NOTIFICATION HISTORY:
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.notifications),
        //     onPressed: () async {
        //       await NotifService().initNotification();

        //       // Fetch stocks and check their levels when the user presses the notification button
        //       final token = await SharedPrefsService.getToken();
        //       if (token == null || token.isEmpty) {
        //         debugPrint("Token not found.");
        //         return;
        //       }

        //       final response = await http.get(
        //         Uri.parse('${API.baseUrl}stocks'),
        //         headers: {
        //           'Authorization': 'Bearer $token',
        //         },
        //       );

        //       if (response.statusCode == 200) {
        //         final List<dynamic> stocks = jsonDecode(response.body);

        //         // Check stock level for each item
        //         for (var stock in stocks) {
        //           final int stockAmount = stock['availableStock'];
        //           final String stockName = stock['stockName'];

        //           // Trigger stock notifications based on stock levels
        //           StockNotifier.checkStockAndNotify(stockAmount, stockName);
        //         }
        //       } else {
        //         debugPrint(
        //             "Failed to fetch stock list: ${response.statusCode}");
        //       }
        //     },
        //   ),
        //   Builder(
        //     builder: (context) => IconButton(
        //       icon: Icon(Icons.menu),
        //       onPressed: () {
        //         Scaffold.of(context).openEndDrawer();
        //       },
        //     ),
        //   ),
        // ],
      ),
      endDrawer: const SideMenu(),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/tectags_bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value.toLowerCase().trim();
                          });
                        },
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: const Color.fromARGB(255, 233, 233, 233),
                          hintText: 'Search for any stock name..',
                          hintStyle: const TextStyle(color: Colors.black38),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: stockCounts.isEmpty
                    ? const Center(
                        child: Text(
                        "No stocks available.",
                        style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                            color: Colors.white),
                      ))
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        itemBuilder: (context, index) {
                          String item = filteredItems[index];
                          int availableStock =
                              stockCounts[item]?["availableStock"] ?? 0;
                          int totalStock =
                              stockCounts[item]?["totalStock"] ?? 0;
                          int sold = stockCounts[item]?["sold"] ?? 0;

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: const Color.fromARGB(234, 255, 255, 255),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              item,
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text("Available: $availableStock",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            )),
                                        Text("Sold: $sold",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 14,
                                              // fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(right: 15),
                                    child: Text("Total: $totalStock",
                                        style: TextStyle(
                                          fontSize: 14,
                                          // fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        )),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_horiz),
                                    onSelected: (value) {
                                      if (value == 'restock') {
                                        _openRestockStockModal(context, item);
                                      } else if (value == 'sell') {
                                        _openSellStockModal(context, item);
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text(
                                              "Delete $item?",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                            content: Text(
                                              "Are you sure you want to remove this stock item?",
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[800])),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteStockItem(item);
                                                  Navigator.pop(context);
                                                },
                                                child: Text("Delete",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.red[400])),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'restock',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.green[50],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.add_box,
                                                  color: Colors.green[400]),
                                              SizedBox(width: 5),
                                              Text('Restock',
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    // fontSize: 15.0,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'sell',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue[50],
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                  Icons.indeterminate_check_box,
                                                  color: Colors.blue[400]),
                                              SizedBox(width: 5),
                                              Text('Sell',
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    // fontSize: 15.0,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red[
                                                50], // light red background for delete
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete_rounded,
                                                  color: Colors.red[400]),
                                              SizedBox(width: 8),
                                              Text('Delete',
                                                  style: TextStyle(
                                                    fontFamily: 'Roboto',
                                                    // fontSize: 15.0,
                                                    fontWeight: FontWeight.w400,
                                                  )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddProductModal(context),
        tooltip: 'Add Product',
        backgroundColor:
            Color.fromARGB(255, 22, 165, 221), // Change background color
        foregroundColor: Colors.white, // Change icon/text color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 24.0,
        ),
      ),
    );
  }
}

// onSell spitting out the sellAmount to feed into the  updateStockForSale(item, sellAmount);
//  onSell: (sellAmount) {
              //   updateStockForSale(item, sellAmount);
              // },
// https://chatgpt.com/share/681b4066-452c-8000-b65c-d1e2a9477357