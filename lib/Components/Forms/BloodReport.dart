import 'dart:convert';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';

import '../../URL.dart';

class BloodReportEntryBottomSheet extends StatefulWidget {
  @override
  _BloodReportEntryBottomSheetState createState() =>
      _BloodReportEntryBottomSheetState();
}

class _BloodReportEntryBottomSheetState extends State<BloodReportEntryBottomSheet> {

  // LDL (Low-Density Lipoprotein) Cholesterol
  // HDL (High-Density Lipoprotein) Cholesterol
  // Total Cholesterol
  // Triglycerides

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();

  // hemoglobin A1C
  TextEditingController hbController = TextEditingController();

  // Cholesterol
  TextEditingController choleLDLController = TextEditingController();
  TextEditingController choleHDLController = TextEditingController();
  TextEditingController choleTotalController = TextEditingController();
  TextEditingController choleTriController = TextEditingController();
  TextEditingController choleVLDLController = TextEditingController();
  TextEditingController choleNonHDLController = TextEditingController();

  // Thyroid Function
  TextEditingController tshController = TextEditingController();
  TextEditingController t3Controller = TextEditingController();
  TextEditingController t4Controller = TextEditingController();

  // TTG
  TextEditingController ttgController = TextEditingController();

  // urine microalbumin
  TextEditingController umaController = TextEditingController();

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    final format =
    DateFormat.jm(); // You can customize the time format here if needed.
    return format.format(dateTime);
  }

  double parseDouble(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      // Handle the case where the value cannot be parsed as a double
      return 0.0;  // Default value or any value you consider appropriate
    }
  }

  @override
  Widget build(BuildContext context) {

    ToastContext().init(context);

    return FractionallySizedBox(
      heightFactor: 0.85,
      widthFactor: 1.0,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Text(
                    'Blood Report',
                    style: GoogleFonts.inter(
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff6373CC),
                        fontSize: 24,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Hemoglobin A1c',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF86851),
                              fontSize: 18,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hemoglobin A1C",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: hbController,
                          decoration: InputDecoration(hintText: 'Enter your HbA1c (mmol/mol)'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Cholesterol Levels',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF86851),
                              fontSize: 18,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Cholesterol",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: choleTotalController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LDL (Low-Density Lipoprotein) Cholesterol",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: choleLDLController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "HDL (High-Density Lipoprotein) Cholesterol",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: choleHDLController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Triglycerides",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: choleTriController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Non-HDL Cholesterol",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: choleNonHDLController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "VLDL Cholesterol",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: choleVLDLController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Thyroid Function',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF86851),
                              fontSize: 18,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TSH (Thyroid Stimulating Hormone)",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: tshController,
                          decoration: InputDecoration(hintText: 'Enter your TSH (Thyroid Stimulating Hormone)'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Free T3",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: t3Controller,
                          decoration: InputDecoration(hintText: 'Enter your Free T3 (pg/mL)'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Free T4",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: t4Controller,
                          decoration: InputDecoration(hintText: 'Enter your Free T4 (ng/dL)'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Tissue Transglutaminase (TTG) antibodies',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF86851),
                              fontSize: 18,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "TTG Antibodies Test",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: ttgController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Center(
                        child: Text(
                          'Urine Microalbumin',
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xffF86851),
                              fontSize: 18,
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Urine Microalbumin",
                          style: GoogleFonts.inter(
                            textStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextField(
                          controller: umaController,
                          decoration: InputDecoration(hintText: 'Enter here'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    SizedBox(height: 30,),
                    ListTile(
                      title: Text('Date'),
                      subtitle:
                      Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
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
                          builder: (BuildContext context, Widget ?child) {
                            return MediaQuery(
                              data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != selectedTime)
                          setState(() {
                            selectedTime = picked;
                          });
                      },
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
                        await savebloodReport();
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
  Future<void> savebloodReport() async {

    // TO:DO Valid Validation of the data

    String dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    String timeStr = selectedTime.format(context);

    final data = {
      'selectedDate': dateStr,
      'selectedTime': timeStr,
      'hba1c': parseDouble(hbController.text),
      'cholesterol_ldl': parseDouble(choleLDLController.text),
      'cholesterol_hdl': parseDouble(choleHDLController.text),
      'cholesterol_total': parseDouble(choleTotalController.text),
      'cholesterol_triglycerides': parseDouble(choleTriController.text),
      'thyroid_tsh': parseDouble(tshController.text),
      'thyroid_t3': parseDouble(t3Controller.text),
      'thyroid_t4': parseDouble(t4Controller.text),
      'ttg': parseDouble(ttgController.text),
      'urine_microalbumin': parseDouble(umaController.text),
      'phoneNumber': context.read<UserProvider>().phoneNumber,
      'cholesterol_vldl' : parseDouble(choleVLDLController.text),
      'cholesterol_non_hdl' : parseDouble(choleNonHDLController.text)
    };


    final url = '${URL.baseUrl}/save_blood_reports';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      Toast.show(
        "Blood Report record saved successfully",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
      // Handle success
    } else {
      print('Failed to save blood report record');
      // Handle error
    }
  }
}
