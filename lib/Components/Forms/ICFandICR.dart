import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../../Providers/UserInfo.dart';
import '../../URL.dart';

class ICFandICR extends StatefulWidget {
  final String patientNumber;
  ICFandICR({super.key, required this.patientNumber});

  @override
  State<ICFandICR> createState() => _ICFandICRState();
}

class _ICFandICRState extends State<ICFandICR> {
  @override
  void initState() {
    super.initState();
    fetchCurrIcrAndIcf();
  }

  TextEditingController ICRController = TextEditingController();
  TextEditingController ICFController = TextEditingController();
  bool isloading = false;

  Future<void> fetchCurrIcrAndIcf() async {
    setState(() {
      isloading = true;
    });

    var number = widget.patientNumber;
    final String url = '${URL.baseUrl}/get_icr_icf/$number';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (response.statusCode == 200) {
      var icr = data["records"][0][0];
      var icf = data["records"][0][1];


      setState(() {
        ICRController.text = icr ?? '';
        ICFController.text = icf ?? '';
        isloading = false;
      });
    } else {
      print('Failed to fetch data. Error: ${response.statusCode}');
    }
  }

  // Function to save the blood sugar entry
  Future<void> saveICRICFEntry() async {
    if (ICFController.text.isEmpty ||
        double.tryParse(ICFController.text) == null ||
        double.parse(ICFController.text) < 0) {
      Toast.show(
        "Please enter a valid value",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
      return;
    }

    final data = {
      'phoneNumber': widget.patientNumber,
      'icf': ICFController.text,
      'icr': ICRController.text
    };

    final url = '${URL.baseUrl}/save_icr_icf';

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      Toast.show(
        "Record saved successfully",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
      // Handle success
    } else {
      print('Failed to save meal intake record');
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: isloading
              ? Center(
                  child: CircularProgressIndicator(
              color: Color(0xffF86851),
                ))
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Center(
                        child: Text(
                          'Change ICF and ICR',
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
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ICF",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: ICFController,
                                decoration: InputDecoration(
                                    labelText: 'Enter ICF',
                                    labelStyle: TextStyle(fontSize: 12)),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ICR",
                                style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextField(
                                controller: ICRController,
                                decoration: InputDecoration(
                                    labelText: 'Enter ICR',
                                    labelStyle: TextStyle(fontSize: 12)),
                                keyboardType: TextInputType.number,
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
                              await saveICRICFEntry();
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
}
