import 'package:flutter/material.dart';
import 'package:techtags/screens/crud_test/crud_functions/create.dart';


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
                          // GO TO THE NAVIGATION MENU
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (e) => const CreateData()),
                          );
                        },
                        child: const Text("CREATE")),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: () {}, child: const Text("READ")),
                    const SizedBox(height: 10),
                    ElevatedButton(
                        onPressed: () {}, child: const Text("UPDATE")),
                    const SizedBox(height: 10),

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
