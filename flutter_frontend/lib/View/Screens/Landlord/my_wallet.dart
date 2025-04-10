
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_frontend/View/Components/landlord_side_nav.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class MyWallet extends HookConsumerWidget{
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  const MyWallet({super.key, required this.colorSelected, required this.changeTheme,required this.changeColor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger logger = Logger();
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    return SafeArea(child: Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: App_Bar(
            changeTheme: changeTheme,
            changeColor: changeColor,
            colorSelected: colorSelected,
            title: "Wallet"),
      ),
      drawer: LandlordSideNav(),
      body: Center(
        child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Landlords').doc(FirebaseAuth.instance.currentUser!.uid).collection('Houses').where('isBooked', isEqualTo: true).snapshots(),
            builder: (context,snapshots){
              if(snapshots.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              if(snapshots.hasError){
                return Center(child: Text('An error occurred fetching payments.Please try again.'),);
              }

              final houses = snapshots.data!.docs;
              double price = 0.0;
              for(int i = 0; i < houses.length; i++){
                price += houses[i].data()['House Price'];
                logger.i(price);
              }

              return Center(
                child: SizedBox(
                  width: deviceWidth / 1.5,
                  height: deviceHeight / 2,
                  child: Card(
                  color: CupertinoColors.activeGreen,
                  elevation: 5.0,
                  child: Stack(
                    children:[ Center(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          spacing: 30.0,
                          children: [
                            Row(
                              spacing: 40.0,
                              children: [
                                Icon(Icons.monetization_on,color:  Color(0xFFFFD700),size: 24.0,),
                                UseFont(text: 'My Wallet', myFont: 'Open Sans', size: 25.0),
                              ],
                            ),
                            Divider(),
                            UseFont(text: 'Total Amount Paid', myFont: 'Open Sans', size: 24.0),
                            UseFont(text: 'Ksh.$price.00', myFont: 'Roboto', size: 22.0),
                          ],
                        ),
                      ),
                    ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.greenAccent
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Icon(Icons.wallet, size: 30.0, color: Color(0xFFFFD700),),
                            ),
                          ),
                        ),
                      )
                ]
                  ),
                                ),
                ),);
            }),
      ),
    ),);
  }

}
