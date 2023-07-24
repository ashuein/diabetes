import 'dart:convert';
import 'dart:io';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../../Components/CustomListTitle.dart';

class HomeScreenP extends StatefulWidget {
  const HomeScreenP({super.key});

  @override
  State<HomeScreenP> createState() => _HomeScreenPState();
}

class _HomeScreenPState extends State<HomeScreenP> {
  late String phoneNumber;
  late SharedPreferences prefs;
  String _profilePicturePath = '';

  @override
  void initState() {
    super.initState();
    OnBoaringCompleted();
  }

  Future<void> OnBoaringCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    _profilePicturePath = prefs.getString('profilePicturePath') ?? '';
    if (_profilePicturePath.isNotEmpty) {
      context.read<UserProvider>().setImageFile(File(_profilePicturePath));
      setState(() {});
    }
    phoneNumber = prefs.getString('phoneNumber') ?? "";
    fetchUserData(phoneNumber);
  }

  Future<void> fetchUserData(phoneNumber) async {
    final url = 'http://10.0.2.2:5000/get_users/$phoneNumber';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      context.read<UserProvider>().setName(data['name']);
      context.read<UserProvider>().setPhoneNumber(data['phoneNumber']);
      context.read<UserProvider>().setDateOfBirth(data['dateOfBirth']);
      context.read<UserProvider>().setCity(data['city']);
      context.read<UserProvider>().setGender(data['gender']);
      context.read<UserProvider>().setBloodGroup(data['bloodGroup']);
      context.read<UserProvider>().setFamilyHistory(data['familyHistory']);
      context.read<UserProvider>().setMedicalCondition(data['medicalCondition']);
      context.read<UserProvider>().setDoctorid(data['doctorid']);
      context.read<UserProvider>().setStatus(data['status']);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            String? firstName = userProvider.name;
                            if (firstName != null) {
                              List<String> nameParts = firstName.split(' ');
                              firstName = nameParts.first;
                            }

                            return Container(
                              padding: EdgeInsets.zero,
                              child: FittedBox(
                                alignment: Alignment.centerLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Welcome, ${userProvider.name} !",
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
                        const SizedBox(
                          height: 3,
                        ),
                        Text(
                          "Take charge of your health.",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontSize: 16,
                              color: Color(0xffF86851),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProfilePic(),
                          ),
                        );
                      },
                      child: Consumer<UserProvider>(
                        builder: (context, imageProvider, _) {
                          if (imageProvider.imageFile == null) {
                            return const CircleAvatar(
                              radius: 32,
                              backgroundImage: AssetImage(
                                  'assets/images/default_profile_pic.png'),
                            );
                          } else {
                            return CircleAvatar(
                                radius: 32,
                                backgroundImage:
                                    FileImage(imageProvider.imageFile!)
                                        as ImageProvider);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 45, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Progress",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          new CircularPercentIndicator(
                            radius: 60.0,
                            lineWidth: 10.0,
                            percent: 0.5,
                            center: new Text("50%"),
                            progressColor: Color(0xff6373CC),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Today's Progress",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "5 out of 7 Completed",
                                    style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffF86851)),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Ideal Insulin Intake",
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "40 units of insulin/day",
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff6373CC),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 45, left: 10, right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Track",
                        style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/sugar.png'),
                            heading: 'Blood Sugar',
                            subheading: 'Keep Track of Your Blood Sugar Readings',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: () => _showJohnDoeDialog(context),
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/insulin.png'),
                            heading: 'Insulin Taken',
                            subheading: 'Keep a Record of Your Insulin Intake',
                            trailingIcon: Icons.add_box_rounded,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/meal.png'),
                            heading: 'Meal Intake',
                            subheading: 'Keep Track of Your Daily Meal Intake',
                            trailingIcon: Icons.add_box_rounded,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/blood.png'),
                            heading: 'Blood Report',
                            subheading: 'Record Your Blood Test Results',
                            trailingIcon: Icons.add_box_rounded,
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


void _showJohnDoeDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('John Doe Dialog'),
        content: Text('This is a dialog for John Doe.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}