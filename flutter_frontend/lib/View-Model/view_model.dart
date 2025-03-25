import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/services/firebase_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedNameProvider = StateProvider<String>((ref) => 'Student');
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

Future dialogBox(BuildContext context, String title, String body,
    Future<void> Function() onOkPressed) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 10.0,
      contentPadding: EdgeInsets.all(20.0),
      actionsPadding: EdgeInsets.all(20.0),
      title: Text(title),
      content: Text(body),
      actions: [
        FunctionButton(
            text: 'Cancel',
            onPressed: () {
              Navigator.pop(context);
            },
            btnColor: AppColors.deepBlue),
        FunctionButton(
            text: 'Update',
            onPressed: () async {
              await onOkPressed();
            },
            btnColor: AppColors.deepBlue)
      ],
    ),
  );
}
