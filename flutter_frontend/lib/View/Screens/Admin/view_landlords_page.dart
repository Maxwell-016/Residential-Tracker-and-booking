import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class ViewLandlordsPage extends StatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const ViewLandlordsPage({super.key, required this.colorSelected, required this.changeTheme, required this.changeColor});

  @override
  State<ViewLandlordsPage> createState() => _ViewLandlordsPageState();
}

class _ViewLandlordsPageState extends State<ViewLandlordsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> landlords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLandlords();
  }

  Future<void> fetchLandlords() async {
    try {
      final snapshot = await _firestore.collection('Landlords').get();
      setState(() {
        landlords = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch landlords: $e')),
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
    title: 'View Landlords',
    ),
    ),
      drawer: AdminSideNav(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : landlords.isEmpty
              ? const Center(
                  child: Text(
                    'No landlords found.',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Email')),
                      DataColumn(label: Text('Location')),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('Profile Photo')),
                      DataColumn(label: Text('Verified')),
                    ],
                    rows: landlords.map((landlord) {
                      return DataRow(cells: [
                        DataCell(Text(landlord['Name'] ?? 'N/A')),
                        DataCell(Text(landlord['Email'] ?? 'N/A')),
                        DataCell(Text(landlord['Location'] ?? 'N/A')),
                        DataCell(Text(landlord['Phone Number'] ?? 'N/A')),
                        DataCell(
                          landlord['profilePhoto'] != null
                              ? Image.network(
                                  landlord['Profile Photo'],
                                  width: 50,
                                  height: 50,
                                )
                              : const Text('No Photo'),
                        ),
                        DataCell(Text(
                            landlord['isVerified'] == true ? 'Yes' : 'No')),
                      ]);
                    }).toList(),
                  ),
                ),
    );
  }
}
