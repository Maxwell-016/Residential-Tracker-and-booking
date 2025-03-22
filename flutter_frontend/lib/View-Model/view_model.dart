import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



final selectedNameProvider = StateProvider<String>((ref)=>'Student');
final selectedHouseSize = StateProvider<String>((ref) => 'Single');


final viewModel =
    ChangeNotifierProvider.autoDispose<ViewModel>((ref) => ViewModel());

class ViewModel extends ChangeNotifier {
  bool isObscured = true;
  bool showResendBtn = false;

  void toggleObscured() {
    isObscured = !isObscured;
    notifyListeners();
  }

  int timeLeft = 15;
  void startTimer() {
    showResendBtn = false;
    Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft--;
      notifyListeners();
      if (timeLeft == 0) {
        showResendBtn = true;
        notifyListeners();
        timer.cancel();
        timeLeft = 15;
      }
    });
  }
}
