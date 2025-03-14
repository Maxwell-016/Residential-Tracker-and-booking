import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/navigation/routes.dart';
import 'package:flutter_frontend/View-Model/utils/themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(ProviderScope(child: const ResidentialTrackerAndBooking()));
}

class ResidentialTrackerAndBooking extends StatelessWidget {
  const ResidentialTrackerAndBooking({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      theme: Themes.lightTheme,
      darkTheme: Themes.darkTheme,
      routerConfig: Routes.routeMaker(context),
      title: "Residential Tracker and Booking",
    );
  }
}
