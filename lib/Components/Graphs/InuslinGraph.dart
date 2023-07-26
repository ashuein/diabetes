import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class InsulinGraph extends StatefulWidget {
  @override
  _InsulinGraphState createState() => _InsulinGraphState();
}

class _InsulinGraphState extends State<InsulinGraph> {
  List<Map<String, dynamic>> insulinData = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
    await http.get(Uri.parse('http://10.0.2.2:5000/insulin_records'));
    if (response.statusCode == 200) {
      setState(() {
        insulinData =
        List<Map<String, dynamic>>.from(json.decode(response.body));
        print(insulinData);
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insulin Graph'),
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16.0),
          child: insulinData.isNotEmpty
              ? buildInsulinGraph()
              : CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildInsulinGraph() {
    List<ChartData> chartData = [];
    for (var data in insulinData) {
      var insulin = double.parse(data['insulin']);
      var date = DateTime.parse(data['date']); // Assuming this contains the date portion in a valid format
      var timeString = data['time']; // Assuming this contains the time portion in the format "11:00:00"

      List<String> timeComponents = timeString.split(':');
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);
      int second = int.parse(timeComponents[2]);

      var combinedDateTime = DateTime(date.year, date.month, date.day, hour, minute, second);
      chartData.add(ChartData(combinedDateTime, insulin));
    }

    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        labelStyle: TextStyle(fontSize: 0),
        visibleMinimum: chartData.length >= 5 ? chartData.length - 5 : 0,
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        maximum: 250, // Set the max Y value as needed based on your blood sugar data
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableSelectionZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(
        enable: true,
      ),
      legend: Legend( // Add the Legend widget here
        isVisible: true,
        position: LegendPosition.bottom, // You can change the position as needed
      ),
      series: <LineSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.insulin,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
          ),
        ),
      ],
    );
  }
}

class ChartData {
  final DateTime dateTime;
  final double insulin;

  ChartData(this.dateTime, this.insulin);
}
