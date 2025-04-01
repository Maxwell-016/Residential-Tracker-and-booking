
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HousesInLocationScreen extends ConsumerWidget {
  final String location;

  HousesInLocationScreen(this.location);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text("Houses in $location")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('houses')
            .where('location', isEqualTo: location)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final houses = snapshot.data!.docs;
          if (houses.isEmpty) {
            return Center(child: Text("No houses available in $location."));
          }

          return ListView.builder(
            itemCount: houses.length,
            itemBuilder: (context, index) {
              final house = houses[index];
              return ListTile(
                title: Text(house['name']),
                subtitle: Text("Price: \$${house['price']}"),
              );
            },
          );
        },
      ),
    );
  }
}
