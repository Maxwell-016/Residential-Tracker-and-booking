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

final verifiedLandlord = StateProvider<bool>(
    (ref) => FirebaseAuth.instance.currentUser!.emailVerified);

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
  ) async {
    await landlordReference.doc(_auth.currentUser!.uid).set({
      'Name': name,
      'Email': email,
      'Phone Number': phoneNo,
      'Created at': FieldValue.serverTimestamp(),
      'isVerified': _auth.currentUser!.emailVerified,
      'Location': location,
      'Profile Photo': profilePhoto,
    }, SetOptions(merge: true));
  }

  //fetching the landlords details
  Future<Map<String, dynamic>?> getLandlordProfile() async {
    DocumentSnapshot profile =
        await landlordReference.doc(_auth.currentUser!.uid).get();
    if (profile.exists) {
      return profile.data() as Map<String, dynamic>;
    }
    return null;
  }

  bool isAdding = false;
  void setIsAdding(bool value) {
    isAdding = value;
    notifyListeners();
  }

  //Adding house to the database
  Future<String> addHouseListing(
    String name,
    String location,
    double liveLatitude,
    double liveLongitude,
    int price,
    String size,
    List? images,
    String description,
    List? amenities,
    bool isBooked,
  ) async {
    setIsAdding(true);
    DocumentSnapshot houseSnapshot = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .doc(name)
        .get();
    if (houseSnapshot.exists) {
      setIsAdding(false);
      return 'exists';
    } else {
      await landlordReference
          .doc(_auth.currentUser!.uid)
          .collection('Houses')
          .doc(name)
          .set({
        'House Name': name,
        'Location': location,
        'Live Longitude': liveLongitude,
        'Live Latitude': liveLatitude,
        'House Price': price,
        'House Size': size,
        'Images': images,
        'Description': description,
        'Available Amenities': amenities,
        'isBooked': isBooked,
      });
      setIsAdding(false);
      return 'added';
    }
  }

  bool isUpdating = false;
  void setIsUpdating(bool value) {
    isUpdating = value;
    notifyListeners();
  }

  Future<String?> updateListings(
    String name,
    String location,
    int price,
    String size,
    List? images,
    String description,
    List? amenities,
  ) async {
    setIsUpdating(true);
    Map<String, dynamic> previousDetails =
        await getIndividualListing(name) as Map<String, dynamic>;
    if (previousDetails['House Name'] == name &&
            previousDetails['Location'] == location &&
            previousDetails['House Price'] == price &&
            previousDetails['House Size'] == size &&
            previousDetails['Images'] == images &&
            previousDetails['Description'] == description &&
            previousDetails['Available Amenities'] == amenities
        //previousDetails['isBooked'] == isBooked
        ) {
      setIsUpdating(false);
      return 'No Change';
    } else {
      await landlordReference
          .doc(_auth.currentUser!.uid)
          .collection('Houses')
          .doc(name)
          .update({
        'House Name': name,
        'Location': location,
        'House Price': price,
        'House Size': size,
        'Images': images,
        'Description': description,
        'Available Amenities': amenities,
        'isBooked': false,
      });
      notifyListeners();
      setIsUpdating(false);
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

  Future<Map<String, dynamic>?> getSearchedHouse(String name) async {
    QuerySnapshot snapshot = await firestore
        .collection('booked_students')
        .where('houseName', isEqualTo: name)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data() as Map<String, dynamic>;
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
        houses.add({...snapshot.data() as Map<String, dynamic>});
      }
    }
    return houses;
  }

  Future<List<Map<String, dynamic>>> getHouseListingStatus() async {
    QuerySnapshot housesSnapshot = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .where('isBooked', isEqualTo: true)
        .get();
    List<Map<String, dynamic>> houses = [];
    for (var snapshot in housesSnapshot.docs) {
      if (snapshot.exists) {
        bool isBooked = snapshot.get('isBooked') as bool;
        String tenantName = 'Pending';
        if (isBooked) {
          String houseName = snapshot.get('House Name') ?? '';
          QuerySnapshot booked = await firestore
              .collection('booked_students')
              .where('houseName', isEqualTo: houseName)
              .get();
          if (booked.docs.isNotEmpty) {
            tenantName = booked.docs.first.get('name').toString();
          }
          houses.add({
            'tenant': tenantName,
            ...snapshot.data() as Map<String, dynamic>
          });
        }
      }
    }
    return houses;
  }

  Future<int> getNoOfAllHouses() async {
    QuerySnapshot houses = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .get();
    return houses.docs.length;
  }

  Future<int> getNoOfAllBookedHouses() async {
    QuerySnapshot houses = await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .where('isBooked', isEqualTo: true)
        .get();
    return houses.docs.length;
  }

  bool isDeleting = false;
  void setIsDeleting(bool value) {
    isDeleting = value;
    notifyListeners();
  }

  Future<void> deleteDocById(String name) async {
    setIsDeleting(true);
    await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .doc(name)
        .delete();
    setIsDeleting(false);
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> fetchResidences() async {
    try {
      QuerySnapshot snapshot =
          await firestore.collection('booked_students').get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      logger.e('Error fetching residences: $e');
      return [];
    }
  }

  bool isMarkingAvailable = false;

  void setIsMarkingAvailable(bool value) {
    isMarkingAvailable = value;
    notifyListeners();
  }

  Future<void> markRoomAsAvailable(String houseName) async {
    setIsMarkingAvailable(true);

    //delete the record from collection booked_students
    QuerySnapshot bookedHouse = await firestore
        .collection('booked_students')
        .where('houseName', isEqualTo: houseName)
        .get();
    for (var bookedDoc in bookedHouse.docs) {
      await bookedDoc.reference.delete();
      notifyListeners();
    }

    //update the value of isBooked to false
    await landlordReference
        .doc(_auth.currentUser!.uid)
        .collection('Houses')
        .doc(houseName)
        .update({'isBooked': false});
    notifyListeners();
    setIsMarkingAvailable(false);
  }
}
