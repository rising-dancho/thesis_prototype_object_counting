// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tectags/screens/navigation/side_menu.dart';
// import 'dart:io';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   _ProfileScreenState createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   final Map<String, TextEditingController> _controllers = {
//     'Full Name': TextEditingController(),
//     'Email': TextEditingController(),
//     'Phone': TextEditingController(),
//     'Password': TextEditingController(),
//   };

//   File? _profileImage;

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? image = await picker.pickImage(source: ImageSource.gallery);

//     if (image != null) {
//       setState(() {
//         _profileImage = File(image.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         title: const Text('My Profile'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         foregroundColor: Colors.white,
//       ),
//       endDrawer: const SideMenu(),
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/tectags_bg.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           Container(color: Colors.black.withOpacity(0.5)),
//           Center(
//             child: SingleChildScrollView(
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
//                 child: Container(
//                   padding: const EdgeInsets.all(24),
//                   decoration: BoxDecoration(
//                     gradient: const LinearGradient(
//                       colors: [
//                         Color(0xFF42A5F5),
//                         Color(0xFF478DE0),
//                         Color(0xFF5C6BC0),
//                       ],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.3),
//                         blurRadius: 15,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Stack(
//                         alignment: Alignment.bottomRight,
//                         children: [
//                           CircleAvatar(
//                             radius: 60,
//                             backgroundImage: _profileImage != null
//                                 ? FileImage(_profileImage!)
//                                 : const AssetImage('assets/profile_picture.png')
//                                     as ImageProvider,
//                           ),
//                           GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: Colors.white,
//                                 border: Border.all(
//                                     color: Colors.blueAccent, width: 2),
//                               ),
//                               child: const Icon(Icons.edit,
//                                   color: Colors.blueAccent, size: 20),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         "Edit Your Profile",
//                         style: TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 25),
//                       _buildTextField(label: 'Full Name', icon: Icons.person),
//                       _buildTextField(label: 'Email', icon: Icons.email),
//                       _buildTextField(label: 'Phone', icon: Icons.phone),
//                       _buildTextField(
//                           label: 'Password',
//                           icon: Icons.lock,
//                           obscureText: true),
//                       const SizedBox(height: 30),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                                 const Color.fromARGB(255, 22, 165, 221),
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 6,
//                           ),
//                           onPressed: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(
//                                   content: Text('Changes saved successfully!')),
//                             );
//                           },
//                           child: const Text(
//                             'Save Changes',
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.w600),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: TextFormField(
//         controller: _controllers[label],
//         obscureText: obscureText,
//         style: const TextStyle(color: Colors.black87),
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Color(0xFF1565C0)),
//           labelText: label,
//           labelStyle: const TextStyle(color: Colors.black54),
//           filled: true,
//           fillColor: Colors.white,
//           contentPadding:
//               const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
//           border: InputBorder.none,
//         ),
//       ),
//     );
//   }
// }
