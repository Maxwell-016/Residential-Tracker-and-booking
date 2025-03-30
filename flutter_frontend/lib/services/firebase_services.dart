import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/savecurrentpage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';


import '../View-Model/view_model.dart';

final firebaseServices =
    ChangeNotifierProvider<FirebaseServices>((ref) => FirebaseServices());
final userState =
    StateProvider<User?>((ref) => FirebaseAuth.instance.currentUser);

final verifiedLandlord = StateProvider<bool>((ref) => FirebaseAuth.instance.currentUser!.emailVerified);

class FirebaseServices extends ChangeNotifier {
  Logger logger = Logger();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference landlordReference =
  FirebaseFirestore.instance.collection('Landlords');

  User? get isLoggedIn => _auth.currentUser;

  bool isLoading = false;

  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  bool loggedIn() {
    return _auth.currentUser != null;
  }

  //Creating a user on first time registration
  Future<void> createUser(BuildContext context, WidgetRef ref, String email,
      String password, String role) async {
    final viewModelProvider = ref.watch(viewModel);
    setIsLoading(true);
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    await _auth.currentUser!.sendEmailVerification();

    await firestore.collection("users").doc(_auth.currentUser!.uid).set({
      "email": email,
      "role": role,
    });

     viewModelProvider.startTimer();

    if (!context.mounted) return;
    context.go('/verification');
    saveCurrentPage("/verification");
  }

  //Signing in a user
  Future<void> signIn(BuildContext context, WidgetRef ref, String email,
      String password) async {
    final viewModelProvider = ref.watch(viewModel);
    setIsLoading(true);
    await _auth.signInWithEmailAndPassword(email: email, password: password);
    if (_auth.currentUser!.emailVerified) {
      await _auth.setPersistence(Persistence.LOCAL);

      String? role = await getUserRole();
      logger.i('user role : $role');
      //go to dashboards
      if (role != null) {
        switch (role) {
          case 'Student':
            if (!context.mounted) return;

            context.go('/student-dashboard');

            break;
          case 'Landlord':
            if (!context.mounted) return;

            context.go('/landlord-dashboard');

            break;
          case 'Admin':
            if (!context.mounted) return;
            context.go('/admin-dashboard');

            break;
        }
      } else {
        logger.i(role);
      }
    } else {
      //go to email verification page
      await _auth.currentUser!.sendEmailVerification();
   //   sendEmailVerification();
      viewModelProvider.startTimer();
      if (!context.mounted) return;
      context.go('/verification');

    }
  }

  Future<String?> getUserRole() async {
    if (_auth.currentUser == null) return null;

    DocumentSnapshot userDoc =
    await firestore.collection('users').doc(_auth.currentUser!.uid).get();

    if (userDoc.exists) {
      return userDoc['role'];
    }
    return null;
  }

  //reset users password
  Future<void> resetPassword(email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  //sign out of the app
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    // await GoogleSignIn().signOut();
    // Future.microtask(() {
    //   if (!context.mounted) return;
    //   Navigator.of(context).pushReplacementNamed('/login');
    // });
  }

  //email verification
  Future<void> sendEmailVerification() async {
    await _auth.currentUser!.sendEmailVerification();
  }

  //handles errors during authentication
  String handleFirebaseAuthErrors(FirebaseAuthException e) {
    final errorMessages = {
      // Sign In User Errors
      'invalid-email': "The email address is badly formatted.",
      'user-not-found': "No user found with this email address.",
      'wrong-password': "The password is incorrect.",
      'invalid-credential':
      "Incorrect credentials. Check your email and password and try again or sign up if you don't have an account",
      'too-many-requests': "Too many attempts. Try again later.",
      'operation-not-allowed': "This operation is not allowed.",
      'network-request-failed': "Network error. Check your connection.",

      // Create User Errors
      'email-already-in-use':
      "The email address is already in use by another account.",
      'weak-password':
      "The password is too weak. It must be at least 8 characters long.",
      'user-disabled': "This account has been disabled by the administrator.",

      // Generic Errors
      'internal-error': "An internal error occurred. Please try again later.",
      'timeout':
      "The request has timed out. Please check your internet connection.",
      'unknown': "An unknown error occurred. Please try again.",
    };
    String message =
        errorMessages[e.code] ?? "An unknown error occurred. Please try again.";
    return message;
  }

  //landlords Profile

  Future<void> createLandlordProfile(
      WidgetRef ref,
      String name,
      String email,
      String phoneNo,
      String location,
      String? profilePhoto,
      )async{
    await landlordReference.doc(_auth.currentUser!.uid).set({
      'Name' : name,
      'Email' : email,
      'Phone Number' : phoneNo,
      'Created at' : FieldValue.serverTimestamp(),
      'isVerified' : _auth.currentUser!.emailVerified,
      'Location' : location,
      'Profile Photo' : profilePhoto,
    },SetOptions(merge: true));
  }

