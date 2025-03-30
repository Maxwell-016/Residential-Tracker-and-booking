import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalStudents = 0;
  int nonResidentStudents = 0;
  Map<String, double> locationData = {
    "Lurambi": 0,
    "Sichirai": 0,
    "Tea Zone": 0,
    "Kefinco": 0,
    "Mwiyala": 0,
    "Millimani": 0,
  };

  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    var studentsSnapshot =
        await FirebaseFirestore.instance.collection('students').get();
    setState(() {
      totalStudents = studentsSnapshot.docs.length;
      nonResidentStudents =
          studentsSnapshot.docs.where((doc) => doc['resident'] == false).length;
      locationData = {
        "Lurambi": studentsSnapshot.docs
            .where((doc) => doc['location'] == 'Lurambi')
            .length
            .toDouble(),
        "Sichirai": studentsSnapshot.docs
            .where((doc) => doc['location'] == 'Sichirai')
            .length
            .toDouble(),
        "Tea Zone": studentsSnapshot.docs
            .where((doc) => doc['location'] == 'Tea Zone')
            .length
            .toDouble(),
        "Kefinco": studentsSnapshot.docs
            .where((doc) => doc['location'] == 'Kefinco')
            .length
            .toDouble(),
        "Mwiyala": studentsSnapshot.docs
            .where((doc) => doc['location'] == 'Mwiyala')
            .length
            .toDouble(),
        "Millimani": studentsSnapshot.docs
            .where((doc) => doc['location'] == 'Millimani')
            .length
            .toDouble(),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  showSearchPopup(context, value);
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total number of students:"),
                    TextField(
                      controller: TextEditingController(text: "$totalStudents"),
                      readOnly: true,
                    ),
                    SizedBox(height: 10),
                    Text("Non-resident students:"),
                    TextField(
                      controller:
                          TextEditingController(text: "$nonResidentStudents"),
                      readOnly: true,
                    ),
                  ],
                ),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: PieChart(
                    PieChartData(
                      sections: locationData.entries.map((entry) {
                        return PieChartSectionData(
                          value: entry.value,
                          title: entry.key,
                          color: getLocationColor(entry.key),
                          radius: 50,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color getLocationColor(String location) {
    switch (location) {
      case "Lurambi":
        return Colors.green;
      case "Sichirai":
        return Colors.blue;
      case "Tea Zone":
        return Colors.purple;
      case "Kefinco":
        return Colors.orange;
      case "Mwiyala":
        return Colors.black;
      case "Millimani":
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  void showSearchPopup(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Search Student"),
          content: TextField(
            decoration: InputDecoration(
              hintText: "Enter student email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }
}
