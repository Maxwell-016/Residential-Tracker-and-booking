import 'package:flutter/material.dart';

class AdminSettingsPage extends StatelessWidget {
  const AdminSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings')
        ),
      body: const Center(
        child: Text(
          'This is the Admin Settings Page',
          style: TextStyle(fontSize: 18),
          ),
      ),
    );
  }
}