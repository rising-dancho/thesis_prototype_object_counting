import 'package:flutter/material.dart';
import 'edit.dart';
import '../model/product_model.dart';
import '../services/api.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update data"),
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
                        onPressed: () {
                          debugPrint(
                              "EDITING THIS PRODUCT: ${pdata[index].toString()}"); // Debug
                          // GO TO EDIT SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (e) => EditScreen(
                                      data: pdata[index],
                                    )),
                          );
                        },
                        icon: const Icon(Icons.edit)),
                  );
                });
          }
        },
      ),
    );
  }
}
