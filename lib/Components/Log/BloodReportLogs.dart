import 'dart:io';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../URL.dart';
import '../Forms/BloodReportLogBottomSheet.dart';

class BloodReport extends StatefulWidget {

  final String patientNumber; // Using the "?" makes it optional
  BloodReport({required this.patientNumber});

  @override
  State<BloodReport> createState() => _BloodReportState();
}

class _BloodReportState extends State<BloodReport> {


  Future<List<ReportEntry>> fetchReportData(phoneNumber) async {
    final response = await http.get(Uri.parse('${URL.baseUrl}/blood_reports/$phoneNumber'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((entry) {
        return ReportEntry(
          hba1c: entry['hba1c'] ?? 0,
          ldl: entry['ldl'] ?? 0,
          hdl: entry['hdl'] ?? 0,
          totalChole: entry['totalChole'] ?? 0,
          triglyChole: entry['triglyChole'] ?? 0,
          tsh: entry['tsh'] ?? 0,
          t3: entry['t3'] ?? 0,
          t4: entry['t4'] ?? 0,
          ttg: entry['ttg'] ?? 0,
          urine: entry['uma'] ?? 0,
          date: DateTime.parse(entry['date']),
          time: DateFormat('HH:mm:ss').parse(entry['time']),
          non_hdl: entry['non_hdl'] ?? 0,
          vldl: entry['vldl'] ?? 0,
        );
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  void openBloodReportEntryDialog(totalChole,hba1c,hdl,ldl,t3,t4,triglyChole,tsh,ttg,urine,vldl,nonhdl) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
      ),
      builder: (BuildContext context) {
        return BloodReportLogBottomSheet(totalChole: totalChole,hba1c: hba1c,hdl: hdl,ldl: ldl,t3: t3,t4: t4,triglyChole: triglyChole,tsh: tsh,ttg: ttg,urine: urine,vldl: vldl,non_hdl: nonhdl,);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color:Color(0xffF86851)),
        title: Text('Blood Reports Logs',style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xffF86851),
          ),
        ),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<ReportEntry>>(
          future: fetchReportData(widget.patientNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              print(snapshot);
              return Center(child: Text('Error fetching data'));
            } else {
              final ReportData = snapshot.data!;
              // Sort the data by date
              ReportData.sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                itemCount: ReportData.length,
                itemBuilder: (context, index) {

                  var data = ReportData[index];
                  String date = DateFormat('yyyy-MM-dd').format(data.date);
                  String time = DateFormat('HH:mm').format(data.time);

                  return ListTile(
                    onTap: (){
                      openBloodReportEntryDialog(data.totalChole,data.hba1c,data.hdl,data.ldl,data.t3,data.t4,data.triglyChole,data.tsh,data.ttg,data.urine,data.vldl,data.non_hdl);
                    },
                    title: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.0),
                        color: Color(0xffF2F2F2),
                        border:Border.all(
                        color: Color(0xff6373CC), // Set the desired border color here
                        width: 2.0, // Set the desired border width here
                      ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(date,style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff6373CC),
                                  ),
                                ),),
                                Text(time,style: GoogleFonts.inter(
                                  textStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xffF86851),
                                  ),
                                ),),
                              ],
                            ),
                            Icon( Icons.arrow_forward_ios_outlined,color: Color(0xff6373CC) ,),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}



class ReportEntry {
  final double hba1c;
  final double totalChole;
  final double ldl;
  final double hdl;
  final double triglyChole;
  final double tsh;
  final double t3;
  final double t4;
  final double ttg;
  final double urine;
  final double non_hdl;
  final double vldl;
  final DateTime date;
  final DateTime time;

  ReportEntry({
    required this.totalChole,
    required this.ldl,
    required this.hdl,
    required this.triglyChole,
    required this.tsh,
    required this.t3,
    required this.t4,
    required this.ttg,
    required this.urine,
    required this.hba1c,
    required this.date,
    required this.time,
    required this.vldl,
    required this.non_hdl
  });
}