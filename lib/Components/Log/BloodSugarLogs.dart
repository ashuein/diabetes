import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:intl/intl.dart';

class BloodSugarLog extends StatelessWidget {
  Future<List<BloodSugarEntry>> fetchBloodSugarData() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/blood_sugar_records'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((entry) {
        return BloodSugarEntry(
          bloodSugar: entry['blood_sugar'],
          date: DateTime.parse(entry['date']),
          mealType: entry['meal_type'],
          time: DateFormat('HH:mm:ss').parse(entry['time']),
        );
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Blood Sugar Tracker'),
        ),
        body: FutureBuilder<List<BloodSugarEntry>>(
          future: fetchBloodSugarData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching data'));
            } else {
              final bloodSugarData = snapshot.data!;
              // Sort the data by date
              bloodSugarData.sort((a, b) => a.date.compareTo(b.date));

              // Group the data by date
              Map<String, List<BloodSugarEntry>> groupedData = {};
              bloodSugarData.forEach((entry) {
                String key = DateFormat('yyyy-MM-dd').format(entry.date);
                groupedData.putIfAbsent(key, () => []);
                groupedData[key]?.add(entry);
              });

              return ListView.builder(
                itemCount: groupedData.length,
                itemBuilder: (context, index) {
                  String key = groupedData.keys.elementAt(index);
                  List<BloodSugarEntry> entries = groupedData[key]!;
                  return ListTile(
                    title: Text('Date: $key'),
                    subtitle: Column(
                      children: entries.map((entry) {
                        String formattedTime = DateFormat('HH:mm:ss').format(entry.time);
                        return Text(
                          'Time: $formattedTime, Blood Sugar: ${entry.bloodSugar}, Meal Type: ${entry.mealType}',
                        );
                      }).toList(),
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



class BloodSugarEntry {
  final double bloodSugar;
  final DateTime date;
  final String mealType;
  final DateTime time;

  BloodSugarEntry({
    required this.bloodSugar,
    required this.date,
    required this.mealType,
    required this.time,
  });
}