import 'package:flutter/material.dart';
import 'crud_functions/create.dart';
import 'crud_functions/delete.dart';
import 'crud_functions/get.dart';
import 'crud_functions/update.dart';

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          // GO TO CREATE SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (e) => const CreateData()),
                          );
                        },
                        child: const Text("CREATE")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          // GO TO CREATE SCREEN
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (e) => const FetchData()),
                          );
                        },
                        child: const Text("READ")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (e) => const UpdateScreen()),
                          );
                        },
                        child: const Text("UPDATE")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (e) => const DeleteScreen()),
                          );
                        },
                        child: const Text("DELETE")),
                  ],
                ),
              ),
            ]),
      ),
    );
  }
}
