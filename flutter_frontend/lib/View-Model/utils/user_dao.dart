import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserDao extends ChangeNotifier{
  String errorMessage="Error has occurred";
  final auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore=FirebaseFirestore.instance;


  bool isLoggedIn(){
    return auth.currentUser!=null;
  }

  String? userId(){
    return auth.currentUser?.uid;
  }

  String? email(){
    return auth.currentUser?.email;
  }

  //sign up with role
Future<String?> signUp(String email,String password,String role) async {
    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      await firestore.collection("users").doc(userCredential.user!.uid).set({
        "email":email,
        "role":role,
      });
      notifyListeners();
      return null;

    }on FirebaseAuthException catch (e){
      if(email.isEmpty){
        errorMessage="Email cannot be blank!";
      }else if(password.isEmpty){
        errorMessage='Password is blank.';
      }else if(e.code=="weak-password"){
        errorMessage='The password provided is too weak.';

      }else if(e.code=='email-already-in-use') {
        errorMessage='The account already exists for that email.';
      }
      return errorMessage;



    }catch (e){
      log(e.toString());
      return e.toString();
    }
}

//sign in return null or role adjust
  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await firestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        return 'User role not found.';
      }

      String role = userDoc['role'];

      log('User logged in as: $role');
      notifyListeners();
    //  return null;
      return role;

    } on FirebaseAuthException catch (e) {
      if (email.isEmpty) {
        errorMessage = 'Email is blank.';
      } else if (password.isEmpty) {
        errorMessage = 'Password is blank. Provide correct details';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Invalid email.';
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        errorMessage = 'Invalid credentials.';
      } else if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      }
      return errorMessage;
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }

  Future<String?> getUserRole() async {
    if (auth.currentUser == null) return null;

    DocumentSnapshot userDoc =
    await firestore.collection('users').doc(auth.currentUser!.uid).get();

    if (userDoc.exists) {
      return userDoc['role'];
    }
    return null;
  }



  Future<String?> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        return 'Invalid email address.';
      } else if (e.code == 'user-not-found') {
        return 'No user found with this email.';
      }
      return 'Something went wrong. Please try again.';
    } catch (e) {
      log(e.toString());
      return e.toString();
    }
  }



  Future<void> logout() async {
    await auth.signOut();
    notifyListeners();

  }
}




