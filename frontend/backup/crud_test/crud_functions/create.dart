import 'package:flutter/material.dart';
import '../crud.dart';
import '../services/api.dart';

class CreateData extends StatefulWidget {
  const CreateData({super.key});

  @override
  State<CreateData> createState() => _CreateDataState();
}

class _CreateDataState extends State<CreateData> {
  var nameController = TextEditingController();
  var priceController = TextEditingController();
  var descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create")),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.green[300],
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Name here"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(hintText: "Price here"),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(hintText: "Description here"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  var data = {
                    "pname": nameController.text,
                    "pprice": priceController.text,
                    "pdesc": descController.text,
                  };

                  API.addProduct(data);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (e) => const Crud()),
                  );
                },
                child: const Text("Create Data"))
          ],
        ),
      ),
    );
  }
}
