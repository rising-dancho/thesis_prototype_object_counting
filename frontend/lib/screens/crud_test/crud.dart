import 'package:flutter/material.dart';

class Crud extends StatefulWidget {
  const Crud({super.key});

  @override
  State<Crud> createState() => _CrudState();
}

class _CrudState extends State<Crud> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("CRUD test")),
      body: Container(
        padding: EdgeInsets.all(16),
        color: Colors.green[300],
        width: double.infinity,
        height: double.infinity,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    ElevatedButton(
                        onPressed: () {}, child: const Text("CREATE")),
                    ElevatedButton(
                        onPressed: () {}, child: const Text("READ")),
                    ElevatedButton(
                        onPressed: () {}, child: const Text("UPDATE")),
                    ElevatedButton(
                        onPressed: () {}, child: const Text("DELETE")),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
