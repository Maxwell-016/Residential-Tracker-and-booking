// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter_frontend/View/Components/individual_bar.dart';
// import 'package:flutter_frontend/services/firebase_services.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

// class barData {
//   final int NumberOfStudents;

//   barData(
//     this.NumberOfStudents,
//   );

//   List<indivudualBar> BarData = List.empty();
//   void initializeBarData() {
//     {
//       indivudualBar;
//       {
//         (x: 0, y: NumberOfStudents);
//         ;
//       }
//     }
//   }
// }

// class StudentNumber {

//   final FirebaseServices firebaseServices = FirebaseServices();
//   List<Map<String, dynamic>> studentNo = [];
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchStudentsNo();
//   }

//   Future<void> fetchStudentsNo() async {
//     try {
//       final data = await firebaseServices.fetchResidences();
//       setState(() {
//         studentNo = data;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//     }
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('There is no student booking yet: &e')),
//     );
//   }
// }

// void setState(Null Function() param0) {
// }
