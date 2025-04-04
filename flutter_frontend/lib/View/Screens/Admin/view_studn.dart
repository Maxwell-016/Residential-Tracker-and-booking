import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_frontend/View/Components/SimpleAppBar.dart';
import 'package:flutter_frontend/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class ViewStudentdt extends ConsumerStatefulWidget {
  const ViewStudentdt({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });

  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  @override
  ConsumerState<ViewStudentdt> createState() => _ViewStudentdata();
}

class _ViewStudentdata extends ConsumerState<ViewStudentdt> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final Logger logger = Logger();

  /// Fetches location data from Firebase Firestore
  Future<List<Map<String, dynamic>>> fetchLocations() async {
    QuerySnapshot snapshot = await firestore.collection('locations').get();
    return snapshot.docs.map((doc) {
      return {
        'name': doc['name'] ?? 'Unknown',
        'students': doc['students'] ?? 0,
      };
    }).toList();
  }

  /// Widget to display each location as a card
  Widget locationCard(Map<String, dynamic> location, int index) {
    return GestureDetector(
      onTap: () {
        logger.i("Clicked on ${location['name']}");
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              location['name'],
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 5),
            Text(
              "No of students: ${location['students']}",
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    logger.i('Fetching locations from Firebase');

    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: App_Bar(
              changeTheme: widget.changeTheme,
              changeColor: widget.changeColor,
              colorSelected: widget.colorSelected,
              title: "View Student Data"),
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchLocations(), // CALLING fetchLocations() here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text("Error loading data"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("No data available"));
            }

            var locations = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                children: List.generate(locations.length, (index) {
                  return locationCard(
                      locations[index], index); // CALLING locationCard() here
                }),
              ),
            );
          },
        ),
      ),
    );
  }
}


// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter_frontend/View/Components/SimpleAppBar.dart';
// import 'package:flutter_frontend/constants.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:logger/logger.dart';



// }

//   final FirebaseFirestore firestore = FirebaseFirestore.instance;
//   final Logger logger = Logger();

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     logger.i('Fetching locations from Firebase');
//     return SafeArea(
//       child: Scaffold(
//         appBar: PreferredSize(
//           preferredSize: Size.fromHeight(60),
//           child: App_Bar(
//               changeTheme: widget.changeTheme,
//               changeColor: widget.changeColor,
//               colorSelected: widget.colorSelected,
//               title: "view student data"),
//         ),
//         body: FutureBuilder<List<Map<String, dynamic>>>(
//           future: fetchLocations(),
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             if (snapshot.hasError) {
//               return const Center(child: Text("Error loading data"));
//             }
//             if (!snapshot.hasData || snapshot.data!.isEmpty) {
//               return const Center(child: Text("No data available"));
//             }

//             var locations = snapshot.data!;
//             return SingleChildScrollView(
//               child: Column(
//                 children: List.generate(locations.length, (index) {
//                   return locationCard(locations[index], index);
//                 }),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }

//   Future<List<Map<String, dynamic>>> fetchLocations() async {
//     QuerySnapshot snapshot = await firestore.collection('locations').get();
//     return snapshot.docs.map((doc) {
//       return {
//         'name': doc['name'] ?? 'Unknown',
//         'students': doc['students'] ?? 0,
//       };
//     }).toList();
//   }

//   Widget locationCard(Map<String, dynamic> location, int index) {
//     return GestureDetector(
//       onTap: () {
//         logger.i("Clicked on ${location['name']}");
//         // Handle click action here
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.black54,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               location['name'],
//               style: const TextStyle(color: Colors.white, fontSize: 18),
//             ),
//             const SizedBox(height: 5),
//             Text(
//               "No of students: ${location['students']}",
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
