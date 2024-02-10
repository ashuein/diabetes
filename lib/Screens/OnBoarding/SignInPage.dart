import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diabetes_ms/Screens/OnBoarding/Verification.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/UserInfo.dart';
import '../../URL.dart';
import 'UserForm.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {

  final _formKey = GlobalKey<FormState>();
  late String mobile_number;
  bool alreadyP = false;
  bool isDoctor = false;
  bool isloading = false;

  // Check if the mobile number belongs to a doctor
  Future<void> checkDoctor(mobileNumber) async {
    final url = '${URL.baseUrl}/check_number';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"number": mobileNumber});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      final data = json.decode(response.body);

      setState(() async {
        isDoctor = data['exists'];
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDoctor',isDoctor);
      });
    } catch (error) {
      // Handle error
    }
  }

  // Check if the user is logging in for the first time
  Future<void> checkFirstTime(mobileNumber) async {
    final url = '${URL.baseUrl}/check_number_first_time';
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({"number": mobileNumber});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      final data = json.decode(response.body);

      setState(() async {
        alreadyP = data['exists'];
      });
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: isloading ? Container(
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color:Color(0xffF86851),
                  ),
                ],
              ),
            ),
          ) : Container(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/Otp_send.png',
                  width: width * 0.8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: FittedBox(
                    child: Text(
                      "Hi There!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                              color: Color(0xff6373CC),
                              fontWeight: FontWeight.bold,
                              fontSize: 32),),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "To start working with the app.we need to verify your phone number.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        color: Color(0xffF86851),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Your Mobile Number',
                              hintStyle: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: const Color(0xff6A696E).withOpacity(0.5)),
                              border: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xffF86851),
                                ),
                                borderRadius:
                                    BorderRadius.circular(10.0), // Border radius
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your mobile number';
                              }

                              if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                                return 'Please enter a valid numeric mobile number';
                              }

                              if(value.length != 10){
                                return 'Please enter a valid mobile number';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              mobile_number = value!;
                            },
                          ),
                          const SizedBox(
                            height: 60,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState != null &&
                                  _formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                setState(() {
                                  isloading = true;
                                });
                                await checkFirstTime(mobile_number);
                                await checkDoctor(mobile_number);

                                context.read<UserProvider>().setPhoneNumber(mobile_number);
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('phoneNumber',mobile_number);

                                setState(() {
                                  isloading  = false;
                                });

                                if(alreadyP == true || isDoctor == true){
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Verification(
                                        mobileNumber: mobile_number,
                                      ),
                                    ),
                                  );
                                } else{
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserForm(),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff6373CC),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              minimumSize:
                                  Size(MediaQuery.of(context).size.width, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                            child: Text(
                              'Next',
                              style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                fontSize: 16,
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
