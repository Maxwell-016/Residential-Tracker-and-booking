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

class FirebaseServices extends ChangeNotifier {
  Logger logger = Logger();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference houseReference =
      FirebaseFirestore.instance.collection('Houses');

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

    _auth.currentUser!.sendEmailVerification();

    await firestore.collection("users").doc(_auth.currentUser!.uid).set({
      "email": email,
      "role": role,
    });

    // viewModelProvider.startTimer();

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
      sendEmailVerification();
      viewModelProvider.startTimer();
      if (!context.mounted) return;
      context.go('/verification');
      saveCurrentPage("/verification");
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
    Future.microtask(() {
      if (!context.mounted) return;
      Navigator.of(context).pushReplacementNamed('/login');
    });
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

  //Adding house to the database
  Future<void> addHouseListing(
    String name,
    int price,
    String size,
    List? images,
    String description,
    List? amenities,
  ) async {
    await houseReference
        .doc(_auth.currentUser!.uid)
        .collection('House Details')
        .add({
      'House Name': name,
      'House Price': price,
      'House Size': size,
      'Images': images,
      'Description': description,
      'Available Amenities': amenities
    });
  }

  Future<String?> updateListings(
    String id,
    String name,
    int price,
    String size,
    List? images,
    String description,
    List? amenities,
  ) async {
    Map<String, dynamic> previousDetails =
        await getIndividualListing(id) as Map<String, dynamic>;
    if (previousDetails['House Name'] == name &&
        previousDetails['House Price'] == price &&
        previousDetails['House Size'] == size &&
        previousDetails['Images'] == images &&
        previousDetails['Description'] == description &&
        previousDetails['Available Amenities'] == amenities) {
      return 'No Change';
    } else {
      await houseReference
          .doc(_auth.currentUser!.uid)
          .collection('House Details')
          .doc(id)
          .update({
        'House Name': name,
        'House Price': price,
        'House Size': size,
        'Images': images,
        'Description': description,
        'Available Amenities': amenities
      });
      return null;
    }
  }

  Future<Object?> getIndividualListing(String id) async {
    DocumentSnapshot snapshot = await houseReference
        .doc(_auth.currentUser!.uid)
        .collection('House Details')
        .doc(id)
        .get();
    if (snapshot.exists) {
      return snapshot.data();
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> getHouseListing() async {
    QuerySnapshot housesSnapshot = await houseReference
        .doc(_auth.currentUser!.uid)
        .collection('House Details')
        .get();
    List<Map<String, dynamic>> houses = [];
    for (var snapshot in housesSnapshot.docs) {
      if (snapshot.exists) {
        houses.add(
            {'Id': snapshot.id, ...snapshot.data() as Map<String, dynamic>});
      }
    }
    return houses;
  }

  Future<void> deleteDocById(String id) async {
    await houseReference
        .doc(_auth.currentUser!.uid)
        .collection('House Details')
        .doc(id)
        .delete();
  }
}
