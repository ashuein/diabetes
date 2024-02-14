import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummarySection extends StatelessWidget {
  final String label;
  final String value;

  SummarySection({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 8.0),
        Container(
          width: 75.0, // Adjust the size of the circular container
          height: 75.0,
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xffF86851), // Adjust the color as needed
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Center(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold// Adjust the text color as needed
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}

class SummarySection2 extends StatelessWidget {
  final String label;
  final String value;

  SummarySection2({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            textStyle: TextStyle(
              fontSize: 16,
              color: Color(0xff6373CC),
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        SizedBox(height: 8.0),
        Text(
          value,
          style: TextStyle(fontSize: 14.0),
        ),
        SizedBox(height: 16.0),
      ],
    );
  }
}