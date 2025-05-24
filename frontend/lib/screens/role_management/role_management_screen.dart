import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/services/shared_prefs_service.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String token = ''; // 🔐 Your JWT token here
  String loggedInUserId = ''; // Store logged-in user ID

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
      loadUsers(); // Refresh user list after update
    }
  }

  @override
  void initState() {
    super.initState();
    loadUsers();
    _loadLoggedInUserId();
  }

  Future<void> _loadLoggedInUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('userId') ?? '';

    setState(() {
      loggedInUserId = id;
    });
  }

  void handleUserDelete(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[800])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red[400])),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final token = await SharedPrefsService.getToken();

    final result = await API.deleteUser(userId, token!);
    if (result['success'] == true) {
      loadUsers();
    } else {
      final errorMessage = result['message'] ?? 'Error deleting user';
      if (errorMessage.contains('Invalid or expired token')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Session expired. Please log in again.')),
        );
        // Optional: Redirect to login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    }
    if (result['success']) {
      loadUsers(); // Refresh user list
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title:
            // const Text('User Management'),
            const Text(
          "User Management",
          style: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 22,
            letterSpacing: 1.2,
            fontWeight: FontWeight.bold,
            // color: Color.fromARGB(255, 27, 211, 224),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: true,
      ),
      endDrawer: const SideMenu(),
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/tectags_bg.png', // Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          // Background dim layer
          Container(
            color: Colors.black.withOpacity(0.6),
          ),
          // Main content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    String selectedRole = user['role'];

                    bool isSelf = (user['_id'] == loggedInUserId);
                    debugPrint('USER ID IS IT RIGHT?? ${user['_id']}');
                    bool isDemotingSelf = isSelf && selectedRole != 'manager';

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
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (!isSelf)
                                      SizedBox(
                                        height:
                                            62, // Match height with the ElevatedButton
                                        width:
                                            62, // Make it square for consistency
                                        child: Card(
                                          color: Colors.white70,
                                          elevation: 2,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            icon: const Icon(Icons.delete,
                                                size: 20),
                                            color: Colors.black54,
                                            tooltip: 'Delete User',
                                            onPressed: () =>
                                                handleUserDelete(user['_id']),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      height:
                                          55, // Match height with delete button
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                              255, 22, 165, 221),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: isDemotingSelf
                                            ? null
                                            : () {
                                                handleRoleUpdate(
                                                    user['_id'], selectedRole);
                                              },
                                        child: const Text('Update Role'),
                                      ),
                                    ),
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
        ],
      ),
    );
  }
}
