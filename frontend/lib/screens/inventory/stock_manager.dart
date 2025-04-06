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

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  void fetchStockData() async {
    Map<String, int>? data = await API.fetchStockFromMongoDB();

    if (data != null && mounted) {
      setState(() {
        stockCounts = data;
      });
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

  void deleteStockItem(String item) {
    setState(() {
      stockCounts.remove(item);
    });

    API.deleteStockFromMongoDB(item);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory Management"),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: itemController,
                      decoration: InputDecoration(
                        labelText: 'Stock Category',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 233, 233, 233),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stock Count',
                        filled: true,
                        fillColor: const Color.fromARGB(255, 233, 233, 233),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: addStockItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 3, 130, 168),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: stockCounts.isEmpty
                  ? const Center(child: Text("No stock available."))
                  : ListView.builder(
                      itemCount: stockCounts.length,
                      itemBuilder: (context, index) {
                        String item = stockCounts.keys.elementAt(index);
                        int count = stockCounts[item] ?? 0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Card(
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Total: $count"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      TextEditingController editController =
                                          TextEditingController(
                                              text: count.toString());
                                      showDialog(
                                        context: context,
                                        builder: (context) {
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
                                                          editController.text);
                                                  if (newCount != null) {
                                                    updateStock(item, newCount);
                                                  }
                                                  Navigator.pop(context);
                                                },
                                                child: const Text("Save"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text("Delete $item?"),
                                            content: const Text(
                                                "Are you sure you want to remove this stock item?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  deleteStockItem(item);
                                                  Navigator.pop(context);
                                                },
                                                child: const Text(
                                                  "Delete",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
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
