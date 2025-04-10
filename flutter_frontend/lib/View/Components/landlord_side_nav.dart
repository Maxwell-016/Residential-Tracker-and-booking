import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/side_nav_item.dart';
import 'package:go_router/go_router.dart';

class LandlordSideNav extends StatelessWidget {
  const LandlordSideNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          GestureDetector(
              onTap: () {
                context.go('/landlord-dashboard');
              },
              child: SideNavItem(icon:Icon(Icons.dashboard,color: Colors.blue,) ,text: 'Dashboard')),
          GestureDetector(
              onTap: () {
                context.go('/manageListings');
              },
              child: SideNavItem(icon: Icon(Icons.apartment,color: Colors.blue,), text: 'Manage House Listings')),
          GestureDetector(
              onTap: () {
                context.go('/student-bookings');
              },
              child: SideNavItem(icon: Icon(Icons.calendar_month,color: Colors.blue,),text: 'Students Bookings')),
          GestureDetector(
            onTap: (){
              context.go('/tenant-feedback');
            },
              child: SideNavItem(icon: Icon(Icons.feedback,color: Colors.blue,), text: 'Reviews and Feedback')),
          GestureDetector(
            onTap: (){
              context.go('/wallet');
            },
            child: SideNavItem(text: 'My Wallet', icon: Icon(Icons.wallet,color: Colors.blue,)),
          ),
          GestureDetector(
            onTap: () {
              context.go('/landlord-profile');
            },
            child: SideNavItem(icon: Icon(Icons.person,color: Colors.blue,), text: 'Profile'),
          ),
        ],
      ),
    );
  }
}
