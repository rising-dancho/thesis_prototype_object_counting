import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../services/api.dart';

class FetchData extends StatelessWidget {
  const FetchData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD")),
      body: FutureBuilder(
        future: API.getProduct(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text("No products found"));
          }

          List<Product> pdata = snapshot.data;
          return ListView.builder(
            itemCount: pdata.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                leading: Icon(Icons.storage),
                title: Text(pdata[index].name ?? "No Name"),
                subtitle: Text(pdata[index].desc ?? "No Description"),
                trailing: Text("₱ ${pdata[index].price}"),
              );
            },
          );
        },
      ),
    );
  }
}
