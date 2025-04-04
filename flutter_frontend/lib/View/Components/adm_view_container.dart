// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class admViewContainer extends ConsumerStatefulWidget {
//   final String locationName;
//   final int studentCount;
//   final VoidCallback onTap;
//   const admViewContainer(
//       {super.key,
//       required this.locationName,
//       required this.studentCount,
//       required this.onTap});

//  @override
//   ConsumerState<admViewContainer> createState() => _adminViewContainer();
// }

// class _adminViewContainer extends ConsumerState<admViewContainer> {
//     Future<List<Map<String, dynamic>>> fetchLocations() async {
//     QuerySnapshot snapshot =
//         await FirebaseFirestore.instance.collection('locations').get();

//     return snapshot.docs.map((doc) {
//       return {
//         'name': doc['name'] ?? 'Unknown',
//         'students': doc['students'] ?? 0,
//       };
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold( 
//    children: [
//       GestureDetector(
//         onTap: onTap,
//         child: Container(
//           margin: EdgeInsets.only(bottom: 20.0),
//           width: double.infinity,
//           height: 100.0,
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Center(
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(locationName,
//                     style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold)),
//                 SizedBox(height: 5),
//                 Text('No of students: $studentCount',
//                     style: TextStyle(color: Colors.white, fontSize: 16)),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ],
//     ),
//     );
//   }
// }

