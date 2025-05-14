import 'package:flutter/material.dart';

class RestockProduct extends StatefulWidget {
  final String itemName;
  final int initialAmount;
  final void Function(int restockAmount) onRestock;

  const RestockProduct({
    super.key,
    required this.itemName,
    required this.initialAmount,
    required this.onRestock,
  });

  @override
  State<RestockProduct> createState() => _RestockProductState();
}

class _RestockProductState extends State<RestockProduct> {
  late TextEditingController _restockController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _restockController = TextEditingController(
      text: widget.initialAmount > 0 ? widget.initialAmount.toString() : '',
    );
  }

  @override
  void dispose() {
    _restockController.dispose();
    super.dispose();
  }

  void restockItem() {
    int? restockAmount = int.tryParse(_restockController.text.trim());
    if (restockAmount != null && restockAmount > 0) {
      setState(() {
        isLoading = true;
      });
      widget.onRestock(restockAmount);
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
                    'Restock',
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
            controller: _restockController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Enter restock amount",
              labelStyle: TextStyle(
                color: Colors.grey[700], // Default (unfocused) label color
              ),
              floatingLabelStyle: TextStyle(
                color: Color(0xFF416FDF), // Focused label color
                // fontWeight: FontWeight.w600,
              ),
              hintText: "e.g. 100",
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
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : restockItem,
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
              child: isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'RESTOCK',
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
