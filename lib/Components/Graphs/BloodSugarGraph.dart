import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../ColorBlockDialog.dart';
import '../Log/BloodSugarLogs.dart';
import 'package:dropdown_model_list/dropdown_model_list.dart';

class BloodSugarGraph extends StatefulWidget {

  final String patientNumber; // Using the "?" makes it optional
  BloodSugarGraph({required this.patientNumber});

  @override
  _BloodSugarGraphState createState() => _BloodSugarGraphState();
}

class _BloodSugarGraphState extends State<BloodSugarGraph> {

  String selectedProfile = 'Today';
  List<Map<String, dynamic>> bloodSugarData = [];

  DropListModel dropListModel = DropListModel([
    OptionItem(id: "1", title: "Today"),
    OptionItem(id: "2", title: "Daily"),
    OptionItem(id: "3", title: "Weekly"),
    OptionItem(id: "4", title: "Fortnightly"),
    OptionItem(id: "5", title: "3 Month Profile"),
  ]);
  OptionItem optionItemSelected = OptionItem(title: "Today");

  @override
  void initState() {
    super.initState();
    fetchData(widget.patientNumber);
  }

  Future<void> fetchData(phoneNumber) async {
    final response = await http.get(
        Uri.parse('http://10.0.2.2:5000/blood_sugar_records/$phoneNumber'));
    if (response.statusCode == 200) {
      setState(() {
        bloodSugarData =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        print(bloodSugarData);
      });
    } else {
      print('Failed to load data: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff6373CC)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Blood Sugar Statistics",
              style: GoogleFonts.inter(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff6373CC),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.info_outlined),
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ColorBlocksDialog();
                },
              ),
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SelectDropList(
            itemSelected: optionItemSelected,
            dropListModel: dropListModel,
            showIcon: false,
            showArrowIcon: true,
            showBorder: true,
            paddingTop: 0,
            paddingDropItem: const EdgeInsets.only(
                left: 20, top: 10, bottom: 10, right: 20),
            suffixIcon: Icons.arrow_drop_down,
            containerPadding: const EdgeInsets.all(10),
            icon: const Icon(Icons.person, color: Colors.black),
            onOptionSelected: (optionItem) {
              optionItemSelected = optionItem;
              setState(() {
                selectedProfile = optionItemSelected.title;
              });
            },
          ),
          Expanded(
            child: Center(
              child: Container(
                child: () {
                  if (bloodSugarData.isNotEmpty) {
                    if (selectedProfile == 'Today') {
                      return buildTodayBloodSugarGraph();
                    } else if (selectedProfile == 'Daily') {
                      return buildDailyBloodSugarGraph();
                    } else if (selectedProfile == 'Weekly') {
                      return buildWeeklyBloodSugarGraph();
                    } else {
                      // You can add other cases as needed
                      return const Text('Not implemented yet');
                    }
                  } else {
                    return const CircularProgressIndicator();
                  }
                }(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xff6373CC),
        onPressed: () {
          // Show the dialog box with three blocks of colors and text
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BloodSugarLog(patientNumber: widget.patientNumber,),
            ),
          );
        },
        child: const Icon(Icons.book),
      ),
    );
  }

  Widget buildTodayBloodSugarGraph() {
    List<ChartData> chartData = [];
    DateTime today = DateTime.now();

    for (var data in bloodSugarData) {
      var bloodSugar = data['blood_sugar'];
      var date = DateTime.parse(data['date']);

      // Check if the data entry is from today
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        var timeString = data['time'];
        var meal_time = data['meal_type'];

        List<String> timeComponents = timeString.split(':');
        int hour = int.parse(timeComponents[0]);
        int minute = int.parse(timeComponents[1]);

        var combinedDateTime = DateTime(date.year, date.month, date.day, hour, minute);
        chartData.add(ChartData(combinedDateTime, bloodSugar, meal_time));
      }
    }

    chartData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return SfCartesianChart(
      plotAreaBorderColor: const Color(0xffF2F2F2),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Time', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Blood Sugar', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
        labelFormat: '{value} mg/dl',
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableSelectionZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          name: 'Blood Sugar Level',
          color: Color(0xffF86851),
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.bloodSugar,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
            builder: (dynamic data, dynamic point, dynamic series,
                int dataIndex, int pointIndex) {
              if (data is ChartData) {
                // Format the date as "dd/MM/yyyy"
                var dateFormatter = DateFormat('dd/MM/yyyy');
                String formattedDate = dateFormatter.format(data.dateTime);

                // Format the time as "HH:mm"
                var timeFormatter = DateFormat('hh:mm a');
                String formattedTime = timeFormatter.format(data.dateTime);

                final String customLabel =
                    '$formattedDate \n $formattedTime \n ${data.bloodSugar.toInt()}';

                var Boxcolor = Colors.black87;
                if (data.label == 'Before') {
                  Boxcolor = Colors.teal;
                } else if (data.label == 'After') {
                  Boxcolor = Colors.deepPurpleAccent;
                } else {
                  Boxcolor = Colors.lightBlue;
                }

                return Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Boxcolor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    customLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            width: 8,
            height: 8,
            color: Color(0xffF86851),
            borderColor: Colors.white,
            borderWidth: 2,
          ),
        ),
      ],
    );
  }

  Widget buildDailyBloodSugarGraph() {

    List<ChartData> chartData = [];
    Map<DateTime, List<double>> dailyBloodSugarMap = {};

    // Assuming bloodSugarData is a List<Map<String, dynamic>> with 'date', 'blood_sugar', and 'time' fields
    for (var data in bloodSugarData) {
      var bloodSugar = data['blood_sugar'];
      var date = DateTime.parse(data['date']);

      // Accumulate blood sugar data for each day
      dailyBloodSugarMap.putIfAbsent(date, () => []);
      dailyBloodSugarMap[date]?.add(bloodSugar);
    }

    // Calculate the average blood sugar for each day
    dailyBloodSugarMap.forEach((date, bloodSugarList) {
      double averageBloodSugar =
          bloodSugarList.reduce((a, b) => a + b) / bloodSugarList.length;

      // You can customize the label based on your needs
      String label = 'Daily Average';

      chartData.add(ChartData(date, averageBloodSugar, label));
    });

    chartData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return SfCartesianChart(
      plotAreaBorderColor: const Color(0xffF2F2F2),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Time', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Blood Sugar', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
        labelFormat: '{value} mg/dl',
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableSelectionZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: <LineSeries<ChartData, DateTime>>[
        LineSeries<ChartData, DateTime>(
          name: 'Blood Sugar Level',
          color: Color(0xffF86851),
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.bloodSugar,
          dataLabelSettings: DataLabelSettings(
            isVisible: true,
            labelAlignment: ChartDataLabelAlignment.auto,
            builder: (dynamic data, dynamic point, dynamic series,
                int dataIndex, int pointIndex) {
              if (data is ChartData) {
                // Format the date as "dd/MM/yyyy"
                var dateFormatter = DateFormat('dd/MM/yyyy');
                String formattedDate = dateFormatter.format(data.dateTime);

                // Format the time as "HH:mm"
                var timeFormatter = DateFormat('hh:mm a');
                String formattedTime = timeFormatter.format(data.dateTime);

                final String customLabel =
                    '$formattedDate \n $formattedTime \n ${data.bloodSugar.toInt()}';

                var Boxcolor = Colors.black87;
                if (data.label == 'Before') {
                  Boxcolor = Colors.teal;
                } else if (data.label == 'After') {
                  Boxcolor = Colors.deepPurpleAccent;
                } else {
                  Boxcolor = Colors.lightBlue;
                }

                return Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Boxcolor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    customLabel,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      textStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              }
              return Container();
            },
          ),
          markerSettings: const MarkerSettings(
            isVisible: true,
            shape: DataMarkerType.circle,
            width: 8,
            height: 8,
            color: Color(0xffF86851),
            borderColor: Colors.white,
            borderWidth: 2,
          ),
        ),
      ],
    );
  }

  Widget buildWeeklyBloodSugarGraph() {

    Map<int, List<ChartData>> weekdayBloodSugarMap = {};
    // Assuming bloodSugarData is a List<Map<String, dynamic>> with 'date', 'blood_sugar', and 'time' fields
    for (var data in bloodSugarData) {
      var bloodSugar = data['blood_sugar'];
      var date = DateTime.parse(data['date']);
      var timeString = data['time'];
      var mealTime = data['meal_type'];

      List<String> timeComponents = timeString.split(':');
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      var combinedDateTime = DateTime(date.year, date.month, date.day, hour, minute);

      var weekday = date.weekday;

      weekdayBloodSugarMap.putIfAbsent(weekday, () => []);
      weekdayBloodSugarMap[weekday]!.add(ChartData(combinedDateTime, bloodSugar, mealTime));
    }

    List<LineSeries<ChartData, DateTime>> seriesList = [];

    weekdayBloodSugarMap.forEach((weekday, data) {
      data.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      seriesList.add(LineSeries<ChartData, DateTime>(
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.dateTime,
        yValueMapper: (ChartData data, _) => data.bloodSugar,
        name: 'Day $weekday',
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ));
    });

    return SfCartesianChart(
      plotAreaBorderColor: const Color(0xffF2F2F2),
      legend: Legend(isVisible: true, position: LegendPosition.bottom),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Time', textStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xff6373CC))),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Blood Sugar', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
        labelFormat: '{value} mg/dl',
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: true,
        enablePinching: true,
        enableSelectionZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: seriesList,
    );
  }

}

class ChartData {
  final DateTime dateTime;
  final double bloodSugar;
  final String label; // Use label to differentiate between daily and weekly data

  ChartData(this.dateTime, this.bloodSugar, this.label);
}

