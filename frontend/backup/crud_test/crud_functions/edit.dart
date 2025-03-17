import 'package:flutter/material.dart';
import '../crud.dart';
import '../model/product_model.dart';
import '../services/api.dart';

class EditScreen extends StatefulWidget {
  final Product data;
  const EditScreen({super.key, required this.data});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  var nameController = TextEditingController();
  var priceController = TextEditingController();
  var descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.data.name.toString();
    priceController.text = widget.data.price.toString();
    descController.text = widget.data.desc.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD test")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name.."),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(hintText: "Price.."),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: "Description.."),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  API.updateProduct(widget.data.id, {
                    "pname": nameController.text,
                    "pprice": priceController.text,
                    "pdesc": descController.text,
                    "id": widget.data.id,
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (e) => const Crud()),
                  );
                },
                child: const Text("Update Data"))
          ],
        ),
      ),
    );
  }
}
