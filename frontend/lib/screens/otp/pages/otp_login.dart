import 'package:tectags/screens/navigation/side_menu.dart';
import 'package:tectags/screens/otp/pages/otp_verify.dart';
import 'package:tectags/screens/otp/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String email = "";
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
            FormHelper.inputFieldWidget(
              context,
              "email",
              "",
              (String? onValidateVal) {
                final val = onValidateVal ?? '';
                final emailRegex = RegExp(
                  r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@"
                  r"(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$",
                );

                if (val.isEmpty) {
                  return "Required";
                } else if (!emailRegex.hasMatch(val)) {
                  return "Invalid email";
                }
                return null;
              },
              (onSaved) {
                email = onSaved;
              },
              borderRadius: 10,
              borderColor: Colors.grey,
            ),
            SizedBox(height: 10),
            FormHelper.submitButton("Continue", () {
              if (validateAndSave()) {
                setState(() {
                  isApiCallProcess = true;
                });

                debugPrint(email);
                APIService.otpLogin(email).then(
                  (response) => {
                    setState(() {
                      isApiCallProcess = false;
                    }),
                    if (response.data != null)
                      {
                        // OTP verification page
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPVerificationPage(
                              otpHash: response.data,
                              email: email,
                            ),
                          ),
                          (route) => false,
                        ),
                      },
                  },
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
