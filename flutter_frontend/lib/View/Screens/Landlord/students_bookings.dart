import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/landlord_side_nav.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../Components/SimpleAppBar.dart';

class StudentsBookings extends HookConsumerWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  const StudentsBookings({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String landlordId = FirebaseAuth.instance.currentUser!.uid;
    Logger logger = Logger();
    return SafeArea(
      child: Scaffold(
        drawer: LandlordSideNav(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: App_Bar(
              changeTheme: changeTheme,
              changeColor: changeColor,
              colorSelected: colorSelected,
              title: "Student Bookings"),
        ),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('booked_students').where('landlordId', isEqualTo: landlordId).snapshots(),
            builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(child: CircularProgressIndicator(),);
              }
              if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                return Center(child: Text('You have no booked houses currently'),);
              }

              var bookings = snapshot.data!.docs;
              logger.i(bookings);
              return ListView.builder(
                itemCount: bookings.length,
                  itemBuilder: (context, index){
                    var booking = bookings[index].data();
                    logger.i(booking);
                    return Card(
                      child: ListTile(
                        leading: booking['house_images'] != null ?
                        Image.network(
                          booking['house_images'][0],
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.cover,
                        ) : Icon(Icons.home_outlined),

                        contentPadding: EdgeInsets.all(10.0),
                        title: Text('House ${booking['houseName']}'),
                        subtitle: Column(
                          spacing: 10.0,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Student: ${booking['name']}'),
                            Text('Amount Ksh.${booking['amount_paid']}'),
                            Text('Payment status: ${booking['payment_status']}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: (){
                          logger.i('show more details');
                        },
                      ),
                    );
                  });
            }),
      ),
    );
  }
}
