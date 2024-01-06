import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:diabetes_ms/Components/Forms/BloodReport.dart';
import 'package:diabetes_ms/Components/Forms/Insulin.dart';
import 'package:diabetes_ms/Components/Forms/MealInTake.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:diabetes_ms/Screens/Patient/Profile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../Components/CustomListTitle.dart';
import '../../Components/Forms/Activity.dart';
import '../../Components/Forms/BloodGlucose.dart';
import '../../Components/SummarySection.dart';
import '../../URL.dart';
import 'ChangeProfilePic.dart';
import 'GraphsScreen.dart';
import 'cal.dart';

class HomeScreenP extends StatefulWidget {
  const HomeScreenP({super.key});

  @override
  State<HomeScreenP> createState() => _HomeScreenPState();
}

class _HomeScreenPState extends State<HomeScreenP> {

  late String phoneNumber;
  late SharedPreferences prefs;
  String _profilePicturePath = '';
  double _progress = 0;
  late DateTime _lastDate;

  double insulinAverage = 0;
  double carbsAverage = 0;
  String recent_activity = "No recent activity";

  final TextEditingController bloodSugarController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  String mealType = '';

  @override
  void initState() {
    super.initState();
    OnBoaringCompleted();
    _loadProgress();
  }

  // Function to mark onboarding as completed
  Future<void> OnBoaringCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
    phoneNumber = prefs.getString('phoneNumber') ?? "";
    fetchUserData(phoneNumber);
    fetchInfoToday();
  }


  // Convert base64 string to File
  File base64ToFile(String base64String) {
    Uint8List bytes = base64Decode(base64String);
    String tempPath = Directory.systemTemp.path;
    String fileName = 'profile_picture.png'; // Provide a suitable file name here
    File file = File('$tempPath/$fileName');
    file.writeAsBytesSync(bytes);
    return file;
  }

  // Fetch user data from the server
  Future<void> fetchUserData(phoneNumber) async {

    // Make a GET request to fetch user data
    // Set Provider values based on fetched data
    final url = '${URL.baseUrl}/get_users/$phoneNumber';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      // print(data);
      context.read<UserProvider>().setName(data['name']);
      context.read<UserProvider>().setPhoneNumber(data['phoneNumber']);
      context.read<UserProvider>().setDateOfBirth(data['dateOfBirth']);
      context.read<UserProvider>().setCity(data['city']);
      context.read<UserProvider>().setGender(data['gender']);
      context.read<UserProvider>().setBloodGroup(data['bloodGroup']);
      context.read<UserProvider>().setFamilyHistory(data['familyHistory']);
      context.read<UserProvider>().setMedicalCondition(data['medicalCondition']);
      context.read<UserProvider>().setHospitalid(data['hospital_id']);
      context.read<UserProvider>().setStatus(int.parse(data['status']));
      // File profilePicFile = base64ToFile(data['profilepic']);
      // context.read<UserProvider>().setImageFile(profilePicFile);
    } catch (error) {
      print(error);
    }
  }

  // Open various entry dialogs
  void openBloodSugarEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodSugarEntryBottomSheet();
      },
    );
  }


  void openInsulinEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return InsulinEntryBottomSheet(callbackToUpdateInfo:fetchInfoToday);
      },
    );
  }

  void openMealIntakeEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return MealIntakeEntryBottomSheet(callbackToUpdateInfo:fetchInfoToday);
      },
    );
  }

  void openActivityEntryDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return ActivityEntryBottomSheet(callbackToUpdateInfo: fetchInfoToday);
      },
    );
  }

  void openBloodReportEntryDialog() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodReportEntryBottomSheet();
      },
    );
  }

  // Load user progress from shared preferences
  Future<void> _loadProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double currentProgress = prefs.getDouble('userProgress') ?? 0;
    context.read<UserProvider>().setLog(currentProgress);
    DateTime? lastDate = DateTime.tryParse(prefs.getString('lastDate') ?? '');
    DateTime today = DateTime.now();

    if (lastDate == null || lastDate.day != today.day) {
      context.read<UserProvider>().setLog(0);
      currentProgress = 0;
    }

    setState(() {
      _lastDate = today;
    });
  }

  // Update user progress and store in shared preferences
  Future<void> _updateProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double updatedProgress = _progress + 1;
    context.read<UserProvider>().setLog(updatedProgress);
    await prefs.setDouble('userProgress', updatedProgress);
    await prefs.setString('lastDate', DateTime.now().toIso8601String());

    setState(() {
      _progress = updatedProgress;
    });
  }


  // main screen, show cab intake, physical activity and insulin taken
  Future<void> fetchInfoToday() async {

    DateTime currentDate = DateTime.now().toLocal();
    String formattedDate = currentDate.toLocal().toString().split(' ')[0];

    final String url = '${URL.baseUrl}/process_data/$phoneNumber/$formattedDate';
    // print(url);

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      // Process the data received from the server

      List<dynamic>insulinRecords = data["insulin_records"];
      List<dynamic> carbsRecords = data["meal_records"];

      if (data["activity_records"] != null && data["activity_records"].isNotEmpty) {
        recent_activity = data["activity_records"][0][0].toString();
      }

      double sum = 0.0;
      for(int i = 0 ; i < insulinRecords.length ; i++){
          sum += insulinRecords[i][0];
      }
      insulinAverage = sum / insulinRecords.length;

      sum = 0.0;
      int diff = 0;
      for(int i = 0 ; i < carbsRecords.length ; i++){
        if(carbsRecords[i][0] == 0){
          diff++;
        }
        sum += carbsRecords[i][0];
      }

      carbsAverage = sum / (carbsRecords.length - diff);

      if (carbsRecords.isEmpty) {
        carbsAverage = 0.0;
      }

      if (insulinRecords.isEmpty) {
        insulinAverage =  0.0;
      }

      setState(() { });

      // print(insulinAverage);
      // print(carbsAverage);
      // print(recent_activity);

      // print('Data from server: ${response.body}');
    } else {
      print('Failed to fetch data. Error: ${response.statusCode}');
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
                                      fontSize: 24,
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
                            builder: (context) => ProfilePage(),
                          ),
                        );
                      },
                      child: Icon(Icons.settings,size: 30,)
                    ),
                  ],
                ),
                const SizedBox(
                  height: 3,
                ),
              Card(
                elevation: 3.0,
                margin: EdgeInsets.only(top: 25.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
                ),
                child: Padding(
                  padding: EdgeInsets.all(18.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 3,),
                      Text(
                        "Today's Summary",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                          textStyle: TextStyle(
                            fontSize: 20,
                            color: Color(0xff6373CC),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 18.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SummarySection(
                            label: "Average Insulin",
                            value: insulinAverage.toString(),
                          ),
                          SizedBox(width: 16.0,),
                          SummarySection(
                            label: "Average Carbs Intake",
                            value: carbsAverage.toString(),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.0),
                      SummarySection2(
                        label: "Recent Activity",
                        value: recent_activity,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(top: 35, left: 10, right: 10),
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
                            onTap: openBloodSugarEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/insulin.png'),
                            heading: 'Insulin Taken',
                            subheading: 'Keep a Record of Your Insulin Intake',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openInsulinEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/meal.png'),
                            heading: 'Meal Intake',
                            subheading: 'Keep Track of Your Daily Meal Intake',
                            trailingIcon: Icons.add_box_rounded,
                            onTap:openMealIntakeEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/physical_activity.png'),
                            heading: 'Physical Activity',
                            subheading: 'Record Your physical activity',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openActivityEntryDialog,
                          ),
                          CustomListTile(
                            leadingIcon: Image.asset('assets/images/blood.png'),
                            heading: 'Blood Report',
                            subheading: 'Record Your Blood Test Results',
                            trailingIcon: Icons.add_box_rounded,
                            onTap: openBloodReportEntryDialog,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor:Color(0xff6373CC),
        onPressed: () {
          // Navigate to another page when the floating button is pressed.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GraphScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(Icons.stacked_bar_chart_sharp),
              Text('Stats',style: TextStyle(fontSize: 12),),
            ],
          ),
        ),
      ),
    );
  }
}



