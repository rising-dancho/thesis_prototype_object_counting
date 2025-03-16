import 'package:flutter/material.dart';
import 'package:techtags/screens/crud_test/crud.dart';
import 'package:techtags/screens/crud_test/model/product_model.dart';
import 'package:techtags/screens/crud_test/services/api.dart';

class DeleteScreen extends StatefulWidget {
  const DeleteScreen({super.key});

  @override
  State<DeleteScreen> createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  void showSnackbar(BuildContext context, String text) {
    final snackBar = SnackBar(
      content: Text(text),
      duration: Duration(seconds: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete data"),
      ),
      body: FutureBuilder(
        future: API.getProduct(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            List<Product> pdata = snapshot.data;

            return ListView.builder(
                itemCount: pdata.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: Icon(Icons.storage),
                    title: Text("${pdata[index].name}"),
                    subtitle: Text("${pdata[index].desc}"),
                    trailing: IconButton(
                        onPressed: () async {
                          // DELETE product in the BACKEND
                          bool success =
                              await API.deleteProduct(pdata[index].id);

                          if (success) {
                            setState(() {
                              // DELETE product in the FRONTEND (only if API was successful)
                              pdata.removeAt(index);
                              debugPrint('Product deleted!');
                            });
                          } else {
                            debugPrint('Failed to delete product!');
                          }
                        },
                        icon: const Icon(Icons.delete)),
                  );
                });
          }
        },
      ),
    );
  }
}
