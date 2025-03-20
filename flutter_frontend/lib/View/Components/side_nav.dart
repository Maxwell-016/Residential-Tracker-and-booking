import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/side_nav_item.dart';
import 'package:go_router/go_router.dart';

class SideNav extends StatelessWidget {
  const SideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                context.go('/landlord-dashboard');
              },
              child: SideNavItem(text: 'Dashboard')),
          GestureDetector(
              onTap: () {
                context.go('/manageListings');
              },
              child: SideNavItem(text: 'Manage House Listings')),
          SideNavItem(text: 'Students Bookings'),
          SideNavItem(text: 'Reviews and Feedback'),
          SideNavItem(text: 'Profile'),
        ],
      ),
    );
  }
}
