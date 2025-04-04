import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewLandlordsPage extends StatefulWidget {
  const ViewLandlordsPage({super.key});

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
      appBar: AppBar(
        title: const Text('View Landlords'),
      ),
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
