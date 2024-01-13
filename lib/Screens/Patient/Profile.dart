import 'dart:convert';

import 'package:diabetes_ms/Screens/Patient/ChangeProfilePic.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/UserInfo.dart';
import '../../URL.dart';
import 'ChangeHospital.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, dynamic>> hospitals = [];
  String hospital = "";
  bool isloading = false;

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', false);
    UserProvider userProvider = UserProvider();
    userProvider.clearUserData();
  }

  @override
  void initState() {
    fetchHospitalData();
  }

  // Fetch available hospital from the server
  void fetchHospitalData() async {

    setState(() {
      isloading = true;
    });

    final response = await http.get(Uri.parse('${URL.baseUrl}/get_hospital'));
    if (response.statusCode == 200) {
      var id = context.read<UserProvider>().hospitalid;

      setState(() {
        final jsonData = json.decode(response.body);
        hospitals = List<Map<String, dynamic>>.from(jsonData['hospital']);

        var hospitalData =
            hospitals.firstWhere((hospital) => hospital['hospital_id'] == id);
        hospital = hospitalData['hospital_name'];

          isloading = false;

      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading ? Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(
            color: Color(0xffF86851),
          ),
        ),
      ),
    ) : Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Color(0xff6373CC),
                        size: 30,
                      ),
                      onPressed: () {
                        // Pop the current context to navigate back when the back icon is pressed.
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "My Profile",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: Color(0xff6373CC),
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    return Container(
                      padding: EdgeInsets.zero,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "${userProvider.name}",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff6373CC),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Consumer<UserProvider>(
                  builder: (context, userProvider, _) {
                    Color textColor;
                    String statusText;
                    // Determine the text color and status text based on user's status
                    switch (userProvider.status) {
                      case 0:
                        textColor = Colors.yellow; // Pending - Yellow color
                        statusText = "Pending";
                        break;
                      case 1:
                        textColor = Colors.green; // Approved - Green color
                        statusText = "Approved";
                        break;
                      case 2:
                        textColor = Colors.red; // Rejected - Red color
                        statusText = "Rejected";
                        break;
                      default:
                        textColor = Colors.yellow; // Default color
                        statusText = "Pending";
                    }

                    return Container(
                      padding: EdgeInsets.zero,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            Text(
                              "Status: ",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              statusText,
                              textAlign: TextAlign.left,
                              style: GoogleFonts.inter(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                Container(
                  padding: EdgeInsets.zero,
                  child: FittedBox(
                    alignment: Alignment.centerLeft,
                    fit: BoxFit.scaleDown,
                    child: Row(
                      children: [
                        Text(
                          "Hospital: ",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          hospital,
                          softWrap: true,
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF86851),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeYourDoctor(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6373CC),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Your Hospital',
                          style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                            fontSize: 16,
                          )),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: () {
                    logOut();
                    SystemNavigator.pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff6373CC),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: Size(MediaQuery.of(context).size.width, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Log Out',
                          style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                            fontSize: 16,
                          )),
                        ),
                        Icon(Icons.arrow_forward_ios),
                      ],
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
