import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/card_button.dart';

import '../../Components/side_nav.dart';

class ManageHouseListings extends StatelessWidget {
  const ManageHouseListings({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(size: 30.0),
          centerTitle: true,
          title: Text("Manage House Listings"),
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
              CardButton(
                bgColor: AppColors.manage,
                title: 'Add House',
                icon: Icon(
                  color: Colors.black,
                  Icons.add_circle_outline_outlined,
                  size: 30.0,
                ),
              ),
              CardButton(
                bgColor: AppColors.manage,
                title: 'Update Listings',
                icon: Icon(
                  color: Colors.black,
                  Icons.update,
                  size: 30.0,
                ),
              ),
              CardButton(
                bgColor: AppColors.manage,
                title: 'Mark House as Booked',
                icon: Icon(
                  color: Colors.black,
                  Icons.calendar_month_outlined,
                  size: 30.0,
                ),
              ),
              CardButton(
                bgColor: AppColors.manage,
                title: 'Delete Listing',
                icon: Icon(
                  color: Colors.black,
                  Icons.delete_outline,
                  size: 30.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
