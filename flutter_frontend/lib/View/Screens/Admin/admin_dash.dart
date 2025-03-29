import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/View/Screens/Admin/admin_settings.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirebaseServices _firebaseServices = FirebaseServices();
  List<Map<String, dynamic>> residences = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResidences();
  }

  Future<void> fetchResidences() async {
    try {
      final data = await _firebaseServices.fetchResidences();
      setState(() {
        residences = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch residences: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: residences.length,
                    itemBuilder: (context, index) {
                      final residence = residences[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(residence['houseName'] ?? 'Unknown'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Location: ${residence['houseLocation'] ?? 'N/A'}'),
                              Text('Landlord: ${residence['landlordName'] ?? 'N/A'}'),
                              Text('Student: ${residence['name'] ?? 'N/A'}'),
                              Text('Student Contact: ${residence['stdContact'] ?? 'N/A'}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminSettingsPage(),
                      ),
                    );
                  },
                  child: const Text('Go to Admin Settings'),
                ),
              ],
            ),
    );
  }
}