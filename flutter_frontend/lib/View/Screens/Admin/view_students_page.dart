import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';
import 'package:flutter_frontend/services/firebase_services.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class ViewStudentsPage extends StatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const ViewStudentsPage(
      {super.key,
      required this.colorSelected,
      required this.changeTheme,
      required this.changeColor});

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: 'View Students',
        ),
      ),
      drawer: AdminSideNav(),
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
