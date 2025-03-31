import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/side_nav_item.dart';
import 'package:flutter_frontend/services/firebase_services.dart';

class StudentSideNav extends StatelessWidget {
  const StudentSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {

              },
              child: SideNavItem(text: 'Dashboard')),
          GestureDetector(
              onTap: () {

              },
              child: SideNavItem(text: 'My Bookings'),),
          SideNavItem(text: 'Give Feedback'),
          SideNavItem(text: 'Help and Support'),
          GestureDetector(
            onTap: () async{
              await FirebaseServices().signOut(context);
            },
              child: SideNavItem(text: 'Log out'),),
        ],
      ),
    );
  }
}
