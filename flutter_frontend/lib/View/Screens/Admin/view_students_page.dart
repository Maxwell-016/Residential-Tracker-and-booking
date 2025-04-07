import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/View/Screens/Student/mapscreen.dart'; // Importing MapScreenHouses

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class ViewStudentsPage extends StatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const ViewStudentsPage({
    super.key,
    required this.colorSelected,
    required this.changeTheme,
    required this.changeColor,
  });

  @override
  State<ViewStudentsPage> createState() => _ViewStudentsPageState();
}

class _ViewStudentsPageState extends State<ViewStudentsPage> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<Map<String, dynamic>> students = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      final data = await _firebaseServices.fetchResidences();
      setState(() {
        students = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch student data: $e')),
      );
    }
  }

  void _viewLocationOnMap(Map<String, dynamic> student) {
    if (student['lat'] != null && student['long'] != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreenHouses(
            title: "Location for ${student['name']}",
            houses: [
              {
                "houseName": student['houseName'] ?? 'N/A',
                "location": student['houseLocation'] ?? 'N/A',
                "lat": student['lat'],
                "long": student['long'],
                "image": student['houseImage'] ?? '', // Optional image field
              }
            ],
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location data is not available for this student.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: 'View Students',
        ),
      ),
      drawer: const AdminSideNav(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 600) {
                  // Small screen layout (e.g., mobile)
                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student['name'] ?? 'N/A',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('Email: ${student['email'] ?? 'N/A'}'),
                              Text('House Name: ${student['houseName'] ?? 'N/A'}'),
                              Text('House Location: ${student['houseLocation'] ?? 'N/A'}'),
                              Text('Landlord: ${student['landlord'] ?? 'N/A'}'),
                              Text('Landlord Contact: ${student['landlordContact'] ?? 'N/A'}'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _viewLocationOnMap(student),
                                child: const Text('View Location'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  // Large screen layout (e.g., tablet, desktop)
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: screenWidth * 0.05,
                      columns: const [
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('House Name')),
                        DataColumn(label: Text('House Location')),
                        DataColumn(label: Text('Landlord')),
                        DataColumn(label: Text('Landlord Contact')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: students.map((student) {
                        return DataRow(cells: [
                          DataCell(Text(student['name'] ?? 'N/A')),
                          DataCell(Text(student['email'] ?? 'N/A')),
                          DataCell(Text(student['houseName'] ?? 'N/A')),
                          DataCell(Text(student['houseLocation'] ?? 'N/A')),
                          DataCell(Text(student['landlord'] ?? 'N/A')),
                          DataCell(Text(student['landlordContact'] ?? 'N/A')),
                          DataCell(
                            ElevatedButton(
                              onPressed: () => _viewLocationOnMap(student),
                              child: const Text('View Location'),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                }
              },
            ),
    );
  }
}