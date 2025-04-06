import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/SimpleAppBar.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../../constants.dart';
import '../../Components/landlord_side_nav.dart';

class ReviewsAndFeedback extends HookConsumerWidget {
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;
  const ReviewsAndFeedback({
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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: App_Bar(
              changeTheme: changeTheme,
              changeColor: changeColor,
              colorSelected: colorSelected,
              title: "Tenant Feedback"),
        ),
        drawer: LandlordSideNav(),
        body: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('house_feedback')
                .where('landlordId', isEqualTo: landlordId)
                //.orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error fetching feedback. Please try again'),
                );
              }
              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text('No feedback has been received yet'),
                );
              }
              return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> feedback =
                        snapshot.data!.docs[index].data();
                    logger.i(feedback);
                    final timestamp = feedback['timestamp'] as Timestamp;
                    final dateTime = timestamp.toDate();

                    final formatedTime =
                        DateFormat('MMMM d, yyyy - hh:mm a').format(dateTime);
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(feedback['email'].toString()),
                        horizontalTitleGap: 30.0,
                        subtitle: Text(
                          feedback['feedback'],
                          maxLines: 20,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          formatedTime.toString(),
                        ),
                        isThreeLine: true,
                      ),
                    );
                  });
            }),
      ),
    );
  }
}

