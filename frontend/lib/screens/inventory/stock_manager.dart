import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StockManager extends StatefulWidget {
  const StockManager({super.key});

  @override
  State<StockManager> createState() => _StockManagerState();
}

class _StockManagerState extends State<StockManager> {
  Map<String, int> stockCounts = {
    "Cement": 100,
    "Sand": 100,
    "Hollow blocks": 100,
    "Plywood": 100,
    "Deform bar": 100,
  };

  TextEditingController itemController = TextEditingController();
  TextEditingController countController = TextEditingController();

  void addStockItem() {
    String itemName = itemController.text.trim();
    int? itemCount = int.tryParse(countController.text.trim());

    if (itemName.isNotEmpty && itemCount != null) {
      setState(() {
        stockCounts[itemName] = itemCount;
      });

      // Call function to save to MongoDB
      saveStockToMongoDB();

      itemController.clear();
      countController.clear();
    }
  }

  void updateStock(String item, int newCount) {
    setState(() {
      stockCounts[item] = newCount;
    });

    // Call function to update in MongoDB
    saveStockToMongoDB();
  }

  void saveStockToMongoDB() async {
    // Replace with your MongoDB connection logic
    var response = await http.post(
      Uri.parse("http://yourserver.com/api/stocks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(stockCounts),
    );
    debugPrint("Stock saved: ${response.body}");
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Input fields for adding new stock category
        Row(
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

        SizedBox(height: 10),

        // List of stocks with editable values
        Expanded(
          child: ListView(
            children: stockCounts.keys.map((item) {
              return ListTile(
                title: Text(item),
                subtitle: Text("Expected Count: ${stockCounts[item]}"),
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
    );
  }
}
