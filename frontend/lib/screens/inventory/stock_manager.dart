import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/widgets/add_product.dart';

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
              onAddStock: (String name, int count) {
                setState(() {
                  stockCounts[name] = {
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

  // INFO DISPLAYED IN THE CARDS PULLED FROM THE STOCKS COLLECTION
  Future<void> fetchStockData() async {
    Map<String, Map<String, int>>? data = await API.fetchStockFromMongoDB();
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

  void updateStock(String item, int newCount) {
    if (stockCounts.containsKey(item)) {
      setState(() {
        stockCounts[item]?["totalStock"] = newCount;
      });

      API.saveStockToMongoDB(stockCounts);
    }
  }

  void deleteStockItem(String item) {
    setState(() => stockCounts.remove(item));
    API.deleteStockFromMongoDB(item);
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = stockCounts.keys
        .where((key) => key.toLowerCase().contains(searchQuery))
        .toList();

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
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
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
                            searchQuery = value.toLowerCase();
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
                                              fontSize: 16,
                                              // fontWeight: FontWeight.w500,
                                              color: Colors.grey[700],
                                            )),
                                        Text("Sold: $sold",
                                            textAlign: TextAlign.start,
                                            style: TextStyle(
                                              fontSize: 16,
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
                                          fontSize: 16,
                                          // fontWeight: FontWeight.w500,
                                          color: Colors.grey[700],
                                        )),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_horiz),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            TextEditingController
                                                editController =
                                                TextEditingController(
                                                    text:
                                                        totalStock.toString());
                                            return AlertDialog(
                                              title: Text("Edit $item Stock"),
                                              content: TextField(
                                                controller: editController,
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    int? newCount =
                                                        int.tryParse(
                                                            editController
                                                                .text);
                                                    if (newCount != null) {
                                                      updateStock(
                                                          item, newCount);
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text("Save"),
                                                )
                                              ],
                                            );
                                          },
                                        );
                                      } else if (value == 'delete') {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Delete $item?"),
                                            content: Text(
                                                "Are you sure you want to remove this stock item?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text("Cancel",
                                                    style: TextStyle(
                                                        color:
                                                            Colors.grey[600])),
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
                                        value: 'edit',
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue[
                                                50], // light blue background for edit
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8, horizontal: 4),
                                          child: Row(
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.center,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.edit,
                                                  color: Colors.blue[400]),
                                              SizedBox(width: 8),
                                              Text('Edit',
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
                                            // crossAxisAlignment:
                                            //     CrossAxisAlignment.center,
                                            // mainAxisAlignment:
                                            //     MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.delete,
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
