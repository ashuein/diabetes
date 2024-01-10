import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import '../../Providers/UserInfo.dart';
import '../../URL.dart';

class BloodSugarEntryBottomSheet extends StatefulWidget {
  @override
  _BloodSugarEntryBottomSheetState createState() =>
      _BloodSugarEntryBottomSheetState();
}

class _BloodSugarEntryBottomSheetState extends State<BloodSugarEntryBottomSheet> {

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String mealType = 'Before'; // Assuming 'Before' is the default value
  TextEditingController bloodSugarController = TextEditingController();

  void _onMealSelected(String type) {
    setState(() {
      mealType = type;
    });
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format = DateFormat.jm(); // You can customize the time format here if needed.
    return format.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {

    ToastContext().init(context);

    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(5.0),
                child: Center(
                  child: Text(
                    'Blood Sugar Entry',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6373CC),
                        fontSize: 20,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Blood Sugar",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextField(
                      controller: bloodSugarController,
                      decoration: InputDecoration(labelText: 'Blood Sugar'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2022),
                    lastDate: DateTime(2025),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Time'),
                subtitle: Text(_formatTimeOfDay(selectedTime)),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (picked != null && picked != selectedTime)
                    setState(() {
                      selectedTime = picked;
                    });
                },
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Meal Type:'),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () => _onMealSelected("Before"),
                          child: const Text('Before'),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: mealType == "Before"
                                  ? Colors.white
                                  : const Color(0xff6373CC),
                              backgroundColor: mealType == "Before"
                                  ? const Color(0xffF86851)
                                  : const Color(0xffD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(75, 35)),
                        ),
                        ElevatedButton(
                          onPressed: () => _onMealSelected("After"),
                          child: const Text('After'),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: mealType == "After"
                                  ? Colors.white
                                  : const Color(0xff6373CC),
                              backgroundColor: mealType == "After"
                                  ? const Color(0xffF86851)
                                  : const Color(0xffD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(75, 35)),
                        ),
                        ElevatedButton(
                          onPressed: () => _onMealSelected("Low Sugar"),
                          style: ElevatedButton.styleFrom(
                              foregroundColor: mealType == "Low Sugar"
                                  ? Colors.white
                                  : const Color(0xff6373CC),
                              backgroundColor: mealType == "Low Sugar"
                                  ? const Color(0xffF86851)
                                  : const Color(0xffD9D9D9),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              minimumSize: const Size(75, 35)),
                          child: const Text('Low Sugar'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await saveBloodSugarEntry();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF86851),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 40)),
                      child: Text('Save'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffF86851),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(100, 40)),
                      child: Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateProgress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double updatedProgress = context.read<UserProvider>().log! + 1;
    context.read<UserProvider>().setLog(updatedProgress);
    await prefs.setDouble('userProgress', updatedProgress);
    await prefs.setString('lastDate', DateTime.now().toIso8601String());
  }


  // Function to save the blood sugar entry
  Future<void> saveBloodSugarEntry() async {

    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    String timeStr = selectedTime.format(context);

    if (bloodSugarController.text.isEmpty || double.tryParse(bloodSugarController.text) == null
    || double.parse(bloodSugarController.text) < 0){
      Toast.show(
        "Please enter a valid blood sugar value",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
      return;
    }

    final data = {
      'selectedDate': dateStr,
      'selectedTime': timeStr,
      'mealType': mealType,
      'bloodSugar': bloodSugarController.text,
      'phoneNumber': context.read<UserProvider>().phoneNumber
    };

    final url = '${URL.baseUrl}/save_blood_sugar';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      Toast.show(
        "Blood sugar record saved successfully",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
      // print('Blood sugar record saved successfully');
      _updateProgress();
      // Handle success
    } else {
      print('Failed to save blood sugar record');
      // Handle error
    }
  }
}
