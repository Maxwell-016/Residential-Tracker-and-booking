import 'dart:html' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';

Future<void> trigernotification(BuildContext context,  String body,String title) async {
  if (html.Notification.supported) {
    if (html.Notification.permission == 'granted') {
      html.Notification(
        title,
        body: body,
        icon:
        'https://res.cloudinary.com/dk10knkfh/image/upload/v1743967762/file-1743967737959_ww5yf3.png',
      );
    } else {
    SnackBars.showErrorSnackBar(context, "Kindly allow notification permission to avoid missing important notifications");
    }
      } else {
        print("Browser does not support notifications");
      }
    }



