import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snippet_coder_utils/ProgressHUD.dart';
import 'package:tectags/screens/login_screen.dart';
import 'package:tectags/screens/otp/pages/otp_verify.dart';
import 'package:tectags/screens/otp/services/api_service.dart';
import 'package:tectags/services/api.dart';
import 'package:tectags/services/shared_prefs_service.dart';
import 'package:tectags/utils/label_formatter.dart';
import 'package:tectags/utils/phone_number_formatter.dart';
import 'package:tectags/widgets/custom_scaffold.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // OTP
  bool isApiCallProcess = false;
  GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  final _formSignUpKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _middleInitialController =
      TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _middleInitialController.dispose();
    _lastNameController.dispose();
    _contactNumberController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ProgressHUD(
          key: UniqueKey(),
          opacity: .3,
          inAsyncCall: isApiCallProcess,
          child: Form(key: globalKey, child: registerUI()),
        ),
      ),
    );
  }

  registerUI() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/tectags_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        child: CustomScaffold(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formSignUpKey,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/images/tectags_logo_nobg.png',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Create your account',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: _emailController,
                      validator: (value) {
                        final emailRegex = RegExp(
                          r"^[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@"
                          r"(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?$",
                        );

                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!emailRegex.hasMatch(value)) {
                          return 'Invalid email address';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'First Name',
                        hintText: 'Enter your first name',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Middle Initial (Optional)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: _middleInitialController,
                      decoration: InputDecoration(
                        labelText: 'Middle Initial (Optional)',
                        hintText: 'Enter your middle initial',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Last Name',
                        hintText: 'Enter your last name',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: Colors.white,
                        filled: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  // Birthday and Phone number
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 5.0),
                            child: TextFormField(
                              controller: _birthdayController,
                              readOnly: true,
                              onTap: () async {
                                final today = DateTime.now();
                                final latestAllowedBirthday = DateTime(
                                  today.year - 18,
                                  today.month,
                                  today.day,
                                ); // precisely 18 years ago including month and day

                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime(2000),
                                  firstDate: DateTime(1900),
                                  lastDate: latestAllowedBirthday
                                      .subtract(const Duration(days: 1)),
                                  builder: (context, child) {
                                    return Theme(
                                      data: Theme.of(context).copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: Color(0xFF16A5DD),
                                          onPrimary: Colors.white,
                                          onSurface: Colors.black,
                                        ),
                                        textButtonTheme: TextButtonThemeData(
                                          style: TextButton.styleFrom(
                                            foregroundColor: Color(0xFF16A5DD),
                                          ),
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  setState(() {
                                    _birthdayController.text =
                                        DateFormat('MM/dd/yyyy')
                                            .format(pickedDate);
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Select birthday';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Birthday',
                                hintText: 'Select your birthday',
                                hintStyle:
                                    const TextStyle(color: Colors.black26),
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                suffixIcon: const Icon(Icons.calendar_today),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: TextFormField(
                              controller: _contactNumberController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                } else if (!RegExp(r'^09\d{9}$')
                                    .hasMatch(value)) {
                                  return 'Must start with 09 and be 11 digits';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter phone number',
                                hintStyle:
                                    const TextStyle(color: Colors.black26),
                                fillColor: Colors.white,
                                filled: true,
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_passwordVisible,
                          obscuringCharacter: '*',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a password';
                            } else if (value.length < 8) {
                              return 'Password must be at least 8 characters long';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            hintStyle: const TextStyle(color: Colors.black26),
                            fillColor: const Color.fromARGB(255, 255, 255, 255),
                            filled: true,
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Must be at least 8 characters',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(221, 255, 255, 255),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_confirmPasswordVisible,
                      obscuringCharacter: '*',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        hintStyle: const TextStyle(color: Colors.black26),
                        fillColor: const Color.fromARGB(255, 255, 255, 255),
                        filled: true,
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _confirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _confirmPasswordVisible =
                                  !_confirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formSignUpKey.currentState!.validate()) {
                            var data = {
                              "email": _emailController.text,
                              "password": _passwordController.text,
                              "firstName": LabelFormatter.titleCase(
                                  _firstNameController.text),
                              "lastName": LabelFormatter.titleCase(
                                  _lastNameController.text),
                              "contactNumber": PhoneNumberFormatter.format(
                                  _contactNumberController.text),
                              "birthday": _birthdayController.text,
                            };

                            Map<String, dynamic>? response;
                            try {
                              response = await API.registerUser(data);
                              debugPrint("API Response: $response");
                            } catch (e) {
                              debugPrint("Error during registration: $e");
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Registration failed. Please try again.')),
                              );
                              return;
                            }

                            if (response != null &&
                                response.containsKey('error') &&
                                response['error'] != null) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['error'])),
                              );
                              return;
                            }

                            if (response != null &&
                                response.containsKey('token')) {
                              await SharedPrefsService.saveTokenWithoutCheck(
                                  response['token']);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(response['message'] ??
                                        'Registration Successful!')),
                              );

                              _emailController.clear();
                              _passwordController.clear();
                              _firstNameController.clear();
                              _lastNameController.clear();

                              // OTP LOGIN after registration
                              String email = data["email"] as String;
                              setState(() {
                                isApiCallProcess = true;
                              });

                              try {
                                final otpResponse =
                                    await APIService.otpLogin(email);
                                setState(() {
                                  isApiCallProcess = false;
                                });

                                if (otpResponse.data != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => OTPVerificationPage(
                                        otpHash: otpResponse.data,
                                        email: email,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("OTP request failed.")),
                                  );
                                }
                              } catch (e) {
                                setState(() {
                                  isApiCallProcess = false;
                                });
                                debugPrint("OTP Error: $e");
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("OTP login failed.")),
                                );
                              }
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Registration failed. Token not received.')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 22, 165, 221),
                          foregroundColor: Colors.white,
                          shadowColor: Colors.grey,
                          elevation: 5,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          'Register',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (e) => const LoginScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Sign in',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 55, 247, 253),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
