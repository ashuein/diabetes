import 'package:flutter/material.dart';

class RoundedVerticalRectangle extends StatelessWidget {
  final Image icon;
  final String heading;
  final Function onTap;

  RoundedVerticalRectangle({required this.icon, required this.heading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.40,
          height: MediaQuery.of(context).size.width * 0.35,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: Color(0xffF86851), // Change the color as per your preference
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: Container(width: 65,
                  height: 65,child: icon)),
              FittedBox(
                child: Text(
                  heading,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
