import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';
import 'package:flutter_frontend/services/firebase_services.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';
import '../../Components/snackbars.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<Map<String, dynamic>> residences = [];
  bool isLoading = true;

  final List<String> areas = [
    'myala',
    'lurambi',
    'sichirayi',
    'amalemba',
    'kefinco',
    'milimani',
    'shinyalu',
    'koromatangi',
    'kakamega town',
    'mudiri',
    'lubao',
    'stage mandazi',
    'khayega'
  ];

  Map<String, int> locationCounts = {};
  int touchedIndex = -1;


  @override
  void initState() {
    super.initState();
    fetchStudentCounts();
  }

  Future<void> fetchStudentCounts() async {
    try {
      final counts = { for (var area in areas) area: 0};
      List<Map<String,dynamic>> residencies = await _firebaseServices.fetchResidences();
      for(var residency in residencies){
        String location = residency['houseLocation'].toString().toLowerCase();
        if(counts.containsKey(location)){
          counts[location] = (counts[location]! + 1)!;
        }
      }
      setState(() {
        locationCounts = counts;
        isLoading = false;
      });
    }catch(e){
      setState(() {
        isLoading = false;
      });
      if(!context.mounted) return;
      SnackBars.showErrorSnackBar(context, 'An error occurred');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: "Admin Dashboard",
        ),
      ),
      drawer: AdminSideNav(),
      body: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: AspectRatio(
              aspectRatio: 1.3,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.0)),
              child: Padding(
                  padding: EdgeInsets.all(16.0),
                child: Column(
                  spacing: 20.0,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Distribution of students across different areas'),
                    Expanded(
                        child: isLoading? Center(child: CircularProgressIndicator(),):
                            BarChart(mainBarData()),
                    ),
                  ],
                ),
              ),

            ),
          ),
        ),
      )
    );
  }
  BarChartGroupData makeGroupData(
      int x,
      double y,
  {
    bool isTouched = false,
    Color barColor = Colors.blue,
    double width = 22,
  }
      ){
    return BarChartGroupData(x: x,
      barRods: [
        BarChartRodData(toY: y,
          color: isTouched? Colors.blueAccent : barColor,
          width: width,
          borderRadius: BorderRadius.circular(4.0),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: _getMaxStudentCount().toDouble(),
            color: Colors.grey[200],
          )
        )
      ]
    );
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final location = areas[group.x];
            final count = locationCounts[location] ?? 0;
            return BarTooltipItem(
              '$location\n',
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '$count students',
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < areas.length) {
                  final location = areas[index];
                  final abbreviated = location.length > 8
                      ? '${location.substring(0, 5)}..'
                      : location;
                  return SideTitleWidget(
                    fitInside: const SideTitleFitInsideData(
                        enabled: true,
                        axisPosition: 0,
                        parentAxisSize: 0,
                        distanceFromEdge: 5),
                    space: 16,
                    meta: meta,
                    child: Text(
                      abbreviated,
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 42),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: _getInterval().toDouble(),
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: _getInterval().toDouble(),
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      barGroups: areas.asMap().entries.map((entry) {
        final index = entry.key;
        final location = entry.value;
        final count = locationCounts[location] ?? 0;
        return makeGroupData(
          index,
          count.toDouble(),
          isTouched: index == touchedIndex,
          barColor: _getBarColor(index),
        );
      }).toList(),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
    Color(0xFFFF0000),
    Color(0xFF00FF00),
    Color(0xFFFFFF00),
    Color(0xFFFFA500),
    Color(0xFF800080),
    Color(0xFFFFC0CB),
    Color(0xFFA52A2A),
    Colors.tealAccent,
    Colors.indigoAccent,
    Color(0xFF808080),
    Color(0xFFFFD700),
    Color(0xFFFF00FF),
    Colors.teal,
    ];
    return colors[index];
  }

  int _getMaxStudentCount() {
    if (locationCounts.isEmpty) return 10;
    final maxCount = locationCounts.values.reduce((a, b) => a > b ? a : b);
    return ((maxCount / 5).ceil() * 5) + 5;
  }

  int _getInterval() {
    final maxCount = _getMaxStudentCount();
    if (maxCount <= 10) return 2;
    if (maxCount <= 20) return 5;
    return 10;
  }
}
