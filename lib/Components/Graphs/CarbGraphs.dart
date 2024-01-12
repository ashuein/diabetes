import 'dart:convert';
import 'package:diabetes_ms/Components/Log/MealIntakeLog.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../URL.dart';
import '../ColorBlockDialog.dart';
import 'package:dropdown_model_list/dropdown_model_list.dart';

class CarbGraph extends StatefulWidget {

  final String patientNumber; // Using the "?" makes it optional
  CarbGraph({required this.patientNumber});

  @override
  _CarbGraphState createState() => _CarbGraphState();
}

class _CarbGraphState extends State<CarbGraph> {

  String selectedProfile = 'Today';
  List<Map<String, dynamic>> carbData = [];

  DropListModel dropListModel = DropListModel([
    OptionItem(id: "1", title: "Today"),
    OptionItem(id: "2", title: "Daily"),
    OptionItem(id: "3", title: "Weekly"),
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
        Uri.parse('${URL.baseUrl}/get_mealIntake/$phoneNumber'),
        headers: {'Connection': 'keep-alive'});
    if (response.statusCode == 200) {
      setState(() {
        carbData = List<Map<String, dynamic>>.from(json.decode(response.body));
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
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Carbs Intake Statistics",
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
                  if (carbData.isNotEmpty) {
                    if (selectedProfile == 'Today') {
                      return buildTodayCarbGraph();
                    } else if (selectedProfile == 'Daily') {
                      return buildDailyCarbGraph();
                    } else if (selectedProfile == 'Weekly') {
                      return buildWeeklyCarbGraph();
                    } else if (selectedProfile == 'Monthly') {
                      return buildMonthlyCarbGraph();
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
              builder: (context) =>
                  MealIntakeLog(patientNumber: widget.patientNumber,),
            ),
          );
        },
        child: const Icon(Icons.book),
      ),
    );
  }

