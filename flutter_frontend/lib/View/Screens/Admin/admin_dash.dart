import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_frontend/View/Screens/Admin/admin_settings.dart';
import 'package:flutter_frontend/View/Screens/Admin/view_students_page.dart';
import 'package:flutter_frontend/View/Screens/Admin/view_landlords_page.dart';
import 'package:flutter_frontend/View/Screens/Admin/add_individuals_page.dart';
import 'package:flutter_frontend/View/Screens/Admin/search_individuals_page.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: App_Bar(
          changeTheme: widget.changeTheme,
          changeColor: widget.changeColor,
          colorSelected: widget.colorSelected,
          title: "Admin Dashboard",
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: const Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Admin Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AdminSettingsPage(
                      changeTheme: widget.changeTheme,
                      changeColor: widget.changeColor,
                      colorSelected: widget.colorSelected,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Students'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewStudentsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('View Landlords'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ViewLandlordsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Individuals'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddIndividualsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.search),
              title: const Text('Search Individuals'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SearchIndividualsPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : const Center(
              child: Text(
                'Welcome to the Admin Dashboard!',
                style: TextStyle(fontSize: 18),
              ),
            ),
    );
  }
}