import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/card_button.dart';
import 'package:flutter_frontend/View/Components/side_nav.dart';

class LandLoardDashboardScreen extends StatelessWidget {
  const LandLoardDashboardScreen({
    super.key,
    // required this.changeTheme,
    // required this.changeColor,
    // required this.colorSelected,
  });

  // final ColorSelection colorSelected;
  // final void Function(bool useLightMode) changeTheme;
  // final void Function(int value) changeColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 30.0),
          centerTitle: true,
          title: Text("Landlord Dashboard"),
          actions: [
            // ThemeButton(changeThemeMode: changeTheme),
            // ColorButton(changeColor: changeColor, colorSelected: colorSelected)
          ],
        ),
        drawer: SideNav(),
        body: Padding(
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
    );
  }
}