  //fetching the landlords details
  Future<Map<String, dynamic>?> getLandlordProfile() async {
    DocumentSnapshot profile = await landlordReference.doc(
        _auth.currentUser!.uid).get();
    if (profile.exists) {
      return profile.data() as Map<String, dynamic>;
    }
    return null;
  }
  //Adding house to the database
  Future<String> addHouseListing(
      String name,
      String location,
      int price,
      String size,
      List? images,
      String description,
      List? amenities,
      bool isBooked,
      ) async {
    DocumentSnapshot houseSnapshot = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses').doc(name).get();
    if(houseSnapshot.exists){
      return 'exists';
    }
    else {
      await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses').doc(name)
        .set({
      'House Name': name,
      'Location' : location,
      'House Price': price,
      'House Size': size,
      'Images': images,
      'Description': description,
      'Available Amenities': amenities,
      'isBooked' : isBooked,
    });
      return 'added';
    }
  }

  Future<String?> updateListings(
      String name,
      String location,
      int price,
      String size,
      List? images,
      String description,
      List? amenities,
      bool isBooked,
      ) async {
    Map<String, dynamic> previousDetails =
    await getIndividualListing(name) as Map<String, dynamic>;
    if (previousDetails['House Name'] == name &&
        previousDetails['Location'] == location&&
        previousDetails['House Price'] == price &&
        previousDetails['House Size'] == size &&
        previousDetails['Images'] == images &&
        previousDetails['Description'] == description &&
        previousDetails['Available Amenities'] == amenities &&
    previousDetails['isBooked'] == isBooked
    ) {
      return 'No Change';
    } else {
      await landlordReference
          .doc(_auth.currentUser!.uid)
          .collection('Houses')
          .doc(name)
          .update({
        'House Name': name,
        'Location' : location,
        'House Price': price,
        'House Size': size,
        'Images': images,
        'Description': description,
        'Available Amenities': amenities,
        'isBooked' : isBooked,
      });
      return null;
    }
  }

  Future<Object?> getIndividualListing(String name) async {
    DocumentSnapshot snapshot = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .doc(name)
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHouseListing() async {
    QuerySnapshot housesSnapshot = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .get();
    List<Map<String, dynamic>> houses = [];
    for (var snapshot in housesSnapshot.docs) {
      if (snapshot.exists) {
        houses.add(
            {...snapshot.data() as Map<String, dynamic>});
      }
    }
    return houses;
  }

  Future<void> deleteDocById(String name) async {
    await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .doc(name)
        .delete();
  }




//   Future<Map<String,dynamic>> getAllHouses(
//       {DocumentSnapshot? lastLandlordDoc,
//         Map<String, DocumentSnapshot>? lastHouseDocs,
//         int perLandlordLimit = 4,
//         int totalLimit = 20}) async {

//     Query landlordsQuery = FirebaseFirestore.instance.collection('Houses').orderBy(FieldPath.documentId).limit(totalLimit );

//     if(lastLandlordDoc != null){
//       landlordsQuery = landlordsQuery.startAfterDocument(lastLandlordDoc);
//     }

//     QuerySnapshot landlords = await landlordsQuery.get();

//     List<Map<String, dynamic>> allHouses = [];
//     DocumentSnapshot? newLastLandlordDoc ;
//     Map<String, DocumentSnapshot>? newLastHouseDocs = {};
//     logger.e(landlords.docs.length);
//     for(var landlordDoc in landlords.docs){

//       Query houseQuery = landlordDoc.reference.collection('House Details').orderBy(FieldPath.documentId).limit(perLandlordLimit);
//       if(lastHouseDocs != null && lastHouseDocs.containsKey(landlordDoc.id)){
//         houseQuery = houseQuery.startAfterDocument(lastHouseDocs[landlordDoc.id]!);
//       }

//       QuerySnapshot houses = await houseQuery.get();

//       for(var houseDoc in houses.docs){
//         allHouses.add({
//           'id' : houseDoc.id,
//           'landlordId' : landlordDoc.id,
//           ...houseDoc.data() as Map<String,dynamic>
//         });
//         newLastHouseDocs[landlordDoc.id] = houseDoc;
//       }
//       newLastLandlordDoc = landlordDoc;
//     }
//     return{
//       'houses' : allHouses,
//       'lastLandlordDoc' : newLastLandlordDoc,
//       'lastHouseDocs' : newLastHouseDocs,
//     };




    // QuerySnapshot houses = await houseReference.get();
    // List<Map<String, dynamic>> allTheHouses = [];
    // DocumentSnapshot? lastDocumentSnapshot;
    //
    // for (var allHouses in houses.docs) {
    //   Query query = allHouses.reference.collection('House Details').limit(
    //       limit);
    //   if (lastDoc != null) {
    //     query = query.startAfterDocument(lastDoc);
    //   }
    //
    //   QuerySnapshot landlordHouse = await query.get();
    //
    //   for (var snapshot in landlordHouse.docs) {
    //     if (snapshot.exists) {
    //       logger.i('Snapshot id = ${snapshot.id}');
    //       allTheHouses.add({
    //         'Id': snapshot.id, ...snapshot.data() as Map<String, dynamic>
    //       });
    //     }
    //     if(landlordHouse.docs.isNotEmpty){
    //       lastDocumentSnapshot = landlordHouse.docs.last;
    //   }
    //
    //   }
    // }
    // logger.i('From get all houses: $allTheHouses');
    // return {'houses' : allTheHouses, 'lastDoc' : lastDocumentSnapshot};



  Future<List<Map<String, dynamic>>> fetchResidences() async {
  try{
    QuerySnapshot snapshot = await this.firestore.collection('booked_students').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  } catch(e){
    this.logger.e('Error fetching residences: $e');
    return [];
  }
}
}



