import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../URL.dart';
import '../ColorBlockDialog.dart';
import '../Log/BloodSugarLogs.dart';
import 'package:dropdown_model_list/dropdown_model_list.dart';
import 'package:toast/toast.dart';

class BloodSugarGraph extends StatefulWidget {

  final String patientNumber;
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
    OptionItem(id: "3", title: "This Week"),
    OptionItem(id: "4", title: "Monthly"),
  ]);
  OptionItem optionItemSelected = OptionItem(title: "Today");

  @override
  void initState() {
    super.initState();
    fetchData(widget.patientNumber);
  }

  Future<void> fetchData(phoneNumber) async {
    final response = await http.get(
        Uri.parse('${URL.baseUrl}/blood_sugar_records/$phoneNumber'),
      headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      setState(() {
        bloodSugarData =
        List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      Toast.show(
        "Error fetching data try again...",
        duration: Toast.lengthShort,
        gravity: Toast.bottom,
        backgroundRadius: 8.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    ToastContext().init(context);

    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff6373CC)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Blood Sugar Statistics",
                style: GoogleFonts.inter(
                  textStyle: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff6373CC),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: FittedBox(fit:BoxFit.scaleDown,child: const Icon(Icons.info_outlined)),
              onPressed: () =>
                  showDialog(
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
            paddingDropItem: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
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
                    } else if (selectedProfile == 'This Week') {
                      return buildWeeklyBloodSugarGraph();
                    } else if (selectedProfile == 'Monthly') {
                      return buildMonthlyBloodSugarGraph();
                    } else {
                      // You can add other cases as needed
                      return const Text('Not implemented yet');
                    }
                  } else {
                    return const Text("No Data Available");
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
              builder: (context) =>
                  BloodSugarLog(patientNumber: widget.patientNumber,),
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
      if (date.year == today.year && date.month == today.month &&
          date.day == today.day) {
        var timeString = data['time'];
        var meal_time = data['meal_type'];

        List<String> timeComponents = timeString.split(':');
        int hour = int.parse(timeComponents[0]);
        int minute = int.parse(timeComponents[1]);

        var combinedDateTime = DateTime(
            date.year, date.month, date.day, hour, minute);
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
                    '$formattedDate \n $formattedTime \n ${data.bloodSugar
                    .toInt()}';

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
      double averageBloodSugar = bloodSugarList.reduce((a, b) => a + b) /
          bloodSugarList.length;

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
          // dataLabelSettings: DataLabelSettings(
          //   isVisible: true,
          //   labelAlignment: ChartDataLabelAlignment.auto,
          //   builder: (dynamic data, dynamic point, dynamic series,
          //       int dataIndex, int pointIndex) {
          //     if (data is ChartData) {
          //       // Format the date as "dd/MM/yyyy"
          //       var dateFormatter = DateFormat('dd/MM/yyyy');
          //       String formattedDate = dateFormatter.format(data.dateTime);
          //
          //       final String customLabel =
          //           '$formattedDate \n ${data.bloodSugar
          //           .toInt()}';
          //
          //       var Boxcolor = Colors.black87;
          //       if (data.label == 'Before') {
          //         Boxcolor = Colors.teal;
          //       } else if (data.label == 'After') {
          //         Boxcolor = Colors.deepPurpleAccent;
          //       } else {
          //         Boxcolor = Colors.lightBlue;
          //       }
          //
          //       return Container(
          //         padding: const EdgeInsets.all(5),
          //         decoration: BoxDecoration(
          //           color: Boxcolor,
          //           borderRadius: BorderRadius.circular(5),
          //         ),
          //         child: Text(
          //           customLabel,
          //           textAlign: TextAlign.center,
          //           style: GoogleFonts.inter(
          //             textStyle: const TextStyle(
          //               fontSize: 8,
          //               fontWeight: FontWeight.bold,
          //               color: Colors.white,
          //             ),
          //           ),
          //         ),
          //       );
          //     }
          //     return Container();
          //   },
          // ),
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
    List<ChartData> chartData = [];
    DateTime today = DateTime.now();

    // Separate data by days of the week
    Map<int, List<ChartData>> dayOfWeekData = {};

    for (var data in bloodSugarData) {
      var bloodSugar = data['blood_sugar'];
      var date = DateTime.parse(data['date']);

      var timeString = data['time'];
      var dayOfWeek = date.weekday;

      List<String> timeComponents = timeString.split(':');
      int hour = int.parse(timeComponents[0]);
      int minute = int.parse(timeComponents[1]);

      var combinedDateTime = DateTime(
          today.year,
          today.month,
          today.day,
          hour,
          minute,
      );

      // Check if the data entry is from this week
      if(date.isAfter(DateTime(today.year, today.month, today.day - today.weekday)) &&
          date.isBefore(DateTime(today.year, today.month, today.day + (7 - today.weekday)))){

        chartData.add(ChartData(combinedDateTime, bloodSugar, data['meal_type']));

        chartData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        // Separate data by day of the week
        var dayOfWeek = date.weekday;
        if (!dayOfWeekData.containsKey(dayOfWeek)) {
          dayOfWeekData[dayOfWeek] = [];
        }
        dayOfWeekData[dayOfWeek]!.add(ChartData(combinedDateTime, bloodSugar, data['meal_type']));
        dayOfWeekData[dayOfWeek]!.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      }
    }

    // Sort the combined data
    chartData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

    // Create LineSeries for each day of the week
    List<LineSeries<ChartData, DateTime>> seriesList = [];
    dayOfWeekData.forEach((dayOfWeek, data) {
      seriesList.add(LineSeries<ChartData, DateTime>(
        name: _getDayOfWeekLabel(dayOfWeek),
        color: _getSeriesColor(dayOfWeek),
        dataSource: data,
        xValueMapper: (ChartData data, _) => data.dateTime,
        yValueMapper: (ChartData data, _) => data.bloodSugar,
        markerSettings: MarkerSettings(
          isVisible: true,
          shape: DataMarkerType.circle,
          width: 8,
          height: 8,
          color: _getSeriesColor(dayOfWeek),
          borderColor: Colors.white,
          borderWidth: 2,
        ),
      ));
    });

    return SfCartesianChart(
      legend: Legend(isVisible: true),
      primaryXAxis: DateTimeAxis(
        title: AxisTitle(text: 'Time'),
        majorGridLines: MajorGridLines(width: 0),
        minorGridLines: MinorGridLines(width: 0),
        edgeLabelPlacement: EdgeLabelPlacement.shift,
        axisLine: AxisLine(width: 2),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Blood Sugar'),
        majorGridLines: MajorGridLines(width: 0),
        minorGridLines: MinorGridLines(width: 0),
        axisLine: AxisLine(width: 2),
        labelFormat: '{value} mg/dl',
      ),
      zoomPanBehavior: ZoomPanBehavior(
        enablePanning: true,
        enableDoubleTapZooming: false,
        enablePinching: true,
        enableSelectionZooming: true,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      series: seriesList,
    );
  }

  String _getDayOfWeekLabel(int dayOfWeek) {
    // Provide a label for each day of the week
    switch (dayOfWeek) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  Color _getSeriesColor(int dayOfWeek) {
    // Provide a color based on the day of the week
    // You can customize the colors based on your preferences
    switch (dayOfWeek) {
      case 1:
        return Colors.teal;
      case 2:
        return Colors.deepPurpleAccent;
      case 3:
        return Colors.lightBlue;
      case 4:
        return Colors.orange;
      case 5:
        return Colors.red;
      case 6:
        return Colors.green;
      case 7:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  Widget buildMonthlyBloodSugarGraph() {

    List<ChartData> chartData = [];
    Map<DateTime, List<double>> monthlyBloodSugarMap = {};

    // Assuming bloodSugarData is a List<Map<String, dynamic>> with 'date', 'blood_sugar', and 'time' fields
    for (var data in bloodSugarData) {
      var bloodSugar = data['blood_sugar'];
      var date = DateTime.parse(data['date']);

      // Accumulate blood sugar data for each month
      var firstDayOfMonth = DateTime(date.year, date.month, 1);
      monthlyBloodSugarMap.putIfAbsent(firstDayOfMonth, () => []);
      monthlyBloodSugarMap[firstDayOfMonth]?.add(bloodSugar);
    }

    // Calculate the average blood sugar for each month
    monthlyBloodSugarMap.forEach((date, bloodSugarList) {
      double averageBloodSugar = bloodSugarList.reduce((a, b) => a + b) /
          bloodSugarList.length;

      // You can customize the label based on your needs
      String label = 'Monthly Average';

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
                    '$formattedDate \n ${data.bloodSugar
                    .toInt()}';

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

}

class ChartData {
  final DateTime dateTime;
  final double bloodSugar;
  final String label; // Use label to differentiate between daily and weekly data

  ChartData(this.dateTime, this.bloodSugar, this.label);
}

