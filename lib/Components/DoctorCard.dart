import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorCard extends StatelessWidget {
  final String name;
  final int id;
  final String city;
  final VoidCallback onTap;

  DoctorCard({
    required this.name,
    required this.id,
    required this.city,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(color: Color(0xff6373CC), width: 2.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ListTile(
            onTap: onTap,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Hospital Id : ${id.toString()}",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xff6373CC),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2, // Set max lines to avoid overflow
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.0),
                Text(
                  "Hospital Name : $name",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      color: Color(0xffF86851),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 2, // Set max lines to avoid overflow
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.0),
                Text(
                  "City : $city",
                  style: GoogleFonts.inter(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  maxLines: 1, // Set max lines to avoid overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