  Widget buildTodayCarbGraph() {
    List<ChartData> chartData = [];
    DateTime today = DateTime.now();

    for (var data in carbData) {
      var carbs = data['carb'];
      var date = DateTime.parse(data['date']);

      // Check if the data entry is from today
      if (date.year == today.year && date.month == today.month &&
          date.day == today.day) {
        var timeString = data['time'];
        var meal_intake = data['meal_intake'];

        List<String> timeComponents = timeString.split(':');
        int hour = int.parse(timeComponents[0]);
        int minute = int.parse(timeComponents[1]);

        var combinedDateTime = DateTime(
            date.year, date.month, date.day, hour, minute);
        chartData.add(ChartData(combinedDateTime, carbs, meal_intake));
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
        title: AxisTitle(text: 'Carb Intake', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
        labelFormat: '{value}',
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
          name: 'Carbs Intake',
          color: Color(0xffF86851),
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.carb,
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
                    '$formattedDate \n $formattedTime \n ${data.carb
                    .toInt()}';

                var Boxcolor = Colors.black87;
                if (data.label == 'Light') {
                  Boxcolor = Colors.teal;
                } else if (data.label == 'Moderate') {
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

  Widget buildDailyCarbGraph() {
    List<ChartData> chartData = [];
    Map<DateTime, List<double>> dailyCarbMap = {};

    // carbData is a List<Map<String, dynamic>> with 'date', 'carb', and 'time' fields
    for (var data in carbData) {
      var carb = data['carb'];
      var date = DateTime.parse(data['date']);

      // Accumulate carb data for each day
      dailyCarbMap.putIfAbsent(date, () => []);
      dailyCarbMap[date]?.add(carb);
    }


    dailyCarbMap.forEach((date, carbList) {
      // Filter out zero values
      List<double> nonZeroCarbList = carbList.where((value) => value != 0).toList();

      if (nonZeroCarbList.isNotEmpty) {
        // Calculate the average excluding zero values
        double averageCarb = nonZeroCarbList.reduce((a, b) => a + b) / nonZeroCarbList.length;

        // You can customize the label based on your needs
        String label = 'Daily Average';

        // Assuming ChartData constructor takes (DateTime, double, String) as parameters
        chartData.add(ChartData(date, averageCarb, label));
      } else {
        print('Date: $date, No non-zero values for the day');
      }
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
        title: AxisTitle(text: 'Carb Intake', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
        labelFormat: '{value}',
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
          name: 'Carbs Intake',
          color: Color(0xffF86851),
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.carb,
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

  Widget buildWeeklyCarbGraph() {
    List<ChartData> chartData = [];
    DateTime today = DateTime.now();

    // Separate data by days of the week
    Map<int, List<ChartData>> dayOfWeekData = {};

    for (var data in carbData) {
      var carbs = data['carb'];
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

        chartData.add(ChartData(combinedDateTime, carbs, data['meal_intake']));

        chartData.sort((a, b) => a.dateTime.compareTo(b.dateTime));

        // Separate data by day of the week
        var dayOfWeek = date.weekday;
        if (!dayOfWeekData.containsKey(dayOfWeek)) {
          dayOfWeekData[dayOfWeek] = [];
        }
        dayOfWeekData[dayOfWeek]!.add(ChartData(combinedDateTime, carbs, data['meal_intake']));
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
        yValueMapper: (ChartData data, _) => data.carb,
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
        title: AxisTitle(text: 'Carbs Intake'),
        majorGridLines: MajorGridLines(width: 0),
        minorGridLines: MinorGridLines(width: 0),
        axisLine: AxisLine(width: 2),
        labelFormat: '{value}',
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

  Widget buildMonthlyCarbGraph() {

    List<ChartData> chartData = [];
    Map<DateTime, List<double>> monthlyCarbsMap = {};

    // Carb is a List<Map<String, dynamic>> with 'date', 'carb', and 'time' fields
    for (var data in carbData) {
      var carb = data['carb'];
      var date = DateTime.parse(data['date']);

      // Accumulate carb data for each month
      var firstDayOfMonth = DateTime(date.year, date.month, 1);
      monthlyCarbsMap.putIfAbsent(firstDayOfMonth, () => []);
      monthlyCarbsMap[firstDayOfMonth]?.add(carb);
    }

    monthlyCarbsMap.forEach((date, carbList) {
      // Filter out zero values
      List<double> nonZeroCarbList = carbList.where((value) => value != 0).toList();

      if (nonZeroCarbList.isNotEmpty) {
        // Calculate the average excluding zero values
        double averageCarb = nonZeroCarbList.reduce((a, b) => a + b) / nonZeroCarbList.length;

        // You can customize the label based on your needs
        String label = 'Monthly Average';

        // Assuming ChartData constructor takes (DateTime, double, String) as parameters
        chartData.add(ChartData(date, averageCarb, label));
      } else {
        print('Date: $date, No non-zero values for the day');
      }
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
        title: AxisTitle(text: 'Carbs Intake', textStyle: GoogleFonts.inter(
          textStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Color(0xff6373CC),
          ),
        )),
        majorGridLines: const MajorGridLines(width: 0),
        minorGridLines: const MinorGridLines(width: 0),
        axisLine: const AxisLine(width: 2, color: Color(0xff6373CC)),
        labelFormat: '{value}',
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
          name: 'Carbs Intake',
          color: Color(0xffF86851),
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.dateTime,
          yValueMapper: (ChartData data, _) => data.carb,
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
                    '$formattedDate \n ${data.carb
                    .toInt()}';

                var Boxcolor = Colors.black87;
                if (data.label == 'Light') {
                  Boxcolor = Colors.teal;
                } else if (data.label == 'Moderate') {
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
  final double carb;
  final String label; // Use label to differentiate between daily and weekly data

  ChartData(this.dateTime, this.carb, this.label);
}

