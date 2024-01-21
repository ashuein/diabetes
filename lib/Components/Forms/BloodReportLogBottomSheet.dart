import 'dart:convert';
import 'package:diabetes_ms/Providers/UserInfo.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BloodReportLogBottomSheet extends StatelessWidget {

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

  BloodReportLogBottomSheet({
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
  });

  // hemoglobin A1C
  TextEditingController hbController = TextEditingController();

  // Cholesterol
  TextEditingController choleLDLController = TextEditingController();
  TextEditingController choleHDLController = TextEditingController();
  TextEditingController choleTotalController = TextEditingController();
  TextEditingController choleTriController = TextEditingController();

  // Thyroid Function
  TextEditingController tshController = TextEditingController();
  TextEditingController t3Controller = TextEditingController();
  TextEditingController t4Controller = TextEditingController();

  // TTG
  TextEditingController ttgController = TextEditingController();

  // urine microalbumin
  TextEditingController umaController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    hbController.text = hba1c.toString();
    choleLDLController.text = ldl.toString();
    choleHDLController.text = hdl.toString();
    choleTotalController.text = totalChole.toString();
    choleTriController.text = triglyChole.toString();
    tshController.text = tsh.toString();
    t3Controller.text = t3.toString();
    t4Controller.text = t4.toString();
    ttgController.text = ttg.toString();
    umaController.text = urine.toString();

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
                          decoration: InputDecoration(hintText: 'Enter your Cholesterol (mg/dL)'),
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
                          decoration: InputDecoration(hintText: 'Enter your Cholesterol (mg/dL)'),
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
                          decoration: InputDecoration(hintText: 'Enter your Cholesterol (mg/dL)'),
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
                          decoration: InputDecoration(hintText: 'Enter your Cholesterol (mg/dL)'),
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

