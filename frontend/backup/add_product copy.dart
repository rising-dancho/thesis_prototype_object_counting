// import 'package:flutter/material.dart';
// import 'package:tectags/utils/label_formatter.dart';

// class AddProduct extends StatefulWidget {
//   final Map<String, Map<String, int>> stockCounts;
//   final void Function(String name, int count) onAddStock;
//   final String? initialName;
//   final int? initialCount;

//   const AddProduct({
//     super.key,
//     required this.stockCounts,
//     required this.onAddStock,
//     this.initialName,
//     this.initialCount,
//   });

//   @override
//   State<AddProduct> createState() => _AddProductState();
// }

// class _AddProductState extends State<AddProduct> {
//   TextEditingController nameController = TextEditingController();
//   TextEditingController countController = TextEditingController();
//   TextEditingController priceController = TextEditingController();
//   // form validation
//   final _formKey = GlobalKey<FormState>();

//   @override
//   void initState() {
//     super.initState();
//     nameController = TextEditingController(text: widget.initialName ?? '');
//     countController =
//         TextEditingController(text: widget.initialCount?.toString() ?? '');
//   }

//   void addStockItem() {
//     String rawItemName = nameController.text.trim();
//     String itemName = LabelFormatter.titleCase(rawItemName);
//     int? itemCount = int.tryParse(countController.text.trim());

//     if (itemName.isNotEmpty && itemCount != null) {
//       widget.onAddStock(itemName, itemCount); // Notify parent
//       nameController.clear();
//       countController.clear();
//       Navigator.pop(context); // Dismiss modal after adding
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       padding: EdgeInsets.only(
//         left: 20,
//         right: 20,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 20,
//         top: 20,
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Add Stock",
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 28,
//                     color: Colors.grey[800],
//                   ),
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300], // background color
//                     borderRadius: BorderRadius.circular(8), // rounded corners
//                   ),
//                   child: IconButton(
//                     icon: Icon(Icons.close),
//                     color: Colors.grey[700], // icon color
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 22),
//             TextFormField(
//               controller: nameController,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Required: Please enter the stock name';
//                 }
//                 return null;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Name',
//                 labelStyle: TextStyle(
//                   color: Colors.grey[700], // default color
//                 ),
//                 floatingLabelStyle: TextStyle(
//                   color:
//                       Color(0xFF416FDF), // 👈 color when the field is focused
//                 ),
//                 hintText: 'Please enter the stock name',
//                 hintStyle: const TextStyle(color: Colors.black26),
//                 fillColor: Colors.grey[200],
//                 filled: true,
//                 border: InputBorder.none,
//                 // prefixIcon: Icon(Icons.new_label),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextFormField(
//               controller: countController,
//               keyboardType: TextInputType.number,
//               validator: (value) {
//                 if (value == null || value.isEmpty) {
//                   return 'Required: Please enter the total stock count';
//                 }
//                 return null;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Total Count',
//                 labelStyle: TextStyle(
//                   color: Colors.grey[700], // default color
//                 ),
//                 floatingLabelStyle: TextStyle(
//                   color:
//                       Color(0xFF416FDF), // 👈 color when the field is focused
//                 ),
//                 hintText: 'Please enter the total stock count',
//                 hintStyle: const TextStyle(color: Colors.black26),
//                 fillColor: Colors.grey[200],
//                 filled: true,
//                 border: InputBorder.none,
//                 // prefixIcon: Icon(Icons.numbers),
//               ),
//             ),
//             const SizedBox(height: 10),
//             TextFormField(
//               controller: priceController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               validator: (value) {
//                 return null;
//               },
//               decoration: InputDecoration(
//                 labelText: 'Price',
//                 labelStyle: TextStyle(
//                   color: Colors.grey[700], // default color
//                 ),
//                 floatingLabelStyle: TextStyle(
//                   color:
//                       Color(0xFF416FDF), // 👈 color when the field is focused
//                 ),
//                 hintText: 'Please enter the stock price',
//                 hintStyle: const TextStyle(color: Colors.black26),
//                 fillColor: Colors.grey[200],
//                 filled: true,
//                 border: InputBorder.none,
//                 // prefixIcon: Icon(Icons.payments),
//               ),
//             ),
//             const SizedBox(height: 10),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color.fromARGB(255, 22, 165, 221),
//                   foregroundColor: Colors.white,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 100, vertical: 15),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     addStockItem();
//                   }
//                 },
//                 child: const Text(
//                   'SAVE',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: 15.0,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }