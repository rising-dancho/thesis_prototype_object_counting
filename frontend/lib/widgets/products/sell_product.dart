import 'package:flutter/material.dart';

class SellProduct extends StatefulWidget {
  final String itemName;
  final bool isSelling;
  final int initialAmount;
  final Function(int sellAmount) onSell;

  const SellProduct({
    super.key,
    required this.itemName,
    this.isSelling = false,
    this.initialAmount = 0,
    required this.onSell,
  });

  @override
  State<SellProduct> createState() => _SellProductState();
}

class _SellProductState extends State<SellProduct> {
  late TextEditingController _sellController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _sellController = TextEditingController(
      text: widget.initialAmount.toString(), // ✅ no need for null check
    );
  }

  @override
  void dispose() {
    _sellController.dispose();
    super.dispose();
  }

  void restockItem() {
    int? sellAmount = int.tryParse(_sellController.text.trim());
    if (sellAmount != null && sellAmount > 0) {
      setState(() {
        isLoading = true;
      });

      // Call the passed callback
      widget.onSell(sellAmount);

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid positive number')),
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
                    'Sell',
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
            controller: _sellController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter amount to sell",
              labelStyle: TextStyle(
                color: Colors.grey[700], // Default (unfocused) label color
              ),
              floatingLabelStyle: TextStyle(
                color: Color(0xFF416FDF), // Focused label color
                // fontWeight: FontWeight.w600,
              ),
              hintText: "e.g. 50",
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
              onPressed: isLoading ? null : restockItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                // backgroundColor: Colors.blue,
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
                      'SELL',
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
