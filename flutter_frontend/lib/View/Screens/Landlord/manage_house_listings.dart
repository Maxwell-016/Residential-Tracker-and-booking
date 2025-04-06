import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/card_button.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';
import '../../Components/landlord_side_nav.dart';

class ManageHouseListings extends ConsumerWidget {


  const ManageHouseListings({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });


  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;







  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Logger logger = Logger();
    final firebaseServicesProvider = ref.watch(firebaseServices);
    return SafeArea(
      child: Scaffold(

        appBar:PreferredSize(
          preferredSize: Size.fromHeight(60),
          child:App_Bar(changeTheme: changeTheme,
              changeColor: changeColor,
              colorSelected: colorSelected,
              title: "Manage House Listings"),
        ),



        drawer: LandlordSideNav(),
        body: SingleChildScrollView(
          child: Padding(
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
                  onTap: ()  {
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
                GestureDetector(
                  onTap: (){
                    context.go('/manageListings/update-house-status');
                  },
                  child: CardButton(
                    bgColor: AppColors.manage,
                    title: 'Mark House as Available',
                    icon: Icon(
                      color: Colors.black,
                      Icons.calendar_month_outlined,
                      size: 30.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
