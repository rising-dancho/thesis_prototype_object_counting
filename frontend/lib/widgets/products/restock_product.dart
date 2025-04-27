import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';

class RestockProduct extends StatefulWidget {
  final String itemName;
  final int restockAmount;
  final void Function(int newTotal) onRestock;

  const RestockProduct({
    super.key,
    required this.itemName,
    required this.restockAmount,
    required this.onRestock,
  });

  @override
  State<RestockProduct> createState() => _RestockProductState();
}

class _RestockProductState extends State<RestockProduct> {
  late TextEditingController _countController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _countController = TextEditingController(text: '10');
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  Future<void> restockItem() async {
    int? amountToAdd = int.tryParse(_countController.text.trim());
    if (amountToAdd == null || amountToAdd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid restock amount')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var result = await API.restockStock(widget.itemName, amountToAdd);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      debugPrint("✅ Restock Successful: ${result['message']}");
      int newTotal = widget.restockAmount + amountToAdd;

      widget.onRestock(newTotal);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Successfully restocked ${widget.itemName}!')),
      );
    } else {
      debugPrint("❌ Restock Failed");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Failed to restock. Try again.')),
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
              Text(
                "Restock ${widget.itemName}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Colors.grey[800],
                ),
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
          const SizedBox(height: 12),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Amount to Add",
              filled: true,
              fillColor: Colors.grey[200],
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : restockItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
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
          )
        ],
      ),
    );
  }
}
