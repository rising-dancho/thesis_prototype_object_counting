import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/screens/otp/pages/otp_verify.dart';
import 'package:tectags/screens/otp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController(); // Use TextEditingController
  bool isApiCallProcess = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ProgressHUD(
          key: UniqueKey(),
          opacity: .3,
          inAsyncCall: isApiCallProcess,
          child: Form(key: globalKey, child: loginUI()),
        ),
      ),
    );
  }

  loginUI() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Email Verification'),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      endDrawer: const SideMenu(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              "https://cdn4.iconfinder.com/data/icons/inituh-communication-illustrate-set/128/Send_Message_Email_Communication_OTP-512.png",
              height: 180,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              "Login With Email",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "A one-time-password (OTP) will be sent to your email for verification",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            // Updated to use TextEditingController
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              validator: (val) {
                final emailRegex = RegExp(
                  r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@"
                  r"(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$",
                );

                if (val == null || val.isEmpty) {
                  return "Required";
                } else if (!emailRegex.hasMatch(val)) {
                  return "Invalid email";
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (validateAndSave()) {
                      setState(() {
                        isApiCallProcess = true;
                      });

                      String email = _emailController.text; // Get value from controller
                      debugPrint(email);

                      APIService.otpLogin(email).then(
                        (response) {
                          setState(() {
                            isApiCallProcess = false;
                          });

                          if (response.data != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OTPVerificationPage(
                                  otpHash: response.data,
                                  email: email,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 22, 165, 221),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.grey,
                    elevation: 5,
                    padding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
