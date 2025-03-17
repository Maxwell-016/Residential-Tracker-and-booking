import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final viewModel =
    ChangeNotifierProvider.autoDispose<ViewModel>((ref) => ViewModel());

class ViewModel extends ChangeNotifier {
  bool isObscured = true;
  bool showResendBtn = true;

  void toggleObscured() {
    isObscured = !isObscured;
    notifyListeners();
  }

  int timeLeft = 50;
  void startTimer() {
    showResendBtn = false;
    Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft--;
      notifyListeners();
      if (timeLeft == 0) {
        showResendBtn = true;
        notifyListeners();
        timer.cancel();
        timeLeft = 50;
      }
    });
  }
}
