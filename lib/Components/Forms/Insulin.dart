import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../Providers/UserInfo.dart';
import '../../URL.dart';

class InsulinEntryBottomSheet extends StatefulWidget {
  @override
  _InsulinEntryBottomSheetState createState() =>
      _InsulinEntryBottomSheetState();
}

class _InsulinEntryBottomSheetState extends State<InsulinEntryBottomSheet> {

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String mealType = 'Meal Bolus'; // Assuming 'Before' is the default value
  TextEditingController insulinController = TextEditingController();

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
                    'Insulin Taken',
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
                      "Insulin Taken",
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextField(
                      controller: insulinController,
                      decoration: InputDecoration(labelText: 'Enter your insulin'),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type:'),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () => _onMealSelected("Meal Bolus"),
                            child: const Text('Meal Bolus',textAlign: TextAlign.center,),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: mealType == "Meal Bolus"
                                    ? Colors.white
                                    : const Color(0xff6373CC),
                                backgroundColor: mealType == "Meal Bolus"
                                    ? const Color(0xffF86851)
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(100, 40)),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () => _onMealSelected("Basal Insulin"),
                            child: const Text('Basal Insulin',textAlign: TextAlign.center,),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: mealType == "Basal Insulin"
                                    ? Colors.white
                                    : const Color(0xff6373CC),
                                backgroundColor: mealType == "Basal Insulin"
                                    ? const Color(0xffF86851)
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(100, 40)),
                          ),
                        ),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () => _onMealSelected("Correction Dose"),
                            style: ElevatedButton.styleFrom(
                                foregroundColor: mealType == "Correction Dose"
                                    ? Colors.white
                                    : const Color(0xff6373CC),
                                backgroundColor: mealType == "Correction Dose"
                                    ? const Color(0xffF86851)
                                    : const Color(0xffD9D9D9),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                minimumSize: const Size(100, 40)),
                            child: const Text('Correction Dose',textAlign: TextAlign.center,),
                          ),
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
                        await saveInsulinEntry();
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

  // Function to save the blood sugar entry
  Future<void> saveInsulinEntry() async {

    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    String timeStr = selectedTime.format(context);

    if (insulinController.text.isEmpty || double.tryParse(insulinController.text) == null
        || double.parse(insulinController.text) < 0){
      Toast.show(
        "Please enter a valid insulin value",
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
      'insulin': insulinController.text,
      'phoneNumber': context.read<UserProvider>().phoneNumber
    };

    final url = '${URL.baseUrl}/save_insulin';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    // Handle success
    if (response.statusCode == 201) {
      Toast.show(
        "Insulin record saved successfully",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
      // print('Insulin record saved successfully');
    } else {
      print('Failed to save insulin record');
      // Handle error
    }
  }
}
