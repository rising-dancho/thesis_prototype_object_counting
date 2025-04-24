import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/utils/label_formatter.dart';

class AddProduct extends StatefulWidget {
  final Map<String, Map<String, int>> stockCounts;
  final void Function(String name, int count) onAddStock;

  const AddProduct({
    super.key,
    required this.stockCounts,
    required this.onAddStock,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController itemController = TextEditingController();
  TextEditingController countController = TextEditingController();
  TextEditingController priceController = TextEditingController();

  void addStockItem() {
    String rawItemName = itemController.text.trim();
    String itemName = LabelFormatter.titleCase(rawItemName);
    int? itemCount = int.tryParse(countController.text.trim());

    if (itemName.isNotEmpty && itemCount != null) {
      widget.onAddStock(itemName, itemCount); // Notify parent
      itemController.clear();
      countController.clear();
      Navigator.pop(context); // Dismiss modal after adding
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Product",
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
            controller: itemController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the stock name';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Stock Name',
              labelStyle: TextStyle(
                color: Colors.grey[700], // default color
              ),
              floatingLabelStyle: TextStyle(
                color: Color(0xFF416FDF), // 👈 color when the field is focused
              ),
              hintText: 'Please enter the stock name',
              hintStyle: const TextStyle(color: Colors.black26),
              fillColor: Colors.grey[200],
              filled: true,
              border: InputBorder.none,
              // prefixIcon: Icon(Icons.new_label),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: countController,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the count';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Stock Count',
              labelStyle: TextStyle(
                color: Colors.grey[700], // default color
              ),
              floatingLabelStyle: TextStyle(
                color: Color(0xFF416FDF), // 👈 color when the field is focused
              ),
              hintText: 'Please enter the stock count',
              hintStyle: const TextStyle(color: Colors.black26),
              fillColor: Colors.grey[200],
              filled: true,
              border: InputBorder.none,
              // prefixIcon: Icon(Icons.numbers),
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: priceController,
            keyboardType: TextInputType.number,
            validator: (value) {
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Stock Price',
              labelStyle: TextStyle(
                color: Colors.grey[700], // default color
              ),
              floatingLabelStyle: TextStyle(
                color: Color(0xFF416FDF), // 👈 color when the field is focused
              ),
              hintText: 'Please enter the stock price',
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
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: addStockItem,
              child: const Text(
                'SAVE',
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
    );
  }
}
