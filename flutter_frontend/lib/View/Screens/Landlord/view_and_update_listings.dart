import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/house_card.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ViewAndUpdateListings extends HookConsumerWidget {
  const ViewAndUpdateListings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesProvider = ref.watch(firebaseServices);
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
            future: firebaseServicesProvider.getHouseListing(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50.0,
                  ),
                );
              }
              if (snapshot.data == null) {
                return Center(
                  child: Text('You have no houses'),
                );
              }
              List<Map<String, dynamic>> houses = snapshot.data!;
              return GridView.builder(
                  itemCount: houses.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 300,
                      mainAxisExtent: 300,
                      mainAxisSpacing: 30,
                      crossAxisSpacing: 30),
                  itemBuilder: (context, index) {
                    return HouseCard(
                        houseName: houses[index]['House Name'],
                        price: houses[index]['House Price'].toString(),
                        houseSize: houses[index]['House Size']);
                  });
            }),
      ),
    );
  }
}
