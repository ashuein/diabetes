import 'dart:convert';

import 'package:diabetes_ms/Screens/Patient/ChangeProfilePic.dart';
import 'package:diabetes_ms/Screens/OnBoarding/ProfilePic.dart';
import 'package:dropdown_model_list/drop_down/model.dart';
import 'package:dropdown_model_list/drop_down/select_drop_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Providers/UserInfo.dart';
import '../../URL.dart';
import 'ChangeHospital.dart';
import 'package:http/http.dart' as http;

import 'PrivacyPolicy.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {


  List<Map<String, dynamic>> hospitals = [];
  String hospital = "";
  bool isloading = false;
  late var jsonData;

  Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', false);
    UserProvider userProvider = UserProvider();
    userProvider.clearUserData();
  }

  void fetchUserTableData(option) async {

    setState(() {
      isloading = true;
    });

    var phoneNumber = context.read<UserProvider>().phoneNumber;
    var days = option;

    final response = await http.get(Uri.parse('${URL.baseUrl}/get_blood_sugar_table/$phoneNumber/$days'));

    if(response.statusCode == 200){
        jsonData = json.decode(response.body);

        setState(() {
          isloading = false;
        });

    } else{
      print('Failed to fetch data');
    }

  }

  List<Map<String, dynamic>> getMealTypeData (String mealType){
    return jsonData
        .where((record) => record['meal_type'].toLowerCase() == mealType.toLowerCase())
        .cast<Map<String, dynamic>>()
        .toList();
  }

  @override
  void initState()  {
    fetchHospitalData();
  }

  String selectedProfile = 'All';
  DropListModel dropListModel = DropListModel([
    OptionItem(id: "1", title: "All"),
    OptionItem(id: "2", title: "7 days"),
    OptionItem(id: "3", title: "30 days"),
  ]);
  OptionItem optionItemSelected = OptionItem(title: "All");

  // Fetch available hospital from the server
  void fetchHospitalData() async {

    fetchUserTableData(1);

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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    SizedBox(
                      width: 55,
                    ),
                    Center(
                      child: Text(
                        "My Profile",
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
                Container(
                  padding: EdgeInsets.all(45),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
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
                    ],
                  ),
                ),
                SizedBox(
                  height: 45,
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      child: FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          "Blood Sugar Report",
                          textAlign: TextAlign.left,
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              color: Color(0xff6373CC),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    SelectDropList(
                      paddingBottom: 0,
                      paddingTop: 0,
                      heightBottomContainer: 125,
                      itemSelected: optionItemSelected,
                      dropListModel: dropListModel,
                      showIcon: false,
                      showArrowIcon: true,
                      showBorder: true,
                      containerPadding: const EdgeInsets.all(10),
                      paddingDropItem: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                      suffixIcon: Icons.arrow_drop_down,
                      onOptionSelected: (optionItem) {
                        optionItemSelected = optionItem;
                        setState(() {
                          selectedProfile = optionItemSelected.title;
                          fetchUserTableData(optionItem.id);
                        });
                      },
                    ),
                  ],
                ),
                Container(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        buildTableWithData(jsonData),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 30,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyScreen(enableButton: false,),
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
                          'Privacy Policy',
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

  Widget buildTableWithData(List<dynamic> mealTypeData) {

    if (mealTypeData.isEmpty) {
      return Text('No data available.');
    }

    List<DataColumn> columns = [
      DataColumn(label: Text('Metric')),
    ];

    List<DataRow> rows = [];

    // Create columns dynamically based on meal types
    Set<String> mealTypes = Set<String>();

    mealTypes.add("before_breakfast");
    mealTypes.add("after_breakfast");
    mealTypes.add("before_lunch");
    mealTypes.add("after_lunch");
    mealTypes.add("before_dinner");
    mealTypes.add("after_dinner");
    mealTypes.add("other");

    columns.addAll(mealTypes.map((mealType) {

      var textLabel = '';

      if(mealType == 'before_breakfast'){
        textLabel = "Before Breakfast";
      } else if (mealType == 'after_breakfast'){
        textLabel = "After Breakfast";
      }  else if (mealType == 'before_lunch'){
        textLabel = "Before Lunch";
      }  else if (mealType == 'after_lunch'){
        textLabel = "After Lunch";
      } else if (mealType == 'before_dinner'){
        textLabel = "Before Dinner";
      }  else if (mealType == 'after_dinner'){
        textLabel = "After Dinner";
      } else{
        textLabel = "Other";
      }

      return DataColumn(label: Text(textLabel));
    }));

    // Create rows dynamically
    List<String> metrics = [
      'consistency_percentage',
      'avg_value',
      'max_value',
      'min_value',
      'std_value',
    ];

    metrics.forEach((metric) {

      var textLabel = "";

      if(metric == "consistency_percentage"){
        textLabel = "Consistency Percentage";
      } else if (metric == "avg_value"){
        textLabel = "Avg Value";
      }  else if (metric == "max_value"){
        textLabel = "Max";
      }  else if (metric == "min_value"){
        textLabel = "MIN";
      }  else if (metric == "std_value"){
        textLabel = "STD";
      }

      List<DataCell> cells = [DataCell(Text(textLabel))];

      mealTypes.forEach((mealType) {
        var dataForMealType = mealTypeData
            .where((record) => record['meal_type'] == mealType)
            .toList();

        var data = "0.0";

        if (dataForMealType.isNotEmpty) {
          if (dataForMealType[0][metric.toLowerCase()].runtimeType == String) {
            data = double.parse(dataForMealType[0][metric.toLowerCase()])
                .toStringAsFixed(2);
          } else {
            data = dataForMealType[0][metric.toLowerCase()].toStringAsFixed(2);
          }
        }

        cells.add(DataCell(Text('$data')));
      });

      rows.add(DataRow(cells: cells));
    });

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(columns: columns, rows: rows),
    );
  }

}
