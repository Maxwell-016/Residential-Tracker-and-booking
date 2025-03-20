
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  final FirebaseFirestore firestore=FirebaseFirestore.instance;

  User? get isLoggedIn => _auth.currentUser;

  bool isLoading = false;
  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }
  //Creating a user on first time registration
  Future<void> createUser(BuildContext context, WidgetRef ref, String email,
      String password,String role) async {
    final viewModelProvider = ref.watch(viewModel);
    setIsLoading(true);
    await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    _auth.currentUser!.sendEmailVerification();
    await firestore.collection("users").doc(_auth.currentUser!.uid).set({
        "email":email,
        "role":role,
      });
    viewModelProvider.startTimer();
    if (!context.mounted) return;
    context.go('/verification');
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
      if(role != null){
        switch(role){
          case 'Student':
            if(!context.mounted)return;
            context.go('/student-dashboard');
            break;
          case 'Landlord':
            if(!context.mounted)return;
            context.go('/landlord-dashboard');
            break;
          case 'Admin':
            if(!context.mounted)return;
            context.go('/admin-dashboard');
            break;
        }
      }else{
        logger.i(role);
      }
    } else {
      //go to email verification page
      sendEmailVerification();
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

  //Google sign in
  // Future<void> googleSignIn(BuildContext context) async {
  //   final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  //   final GoogleSignInAuthentication? googleAuth =
  //   await googleUser?.authentication;
  //   final credential = GoogleAuthProvider.credential(
  //     idToken: googleAuth?.idToken,
  //     accessToken: googleAuth?.accessToken,
  //   );
  //   await _auth.signInWithCredential(credential);
  //   if (!context.mounted) return;
  //   logger.i(_auth.currentUser);
  //   Navigator.of(context).pushReplacementNamed('/landing');
  // }

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
}


