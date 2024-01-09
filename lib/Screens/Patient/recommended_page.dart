import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendedPage extends StatefulWidget {
  final double carbohydrateCount;
  final double icr;
  final bool isActivityYes;
  final String activityIntensity;
  final double currentSugarLevel;
  final double targetSugarLevel;
  final double isf;
  final double totalInsulinDose;
  final double elapsedTime;
  final double insulinDuration;

  RecommendedPage({
    required this.carbohydrateCount,
    required this.icr,
    required this.isActivityYes,
    required this.activityIntensity,
    required this.currentSugarLevel,
    required this.targetSugarLevel,
    required this.isf,
    required this.totalInsulinDose,
    required this.elapsedTime,
    required this.insulinDuration,
  });

  @override
  State<RecommendedPage> createState() => _RecommendedPageState();
}

class _RecommendedPageState extends State<RecommendedPage> {
  @override
  Widget build(BuildContext context) {
    double doseForMeal = widget.carbohydrateCount / widget.icr;
    double activityPercentage = 0.0;
    double recommendedInsulin = 0;

    if (widget.isActivityYes) {
      if (widget.activityIntensity == 'Light') {
        activityPercentage = 0.10;
      } else if (widget.activityIntensity == 'Medium') {
        activityPercentage = 0.20;
      } else if (widget.activityIntensity == 'Heavy') {
        activityPercentage = 0.30;
      }
    }

    double activityDose = doseForMeal * activityPercentage;
    double correctionDose = (widget.currentSugarLevel - widget.targetSugarLevel) / widget.isf;
    double insulinOnBoard = widget.totalInsulinDose * (1 - widget.elapsedTime / widget.insulinDuration);
    double bolusDose = doseForMeal + correctionDose - activityDose - insulinOnBoard;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Results',
          style: TextStyle(
            color: Color(0xFF6373CC),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Color(0xFF6373CC),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Formula We Are Using',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Bolus Dose = Dose for the Meal (ICR) +/- Correction for High/Low Sugar (ISF)- Activity Adjustment (10-30% Depending on Level and Duration of Activity - Insulin on Board (Active Insulin)',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dose for the Meal = Carbohydrate Count / ICR',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Correction for High/Low Sugar = (Current Sugar Level - Target Sugar Level) / ISF',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Insulin on Board (Active Insulin) = Total Insulin Dose from Previous Bolus(es) * (1 - Elapsed Time / Insulin Duration)',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Activity Adjustment = 10% of Dose for the Meal (Light Activity), 20% of Dose for the Meal (Medium Activity), 30% of Dose for the Meal (Heavy Activity)',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Calculations',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dose for the Meal = ${widget.carbohydrateCount} / ${widget.icr} = ${doseForMeal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              if (widget.isActivityYes)
                Text(
                  'Activity Dose = ${doseForMeal.toStringAsFixed(2)} * $activityPercentage = ${activityDose.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              Text(
                'Correction Dose = (${widget.currentSugarLevel} - ${widget.targetSugarLevel}) / ${widget.isf} = ${correctionDose.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                'Insulin on Board = ${widget.totalInsulinDose} * (1 - ${widget.elapsedTime} / ${widget.insulinDuration}) = ${insulinOnBoard.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                'Bolus Dose = ${doseForMeal.toStringAsFixed(2)} + ${correctionDose.toStringAsFixed(2)} - ${activityDose.toStringAsFixed(2)} - ${insulinOnBoard.toStringAsFixed(2)} = ${bolusDose.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Insulin Calculation Results',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Dose for the Meal = ${doseForMeal.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              if (widget.isActivityYes)
                Text(
                  'Activity Dose = ${activityDose.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              Text(
                'Correction Dose = ${correctionDose.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                'Insulin on Board = ${insulinOnBoard.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Text(
                'Bolus Dose = ${bolusDose.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Recommended Insulin:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 10),
              Text(
                '$bolusDose',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
