import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/View/Components/individual_bar.dart';

class NewbarGraph extends StatefulWidget {
  const NewbarGraph({super.key});

  @override
  State<NewbarGraph> createState() => _NewbarGraphState();
}

class _NewbarGraphState extends State<NewbarGraph> {
  final FirebaseServices firebaseServices = FirebaseServices();
  List<individualBar> barData = [];
  List<String> residenceLabels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  // Get max Y value dynamically based on the data
  double getMaxY() {
    if (barData.isEmpty) return 10;
    double maxYValue = barData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    //print("Max Y Value: $maxYValue"); // Debugging the max Y value
    return maxYValue;
  }

  Future<void> fetchStudentData() async {
    try {
      final data = await firebaseServices.fetchResidences();
      // print("Raw Firebase data: $data");

      Map<String, int> residenceCounts = {};

      // Group data by residence and count the number of students in each residence
      for (var entry in data) {
        String? residence = entry['houseLocation'];
        if (residence != null) {
          residenceCounts[residence] = (residenceCounts[residence] ?? 0) + 1;
        }
      }

      //print("Residence Counts (after processing): $residenceCounts");

      // Prepare the bar data and labels
      List<individualBar> generatedBars = [];
      List<String> labels = [];
      int index = 0;

      // Populate bar data with residence counts
      residenceCounts.forEach((residence, count) {
        generatedBars.add(
            individualBar(index, count.toDouble())); // Use count for bar height
        labels.add(residence);
        index++;
      });

      //print("Generated Bars (Bar Data): $generatedBars");

      setState(() {
        barData = generatedBars;
        residenceLabels = labels;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Optional spacing from the edges
        child: SizedBox(
          height: 300,
          width: 350, // You can adjust the width as needed
          child: BarChart(
            BarChartData(
              maxY: getMaxY() + 5, // Adjust Y max dynamically
              minY: 0,
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              // titlesData: FlTitlesData(
              //   show: true,
              //   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              //   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              //   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              // ),
              barGroups: barData
                  .map(
                    (data) => BarChartGroupData(
                      x: data.x,
                      barRods: [
                        BarChartRodData(
                            toY: data.y,
                            width: 25,
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(4),
                            backDrawRodData: BackgroundBarChartRodData(
                              show: true,
                              toY: 50,
                              color: Colors.grey[200],
                            ) // Bar color
                            ),
                      ],
                    ),
                  )
                  .toList(),
              titlesData: FlTitlesData(
                topTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    AxisTitles(sideTitles: SideTitles(showTitles: true)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      int index = value.toInt();
                      if (index >= 0 && index < residenceLabels.length) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            residenceLabels[index],
                            style: const TextStyle(fontSize: 10),
                            overflow:
                                TextOverflow.ellipsis, // Handle long labels
                          ),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
    // return Center(
    //   child: SizedBox(
    //     height: 300,
    //     width: 200,
    //     child: BarChart(
    //       BarChartData(
    //         maxY: getMaxY() + 5, // Adjust Y max dynamically
    //         minY: 0,
    //         gridData: FlGridData(show: false),
    //         borderData: FlBorderData(show: false),
    //         // titlesData: FlTitlesData(
    //         //   show: true,
    //         //   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //         //   leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //         //   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //         // ),
    //         barGroups: barData
    //             .map(
    //               (data) => BarChartGroupData(
    //                 x: data.x,
    //                 barRods: [
    //                   BarChartRodData(
    //                       toY:
    //                           data.y, // Ensure this is the correct scaled value
    //                       width: 25,
    //                       color: Colors.blue,
    //                       borderRadius: BorderRadius.circular(4),
    //                       backDrawRodData: BackgroundBarChartRodData(
    //                         show: true,
    //                         toY: 50,
    //                         color: Colors.grey[200],
    //                       ) // Bar color
    //                       ),
    //                 ],
    //               ),
    //             )
    //             .toList(),
    //         titlesData: FlTitlesData(
    //           topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    //           rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
    //           bottomTitles: AxisTitles(
    //             sideTitles: SideTitles(
    //               showTitles: true,
    //               getTitlesWidget: (double value, TitleMeta meta) {
    //                 int index = value.toInt();
    //                 if (index >= 0 && index < residenceLabels.length) {
    //                   return SideTitleWidget(
    //                     axisSide: meta.axisSide,
    //                     child: Text(
    //                       residenceLabels[index],
    //                       style: const TextStyle(fontSize: 10),
    //                       overflow: TextOverflow.ellipsis, // Handle long labels
    //                     ),
    //                   );
    //                 } else {
    //                   return const SizedBox.shrink();
    //                 }
    //               },
    //             ),
    //           ),
    //         ),
    //       ),kk
    //     ),
    //   ),
    // );