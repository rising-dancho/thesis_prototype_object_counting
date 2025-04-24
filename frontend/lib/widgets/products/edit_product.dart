import 'package:flutter/material.dart';

class EditStockModal extends StatefulWidget {
  final String itemName;
  final int currentStock;
  final void Function(int newCount) onUpdate;

  const EditStockModal({
    super.key,
    required this.itemName,
    required this.currentStock,
    required this.onUpdate,
  });

  @override
  State<EditStockModal> createState() => _EditStockModalState();
}

class _EditStockModalState extends State<EditStockModal> {
  late TextEditingController _countController;

  @override
  void initState() {
    super.initState();
    _countController =
        TextEditingController(text: widget.currentStock.toString());
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void updateStockItem() {
    int? newCount = int.tryParse(_countController.text.trim());
    if (newCount != null) {
      widget.onUpdate(newCount);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                "Edit ${widget.itemName} Stock",
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
          const SizedBox(height: 12),
          TextField(
            controller: _countController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "New Stock Count",
              filled: true,
              fillColor: Colors.grey[200],
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: updateStockItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'UPDATE',
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
