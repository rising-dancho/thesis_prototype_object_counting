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

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  void fetchStockData() async {
    Map<String, int>? data = await API.fetchStockFromMongoDB();

    if (data != null) {
      setState(() {
        stockCounts = data;
      });
    }
  }

  // BACKUP
  // Map<String, int> stockCounts = {
  //   "Cement": 100,
  //   "Sand": 100,
  //   "Hollow Blocks": 100,
  //   "Plywood": 100,
  //   "Deform Bar": 100,
  // };

  Map<String, int> stockCounts = {};

  void addStockItem() {
    String itemName = itemController.text.trim();
    int? itemCount = int.tryParse(countController.text.trim());

    if (itemName.isNotEmpty && itemCount != null) {
      setState(() {
        stockCounts[itemName] = itemCount;
      });

      // Call function to save to MongoDB
      API.saveStockToMongoDB(stockCounts);

      itemController.clear();
      countController.clear();
    }
  }

  void updateStock(String item, int newCount) {
    setState(() {
      stockCounts[item] = newCount;
    });

    // Call function to update in MongoDB
    API.saveStockToMongoDB(stockCounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        backgroundColor: const Color.fromARGB(255, 5, 45, 90),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            // Input fields for adding new stock category
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

            // List of stocks with editable values
            Expanded(
              child: ListView(
                children: stockCounts.keys.map((item) {
                  return ListTile(
                    title: Text(item),
                    subtitle: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Current: 55"),
                        Expanded(child: SizedBox()),
                        Text("Total: ${stockCounts[item]}")
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        // Open a dialog to edit stock count
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController editController =
                                TextEditingController(
                                    text: stockCounts[item].toString());
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
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
