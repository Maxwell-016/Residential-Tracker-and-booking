import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/admin_side_nav.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class ViewLandlordsPage extends StatefulWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  const ViewLandlordsPage({
    super.key,
    required this.colorSelected,
    required this.changeTheme,
    required this.changeColor,
  });

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
    final screenWidth = MediaQuery.of(context).size.width;

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
              : LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      // Small screen layout (e.g., mobile)
                      return ListView.builder(
                        itemCount: landlords.length,
                        itemBuilder: (context, index) {
                          final landlord = landlords[index];
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: landlord['Profile Photo'] != null
                                  ? Image.network(
                                      landlord['Profile Photo'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    )
                                  : const Icon(Icons.person),
                              title: Text(
                                landlord['Name'] ?? 'N/A',
                                style: TextStyle(fontSize: screenWidth * 0.04),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Email: ${landlord['Email'] ?? 'N/A'}',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035),
                                  ),
                                  Text(
                                    'Location: ${landlord['Location'] ?? 'N/A'}',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035),
                                  ),
                                  Text(
                                    'Phone: ${landlord['Phone Number'] ?? 'N/A'}',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035),
                                  ),
                                  Text(
                                    'Verified: ${landlord['isVerified'] == true ? 'Yes' : 'No'}',
                                    style: TextStyle(
                                        fontSize: screenWidth * 0.035),
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
                            DataColumn(label: Text('Location')),
                            DataColumn(label: Text('Phone Number')),
                            DataColumn(label: Text('Profile Photo')),
                            DataColumn(label: Text('Verified')),
                          ],
                          rows: landlords.map((landlord) {
                            return DataRow(cells: [
                              DataCell(Text(
                                landlord['Name'] ?? 'N/A',
                                style: TextStyle(fontSize: screenWidth * 0.015),
                              )),
                              DataCell(Text(
                                landlord['Email'] ?? 'N/A',
                                style: TextStyle(fontSize: screenWidth * 0.015),
                              )),
                              DataCell(Text(
                                landlord['Location'] ?? 'N/A',
                                style: TextStyle(fontSize: screenWidth * 0.015),
                              )),
                              DataCell(Text(
                                landlord['Phone Number'] ?? 'N/A',
                                style: TextStyle(fontSize: screenWidth * 0.015),
                              )),
                              DataCell(
                                landlord['Profile Photo'] != null
                                    ? Image.network(
                                        landlord['Profile Photo'],
                                        width: 150,
                                        height: 150,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Text('Error');
                                        },
                                      )
                                    : const Text('No Photo'),
                              ),
                              DataCell(Text(
                                landlord['isVerified'] == true ? 'Yes' : 'No',
                                style: TextStyle(fontSize: screenWidth * 0.015),
                              )),
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