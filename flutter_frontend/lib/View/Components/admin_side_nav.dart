import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AdminSideNav extends StatelessWidget {
  const AdminSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
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
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              context.go('/admin-dashboard'
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('View Students'),
            onTap: () {
              context.go('/view-students');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('View Landlords'),
            onTap: () {
              context.go('/view-landlords');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Add Individuals'),
            onTap: () {
              context.go('/add-individuals');
            },
          ),
        ],
      ),
    );
  }
}
