import 'package:flutter/material.dart';
// import 'package:tectags/models/stockdata_model.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/utils/label_formatter.dart';
import 'package:tectags/widgets/products/restock_product.dart';

class AddNewProduct extends StatefulWidget {
  final void Function(String name, int count, int sold, double price)
      onAddStock;
  final String? initialName;
  final int? itemCount;
  final String actionType; // "sell" or "restock"

  const AddNewProduct({
    super.key,
    required this.onAddStock,
    this.initialName,
    this.itemCount,
    required this.actionType,
  });

  @override
  State<AddNewProduct> createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  TextEditingController nameController = TextEditingController();
  TextEditingController countController = TextEditingController();
  TextEditingController soldController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  // form validation
  final _formKey = GlobalKey<FormState>();
  // FOR RESTOCKING
  Map<String, Map<String, dynamic>> stockCounts = {};

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    debugPrint("🛠 Initializing AddNewProduct — Sold: ${widget.itemCount}");
    soldController =
        TextEditingController(text: widget.itemCount?.toString() ?? '');
  }

  // FIXES THE SOLD NOT UPDATING CORRECTLY FROM _openAddProductModal
  @override
  void didUpdateWidget(covariant AddNewProduct oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.itemCount != oldWidget.itemCount) {
      soldController.text = widget.itemCount?.toString() ?? '';
    }
  }

  void addStockItem() {
    String rawItemName = nameController.text.trim();
    String itemName = LabelFormatter.titleCase(rawItemName);
    int? itemCount = int.tryParse(countController.text.trim());
    double? price = double.tryParse(priceController.text.trim());

    if (itemName.isNotEmpty && itemCount != null && price != null) {
      int itemSold = int.tryParse(soldController.text.trim()) ?? 0;
      widget.onAddStock(itemName, itemCount, itemSold, price); // Notify parent

      // Clear fields after adding
      nameController.clear();
      countController.clear();
      priceController.clear();
      Navigator.pop(context); // Dismiss modal after adding
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
              initialAmount: widget.itemCount ?? 0,
              onRestock: (restockAmount) {
                updateStock(item, restockAmount);
              },
            ),
          ),
        );
      },
    );
  }

  void updateStock(String initialName, int restockAmount) {
    if (stockCounts.containsKey(initialName)) {
      setState(() {
        int currentTotalStock = stockCounts[initialName]?["totalStock"] ?? 0;
        int currentAvailableStock =
            stockCounts[initialName]?["availableStock"] ?? 0;

        stockCounts[initialName]?["totalStock"] =
            currentTotalStock + restockAmount;
        stockCounts[initialName]?["availableStock"] =
            currentAvailableStock + restockAmount;
        // 🔥 sold does NOT change
      });

      API.saveSingleStockToMongoDB(initialName, stockCounts[initialName]!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.actionType == 'sell'
                      ? "Sell Product"
                      : "Add New Stock",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                    color: Colors.grey[800],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // background color
                    borderRadius: BorderRadius.circular(8), // rounded corners
                  ),
                  child: IconButton(
                    icon: Icon(Icons.close),
                    color: Colors.grey[700], // icon color
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required: Please enter the stock name';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(
                  color: Colors.grey[700], // default color
                ),
                floatingLabelStyle: TextStyle(
                  color:
                      Color(0xFF416FDF), // 👈 color when the field is focused
                ),
                // hintText: 'Please enter the stock name',
                enabled: false, // 🔒 This disables the field
                hintStyle: const TextStyle(color: Colors.black26),
                fillColor: Colors.grey[200],
                filled: true,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: countController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required: Please enter the total stock count';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Total Stock Count',
                labelStyle: TextStyle(
                  color: Colors.grey[700], // default color
                ),
                floatingLabelStyle: TextStyle(
                  color:
                      Color(0xFF416FDF), // 👈 color when the field is focused
                ),
                hintText: 'Please set the total stock count for this stock',
                hintStyle: const TextStyle(color: Colors.black26),
                fillColor: Colors.grey[200],
                filled: true,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
            widget.actionType == 'sell'
                ? TextFormField(
                    controller: soldController,
                    keyboardType: TextInputType.number,
                    enabled: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required: Please enter the number of items sold';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Sold',
                      floatingLabelStyle: TextStyle(color: Color(0xFF416FDF)),
                      hintStyle: const TextStyle(color: Colors.black26),
                      fillColor: Colors.grey[200],
                      filled: true,
                      border: InputBorder.none,
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: () {
                      if (nameController.text.trim().isNotEmpty) {
                        _openRestockStockModal(
                          context,
                          LabelFormatter.titleCase(nameController.text.trim()),
                        );
                      }
                    },
                    icon: Icon(Icons.add),
                    label: Text('Restock This Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
            const SizedBox(height: 10),
            TextFormField(
              controller: priceController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Required: Please enter the price per item/unit';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Price per Unit',
                labelStyle: TextStyle(
                  color: Colors.grey[700], // default color
                ),
                floatingLabelStyle: TextStyle(
                  color:
                      Color(0xFF416FDF), // 👈 color when the field is focused
                ),
                hintText: 'Please enter the price per item/unit',
                hintStyle: const TextStyle(color: Colors.black26),
                fillColor: Colors.grey[200],
                filled: true,
                border: InputBorder.none,
                // prefixIcon: Icon(Icons.payments),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                  // backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addStockItem();
                  }
                },
                child: const Text(
                  'ADD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
