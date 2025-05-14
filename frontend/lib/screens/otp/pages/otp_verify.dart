import 'package:flutter/material.dart';
import 'package:tectags/screens/login_screen.dart';
// import 'package:tectags/screens/navigation/navigation_menu.dart';
import 'package:tectags/screens/otp/services/api_service.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

class OTPVerificationPage extends StatefulWidget {
  final String? email;
  final String? otpHash;
  const OTPVerificationPage({super.key, this.email, this.otpHash});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

extension EmailValidator on String {
  bool isValidEmail() {
    return RegExp(
      r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@"
      r"(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?",
    ).hasMatch(this);
  }
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  String otpCode = "";
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
          child: Form(key: globalKey, child: loginVerificatiobUI()),
        ),
      ),
    );
  }

  loginVerificatiobUI() {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Pops back to the previous screen
          },
        ),
      ),
      // endDrawer: const SideMenu(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              "https://socialapps.tech/sites/default/files/nodeicon/plugins_email-verification-plugin.png",
              height: 180,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 10),
            Text(
              "Verification Code",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              "Enter the verification code that you received on your email.",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 200,
              child: FormHelper.inputFieldWidget(
                context,
                "code",
                "",
                (onValidateVal) {
                  String val = onValidateVal ?? '';
                  if (val.isEmpty) {
                    return "Required";
                  }
                },
                (onSaved) {
                  otpCode = onSaved;
                },
                borderRadius: 10,
                borderColor: Colors.grey,
                maxLength: 4,
                isNumeric: true,
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal, // Button background color
                foregroundColor: Colors.white, // Text color
                side: BorderSide(
                    color: Colors.blue, width: 2.0), // Outline border
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0), // Rounded corners
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12), // Optional
              ),
              onPressed: () {
                if (validateAndSave()) {
                  setState(() {
                    isApiCallProcess = true;
                  });

                  debugPrint(otpCode);
                  APIService.verifyOTP(widget.email!, otpCode, widget.otpHash!)
                      .then((response) {
                    setState(() {
                      isApiCallProcess = false;
                    });

                    print(
                        "Sending OTP Verification with Email: ${widget.email}, OTP Code: $otpCode, OTP Hash: ${widget.otpHash}");

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Email Verification"),
                        content: Text(response.message),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: Text("Ok"),
                          ),
                        ],
                      ),
                    );
                  }).catchError((error) {
                    setState(() {
                      isApiCallProcess = false;
                    });

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text("Error"),
                        content: Text("Something went wrong: $error"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Ok"),
                          ),
                        ],
                      ),
                    );
                  });
                }
              },
              child: Text("Continue"),
            ),
            SizedBox(height: 10),
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     backgroundColor: Colors.teal, // Button background color
            //     foregroundColor: Colors.white, // Text color
            //     side: BorderSide(
            //         color: Colors.blue, width: 2.0), // Outline border
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(8.0), // Rounded corners
            //     ),
            //     padding: EdgeInsets.symmetric(
            //         horizontal: 24, vertical: 12), // Optional
            //   ),
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => WelcomeScreen()),
            //     );
            //   },
            //   child: Text("Cancel"),
            // ),
          ],
        ),
      ),
    );
  }
}
