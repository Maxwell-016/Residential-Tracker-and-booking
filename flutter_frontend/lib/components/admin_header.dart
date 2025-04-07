import 'package:flutter/material.dart';

class AdminHeader extends StatelessWidget {
  const AdminHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('Admin Dashboard'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard');
          },
          child: Text('Dashboard', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
          child: Text('Settings', style: TextStyle(color: Colors.white)),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/logout');
          },
          child: Text('Logout', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
