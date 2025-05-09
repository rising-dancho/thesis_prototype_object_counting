import 'package:flutter/material.dart';
import 'package:tectags/utils/label_formatter.dart';

class AddProduct extends StatefulWidget {
  final String? initialName;
  final int? itemCount;
  final Map<String, Map<String, int>> stockCounts;
  final void Function(String name, int count) onAddStock;

  const AddProduct({
    super.key,
    this.initialName,
    this.itemCount,
    required this.stockCounts,
    required this.onAddStock,
  });

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController itemController = TextEditingController();
  TextEditingController countController = TextEditingController();
  // TextEditingController priceController = TextEditingController();
  // form validation
  final _formKey = GlobalKey<FormState>();

  // FOR DROP DOWN
  final List<String> allItems = [
    'Bistay Sand',
    'Cement',
    'Gravel',
    'Hollow Blocks',
    'Nails',
    'Rebar',
    'Skim Coat',
  ];
  // FOR DROP DOWN
  String? selectedItem;
  // For DropDown, filter out items already in stock
  late List<String> availableItems;

  // Method to filter items not yet in stock

  void filterAvailableItems() {
    // Get the keys (names) of the items already in stock
    final stockedItems = widget.stockCounts.keys.toList();
    // Filter the original items list to exclude stocked items
    availableItems =
        allItems.where((item) => !stockedItems.contains(item)).toList();
  }

  void addStockItem() {
    String? rawItemName = selectedItem; // 👈 now using selectedItem
    if (rawItemName == null) {
      // Handle if nothing selected
      return;
    }
    String itemName = LabelFormatter.titleCase(rawItemName);
    int? itemCount = int.tryParse(countController.text.trim());

    if (itemName.isNotEmpty && itemCount != null) {
      widget.onAddStock(itemName, itemCount);
      // Clear fields after adding
      selectedItem = null; // Clear selected item
      countController.clear();
      Navigator.pop(context);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize the selected product with the initial name
    selectedItem = widget.initialName ?? selectedItem;
    // Initialize the count with the itemCount passed in
    countController = TextEditingController(
      text: widget.itemCount != null ? widget.itemCount.toString() : '',
    );
    // Filter available items whenever the widget is built or stock is updated
    filterAvailableItems();
  }

  @override
  void dispose() {
    itemController.dispose();
    countController.dispose();
    super.dispose();
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
                  "Add Stock",
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
            // TextFormField(
            //   controller: itemController,
            //   validator: (value) {
            //     if (value == null || value.isEmpty) {
            //       return 'Please enter the stock name';
            //     }
            //     return null;
            //   },
            //   decoration: InputDecoration(
            //     labelText: 'Stock Name',
            //     labelStyle: TextStyle(
            //       color: Colors.grey[700], // default color
            //     ),
            //     floatingLabelStyle: TextStyle(
            //       color:
            //           Color(0xFF416FDF), // 👈 color when the field is focused
            //     ),
            //     hintText: 'Please enter the stock name',
            //     hintStyle: const TextStyle(color: Colors.black26),
            //     fillColor: Colors.grey[200],
            //     filled: true,
            //     border: InputBorder.none,
            //     // prefixIcon: Icon(Icons.new_label),
            //   ),
            // ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButtonFormField<String>(
                value: selectedItem,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[700], // 👈 Arrow color to match textfields
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                hint: Text(
                  'Select an item',
                  style: TextStyle(
                      color: Colors.grey[700], fontWeight: FontWeight.w600),
                ),
                items: availableItems.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item,
                        style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedItem = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an item';
                  }
                  return null;
                },
                dropdownColor:
                    Colors.grey[100], // Optional: Dropdown popup background
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
                  color:
                      Color(0xFF416FDF), // 👈 color when the field is focused
                ),
                hintText: 'Please enter the total stock count',
                hintStyle: const TextStyle(color: Colors.black26),
                fillColor: Colors.grey[200],
                filled: true,
                border: InputBorder.none,
                // prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 10),
            // TextFormField(
            //   controller: priceController,
            //   keyboardType: TextInputType.numberWithOptions(decimal: true),
            //   validator: (value) {
            //     return null;
            //   },
            //   decoration: InputDecoration(
            //     labelText: 'Stock Price',
            //     labelStyle: TextStyle(
            //       color: Colors.grey[700], // default color
            //     ),
            //     floatingLabelStyle: TextStyle(
            //       color:
            //           Color(0xFF416FDF), // 👈 color when the field is focused
            //     ),
            //     hintText: 'Please enter the stock price',
            //     hintStyle: const TextStyle(color: Colors.black26),
            //     fillColor: Colors.grey[200],
            //     filled: true,
            //     border: InputBorder.none,
            //     // prefixIcon: Icon(Icons.payments),
            //   ),
            // ),
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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addStockItem();
                  }
                },
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
      ),
    );
  }
}
