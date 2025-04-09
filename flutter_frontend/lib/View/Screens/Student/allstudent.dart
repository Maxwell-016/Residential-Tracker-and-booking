import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';



import '../../Components/admin_side_nav.dart';
import '../Admin/locateAllStudents.dart';
import 'mapscreen.dart';

class AllBookedHousesMap extends StatelessWidget {
  const AllBookedHousesMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AdminSideNav(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection("booked_students").snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No booked houses found."));
          }

          List<Map<String, dynamic>> houses = [];

          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;

            if (data.containsKey('lat') && data.containsKey('long')) {
              houses.add({
                "name":data["name"],
                "email":data["email"],
                "landlordName":data["landlord"],
                "lphn":data["landlordContact"],
                "sphn":data["stdContact"],
                "houseName": data['houseName'],
                "lat": data['lat'],
                "long": data['long'],
                "image": data['images'] != null && data['images'].isNotEmpty ? data['images'][0] : "",
                "location": data['houseLocation'],
              });
            }
          }

          return AllBookedHouses(title: "Booked Houses Map", houses: houses);
        },
      ),
    );
  }
}
