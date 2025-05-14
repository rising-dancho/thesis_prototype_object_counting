import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';

class UpdateStockPriceDialog extends StatefulWidget {
  final String itemName;
  final double initialPrice;
  final Function(double newPrice) onPriceUpdated;

  const UpdateStockPriceDialog({
    super.key,
    required this.itemName,
    required this.initialPrice,
    required this.onPriceUpdated,
  });

  @override
  State<UpdateStockPriceDialog> createState() => _UpdateStockPriceDialogState();
}

class _UpdateStockPriceDialogState extends State<UpdateStockPriceDialog> {
  late TextEditingController _priceController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.initialPrice.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  void updatePrice() async {
    double? newPrice = double.tryParse(_priceController.text.trim());
    if (newPrice != null && newPrice >= 0) {
      setState(() => isLoading = true);

      bool success = await API.updateStockPrice(widget.itemName, newPrice);
      if (success) {
        widget.onPriceUpdated(newPrice);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update price')),
        );
      }

      setState(() => isLoading = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Enter a valid price')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Update Price',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.itemName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: Icon(Icons.close),
                  color: Colors.grey[700],
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: "Enter new price",
              labelStyle: TextStyle(
                color: Colors.grey[700], // Default (unfocused) label color
              ),
              floatingLabelStyle: TextStyle(
                color: Color(0xFF416FDF), // Focused label color
                // fontWeight: FontWeight.w600,
              ),
              hintText: "e.g. 120.50",
              hintStyle: const TextStyle(color: Colors.black26),
              filled: true,
              fillColor: Colors.grey[200],
              border: InputBorder.none,
              // focusedBorder: OutlineInputBorder(
              //   borderSide: BorderSide(color: Colors.blue, width: 2.0),
              //   borderRadius: BorderRadius.circular(8.0),
              // ),
              // enabledBorder: OutlineInputBorder(
              //   borderSide: BorderSide(color: Colors.transparent),
              //   borderRadius: BorderRadius.circular(8.0),
              // ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : updatePrice,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                // backgroundColor: Colors.orange[500],
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'UPDATE',
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
