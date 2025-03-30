import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/card_button.dart';
import 'package:flutter_frontend/View/Components/landlord_side_nav.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../Components/color_button.dart';
import '../../Components/theme_button.dart';


class LandLordDashboardScreen extends StatefulWidget {
  const LandLordDashboardScreen({super.key});

  @override
  State<LandLordDashboardScreen> createState() => _LandLordDashboardScreenState();
}

class _LandLordDashboardScreenState extends State<LandLordDashboardScreen> {
  @override
  Widget build(BuildContext context) {
    Logger logger = Logger();
    logger.i('Rebuilding admin dash');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 30.0),
          centerTitle: true,
          title: Text("Landlord Dashboard"),
          actions: [
          //   ThemeButton(changeThemeMode: changeTheme),
          //    ColorButton(changeColor: changeColor,
          //        colorSelected: colorSelected)
          ],
        ),
        drawer: LandlordSideNav(),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 100.0),
            child: Wrap(
              spacing: 40.0,
              runSpacing: 40.0,
              children: [
                // display
                CardButton(
                    quantity: 89,
                    bgColor: AppColors.totalListings,
                    title: 'Total Listings'),
                CardButton(
                    quantity: 50,
                    bgColor: AppColors.booked,
                    title: 'Booked Houses'),
                CardButton(
                    quantity: 39,
                    bgColor: AppColors.availableListings,
                    title: 'Available Houses'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
