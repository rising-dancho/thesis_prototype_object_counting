import 'package:flutter/material.dart';
import 'package:tectags/services/api.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String token = ''; // 🔐 Your JWT token here

  Future<void> loadUsers() async {
    final result = await API.fetchUsers();
    if (result != null) {
      setState(() {
        users = result;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load users')),
      );
    }
  }

  void handleRoleUpdate(String userId, String newRole) async {
    final result = await API.updateUserRole(userId, newRole);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'])),
    );

    if (result['success']) {
      // Refresh user list or update UI
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                String selectedRole = user['role'];

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${user['firstName']} ${user['lastName']}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(user['email']),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: selectedRole,
                              items: ['employee', 'manager']
                                  .map((role) => DropdownMenuItem<String>(
                                        value: role,
                                        child: Text(role.toUpperCase()),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value!;
                                  users[index]['role'] = value;
                                });
                              },
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    handleRoleUpdate(user['_id'], selectedRole);
                                  },
                                  child: const Text('Update Role'),
                                ),
                                // IconButton(
                                //   icon: const Icon(Icons.delete,
                                //       color: Colors.red),
                                //   onPressed: () async {
                                //     final confirm = await showDialog<bool>(
                                //       context: context,
                                //       builder: (context) => AlertDialog(
                                //         title: const Text('Confirm Deletion'),
                                //         content: Text(
                                //             'Delete ${user['firstName']} ${user['lastName']}?'),
                                //         actions: [
                                //           TextButton(
                                //               onPressed: () =>
                                //                   Navigator.pop(context, false),
                                //               child: const Text('Cancel')),
                                //           TextButton(
                                //               onPressed: () =>
                                //                   Navigator.pop(context, true),
                                //               child: const Text('Delete')),
                                //         ],
                                //       ),
                                //     );

                                //     if (confirm == true) {
                                //       final result =
                                //           await API.deleteUser(user['_id']);
                                //       ScaffoldMessenger.of(context)
                                //           .showSnackBar(
                                //         SnackBar(
                                //             content: Text(result['message'])),
                                //       );
                                //       if (result['success']) {
                                //         loadUsers(); // Refresh list
                                //       }
                                //     }
                                //   },
                                // ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
