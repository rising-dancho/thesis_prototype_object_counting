import 'package:flutter/material.dart';
import '../model/product_model.dart';
import '../services/api.dart';

class DeleteScreen extends StatefulWidget {
  const DeleteScreen({super.key});

  @override
  State<DeleteScreen> createState() => _DeleteScreenState();
}

class _DeleteScreenState extends State<DeleteScreen> {
  List<Product> pdata = []; // Store data in state
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchProducts(); // Fetch products when screen loads
  }

  Future<void> _fetchProducts() async {
    List<Product> products = await API.getProduct();
    setState(() {
      pdata = products;
      isLoading = false;
    });
  }

  void _deleteProduct(int index) async {
    bool success = await API.deleteProduct(pdata[index].id);

    if (success) {
      setState(() {
        pdata.removeAt(index); // This will trigger a rebuild
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product deleted!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Delete data"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pdata.isEmpty
              ? Center(child: Text("No products available"))
              : ListView.builder(
                  itemCount: pdata.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: Icon(Icons.storage),
                      title: Text("${pdata[index].name}"),
                      subtitle: Text("${pdata[index].desc}"),
                      trailing: IconButton(
                        onPressed: () => _deleteProduct(index),
                        icon: const Icon(Icons.delete),
                      ),
                    );
                  },
                ),
    );
  }
}
