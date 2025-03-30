import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/card_button.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../Components/landlord_side_nav.dart';

class ManageHouseListings extends HookConsumerWidget {
  const ManageHouseListings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Logger logger = Logger();
    final firebaseServicesProvider = ref.watch(firebaseServices);
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
        drawer: LandlordSideNav(),
        body: Padding(
          padding: const EdgeInsets.only(left: 100.0),
          child: Wrap(
            spacing: 40.0,
            runSpacing: 40.0,
            children: [
              GestureDetector(
                onTap: () {
                  context.go('/manageListings/add-house');
                },
                child: CardButton(
                  bgColor: AppColors.manage,
                  title: 'Add House',
                  icon: Icon(
                    color: Colors.black,
                    Icons.add_circle_outline_outlined,
                    size: 30.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  context.go('/manageListings/view-and-update-listings');
                },
                child: CardButton(
                  bgColor: AppColors.manage,
                  title: 'View / Update Listings',
                  icon: Icon(
                    color: Colors.black,
                    Icons.update,
                    size: 30.0,
                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}
