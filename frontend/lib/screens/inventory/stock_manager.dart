import 'package:flutter/material.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/api.dart';

class StockManager extends StatefulWidget {
  const StockManager({super.key});

  @override
  State<StockManager> createState() => _StockManagerState();
}

class _StockManagerState extends State<StockManager> {
  TextEditingController itemController = TextEditingController();
  TextEditingController countController = TextEditingController();
  Map<String, int> stockCounts = {};

  // BACKUP
  // Map<String, int> stockCounts = {
  //   "Cement": 100,
  //   "Sand": 100,
  //   "Hollow Blocks": 100,
  //   "Plywood": 100,
  //   "Deform Bar": 100,
  // };

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  void fetchStockData() async {
    Map<String, int>? data = await API.fetchStockFromMongoDB();

    debugPrint("Fetched Stock Data: $data"); // Debug print

    if (data != null && mounted) {
      setState(() {
        stockCounts = data;
      });

      debugPrint("Updated StockCounts: $stockCounts"); // Debug print
    }
  }

  void addStockItem() {
    String itemName = itemController.text.trim();
    int? itemCount = int.tryParse(countController.text.trim());

    if (itemName.isNotEmpty && itemCount != null) {
      setState(() {
        stockCounts[itemName] = itemCount;
      });

      API.saveStockToMongoDB(stockCounts);

      itemController.clear();
      countController.clear();
    }
  }

  void updateStock(String item, int newCount) {
    setState(() {
      stockCounts[item] = newCount;
    });

    API.saveStockToMongoDB(stockCounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const SideMenu(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 0, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: itemController,
                      decoration: InputDecoration(labelText: "Stock Category"),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: countController,
                      decoration: InputDecoration(labelText: "Stock Count"),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: addStockItem,
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: stockCounts.isEmpty
                  ? Center(child: Text("No stock available."))
                  : ListView.builder(
                      itemCount: stockCounts.length,
                      itemBuilder: (context, index) {
                        String item = stockCounts.keys.elementAt(index);
                        int count = stockCounts[item] ?? 0;
                        return ListTile(
                          title: Text(item),
                          subtitle: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total: $count"),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  TextEditingController editController =
                                      TextEditingController(
                                          text: count.toString());
                                  return AlertDialog(
                                    title: Text("Edit $item Stock"),
                                    content: TextField(
                                      controller: editController,
                                      keyboardType: TextInputType.number,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          int? newCount =
                                              int.tryParse(editController.text);
                                          if (newCount != null) {
                                            updateStock(item, newCount);
                                          }
                                          Navigator.pop(context);
                                        },
                                        child: Text("Save"),
                                      )
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
