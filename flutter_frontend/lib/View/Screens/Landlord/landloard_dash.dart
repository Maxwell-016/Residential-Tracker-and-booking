import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/card_button.dart';
import 'package:flutter_frontend/View/Components/landlord_side_nav.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';

import '../../../services/firebase_services.dart';
import '../../Components/SimpleAppBar.dart';
import '../../Components/color_button.dart';
import '../../Components/theme_button.dart';


class LandLordDashboardScreen extends ConsumerStatefulWidget {
  const LandLordDashboardScreen({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });


  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;


  @override
  ConsumerState<LandLordDashboardScreen> createState() => _LandLordDashboardScreenState();
}

class _LandLordDashboardScreenState extends ConsumerState<LandLordDashboardScreen> {

  late Future<Map<String,int>> _houseDataFuture;

  FirebaseServices firebaseService = FirebaseServices();
  @override
  void initState() {
    super.initState();
    _houseDataFuture = _fetchHouseData();
  }
  Future<Map<String,int>> _fetchHouseData() async{
    final total = await firebaseService.getNoOfAllHouses();
    final booked = await firebaseService.getNoOfAllBookedHouses();
    final notBooked = total - booked;
    return {'total' : total, 'booked' : booked, 'notBooked' : notBooked};
  }


  @override
  Widget build(BuildContext context) {
    final fb= ref.watch(firebaseServices);



    Logger logger = Logger();
    logger.i('Rebuilding admin dash');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Scaffold(

        appBar:PreferredSize(
            preferredSize: Size.fromHeight(60),
            child:App_Bar(changeTheme: widget.changeTheme, changeColor: widget.changeColor, colorSelected: widget.colorSelected, title: "Landlord Dashboard"),
        ),


        drawer: LandlordSideNav(),
        body: FutureBuilder(
          future:  _houseDataFuture,
          builder: (context,snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }
            if(snapshot.hasError){
              return Center(child: Text('Error loading data. Check your connection and try again'),);
            }
            final data = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 100.0),
                child: Wrap(
                  spacing: 40.0,
                  runSpacing: 40.0,
                  children: [
                    // display
                    CardButton(
                        quantity: data['total'],
                        bgColor: AppColors.totalListings,
                        title: 'Total Listings'),
                    CardButton(
                        quantity: data['booked'],
                        bgColor: AppColors.booked,
                        title: 'Booked Houses'),
                    CardButton(
                        quantity: data['notBooked'],
                        bgColor: AppColors.availableListings,
                        title: 'Available Houses'),
                  ],
                ),
              ),
            );

          },
        ),
      ),
    );
  }
}
