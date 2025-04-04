import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Screens/Student/mapit.dart';
import 'package:flutter_frontend/pages/searched_house.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers.dart';

class SearchedPlacesScreen extends ConsumerWidget {
  const SearchedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final searchedPlaces = Future.value(ref.watch(searchedPlacesProvider));





    return Scaffold(
       appBar: AppBar(title: Text("Searched Places")),
// <<<<<<< gamma
//       body: Padding(
//           padding:EdgeInsets.all(16),
//          child: MapScreen(locations: searchedPlaces),
//           )



//       // ListView.builder(
//       //   itemCount: searchedPlaces.length,
//       //   itemBuilder: (context, index) {
//       //     final place = searchedPlaces[index];
//       //     return ListTile(
//       //       title: Text(place),
//       //       subtitle: Text("Tap to check available houses"),
//       //       onTap: () {
//       //         // Navigate to a screen showing houses in this location
//       //         Navigator.push(
//       //           context,
//       //           MaterialPageRoute(builder: (_) => HousesInLocationScreen(place)),
//       //         );
//       //
//       //
//       //
//       //       },
//       //     );
//       //   },
//       // ),



// =======
// //       body: ListView.builder(
// //         itemCount: searchedPlaces.length,
// //         itemBuilder: (context, index) {
// //           final place = searchedPlaces[index];
// //           return ListTile(
// //             title: Text(place),
// //             subtitle: Text("Tap to check available houses"),
// //             onTap: () {
// //               // Navigate to a screen showing houses in this location
// //               Navigator.push(
// //                 context,
// //                 MaterialPageRoute(
// //                     builder: (_) => HousesInLocationScreen(place)),
// //               );
// //             },
// //           );
// //         },
// //       ),
// >>>>>>> main
    );
  }
}

void onSearch(String place, WidgetRef ref) {
  ref.read(searchedPlacesProvider.notifier).addSearchedPlace(place);
}
