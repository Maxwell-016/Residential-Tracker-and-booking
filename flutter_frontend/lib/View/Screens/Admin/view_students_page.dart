import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';

class ViewStudentsPage extends StatefulWidget {
  const ViewStudentsPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Students'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('House Name')),
                  DataColumn(label: Text('House Location')),
                  DataColumn(label: Text('Landlord Name')),
                  DataColumn(label: Text('Student Contact')),
                ],
                rows: students.map((student) {
                  return DataRow(cells: [
                    DataCell(Text(student['name'] ?? 'N/A')),
                    DataCell(Text(student['email'] ?? 'N/A')),
                    DataCell(Text(student['houseName'] ?? 'N/A')),
                    DataCell(Text(student['houseLocation'] ?? 'N/A')),
                    DataCell(Text(student['landlordName'] ?? 'N/A')),
                    DataCell(Text(student['stdContact'] ?? 'N/A')),
                  ]);
                }).toList(),
              ),
            ),
    );
  }
}