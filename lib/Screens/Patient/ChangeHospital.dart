import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:diabetes_ms/Screens/Patient/HomeScreenP.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Components/DoctorCard.dart';
import '../../URL.dart';

class ChangeYourDoctor extends StatefulWidget {
  @override
  _ChangeYourDoctorState createState() => _ChangeYourDoctorState();
}

class _ChangeYourDoctorState extends State<ChangeYourDoctor> {
  List<Map<String, dynamic>> hospitals = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch doctor data when the widget is created
  }

  // Edit the selected doctor for the current user
  void EditDoctor() async {
    // Get user's phone number and doctor's email from context
    var phoneNumber = context.read<UserProvider>().phoneNumber;
    var id = context.read<UserProvider>().hospitalid;

    final data = {
      "phoneNumber": phoneNumber,
      "hospitalid": id,
    };

    // Send a POST request to edit the doctor for the user
    final response = await http.post(
      Uri.parse('${URL.baseUrl}/edit_hospital'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    if (response.statusCode == 200) {
      print("Edit Successfully");
    } else {
      print('Failed to edit.');
    }
  }

  // Fetch available hospital from the server
  void fetchData() async {
    final response = await http.get(Uri.parse('${URL.baseUrl}/get_hospital'));
    if (response.statusCode == 200) {
      setState(() {
        final jsonData = json.decode(response.body);
        hospitals = List<Map<String, dynamic>>.from(jsonData['hospital']);
      });
    } else {
      print('Failed to fetch data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return hospitals.isEmpty ? Scaffold(
      body: Center(
        child: Container(
          child: CircularProgressIndicator(
            color: Color(0xffF86851),
          ),
        ),
      ),
    ) : Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(
            children: [
              Text(
                "Select Your Hospital",
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                      color: Color(0xff6373CC),
                      fontWeight: FontWeight.bold,
                      fontSize: 32),
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    child: ListView.builder(
                      itemCount: hospitals.length,
                      itemBuilder: (context, index) {
                        final hospital = hospitals[index];
                        return DoctorCard(
                          id: hospital['hospital_id'],
                          name: hospital['hospital_name'],
                          city: hospital['city'],
                          onTap: () {
                            // Set the selected doctor's email in the provider
                            context.read<UserProvider>().setHospitalid(hospital['hospital_id']);
                            // Edit the doctor for the user
                            EditDoctor();
                            // Navigate to the patient's home screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomeScreenP(),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}