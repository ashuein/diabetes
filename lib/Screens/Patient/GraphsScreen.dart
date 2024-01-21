import 'package:diabetes_ms/Components/Graphs/CarbGraphs.dart';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../Components/Graphs/BloodSugarGraph.dart';
import '../../Components/Graphs/InuslinGraph.dart';
import '../../Components/Log/BloodReportLogs.dart';
import '../../Components/Log/MealIntakeLog.dart';
import '../../Components/Log/PhysicalActivityLog.dart';
import '../../Components/RectangleButton.dart';
import 'cal.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back,color:Color(0xff6373CC),),
                        onPressed: () {
                          // Pop the current context to navigate back when the back icon is pressed.
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.2,
                      ),
                      Center(
                        child: Text(
                          "Toolkit",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: Color(0xff6373CC),
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/sugar.png'),
                            heading: 'Blood Sugar',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BloodSugarGraph(patientNumber: context.read<UserProvider>().phoneNumber ?? ""),
                                ),
                              );
                            },
                          ),
                          RoundedVerticalRectangle(
                            icon: Image.asset(
                              'assets/images/insulin.png',
                            ),
                            heading: 'Insulin Taken',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InsulinGraph(patientNumber: context.read<UserProvider>().phoneNumber ?? ""),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/meal.png'),
                            heading: 'Meal Intake',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CarbGraph(patientNumber: context.read<UserProvider>().phoneNumber ?? ""),
                                ),
                              );
                            },
                          ),
                          RoundedVerticalRectangle(
                            icon: Image.asset(
                                'assets/images/physical_activity.png'),
                            heading: 'Physical Activity',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PhysicalActivityLog(patientNumber: context.read<UserProvider>().phoneNumber ?? ""),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/blood.png'),
                            heading: 'Blood Report',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BloodReport(patientNumber: context.read<UserProvider>().phoneNumber ?? ""),
                                ),
                              );
                            },
                          ),
                          RoundedVerticalRectangle(
                            icon: Image.asset('assets/images/cal.png'),
                            heading: 'Insulin Calculator',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Cal(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
