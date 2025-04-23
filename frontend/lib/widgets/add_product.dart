import 'package:flutter/material.dart';

class AddProduct extends StatefulWidget {
  final VoidCallback addStockItem;
  const AddProduct({super.key, required this.addStockItem});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
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
                  color: Colors.grey[700],
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
          const SizedBox(height: 10),
          TextField(decoration: InputDecoration(labelText: "Product Name")),
          TextField(decoration: InputDecoration(labelText: "Total Count")),
          TextField(decoration: InputDecoration(labelText: "Price")),
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
              onPressed: widget.addStockItem,
              child: const Text(
                'Save',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
