import 'package:flutter/material.dart';

import 'google_fonts.dart';

class SnackBars {
  static showSuccessSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      content: ShowMessage(
        text: text,
        color: Colors.green,
        icon: const Icon(
          Icons.check_circle_outline,
          color: Colors.white,
        ),
      ),
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 205,
        left: 10,
        right: 10,
      ),
    ));
  }

  static showErrorSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      content: Container(
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ShowMessage(
                text: text,
                color: Colors.red,
                icon: const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                  icon: Icon(Icons.cancel_outlined)),
            )
          ],
        ),
      ),
      duration: const Duration(seconds: 10),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 170,
        left: 10,
        right: 10,
      ),
    ));
  }

  static showInfoSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      elevation: 0,
      content: ShowMessage(
        text: text,
        color: Colors.blueAccent,
        icon: const Icon(
          Icons.message_outlined,
          color: Colors.white,
        ),
      ),
      duration: const Duration(seconds: 5),
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: MediaQuery.of(context).size.height - 205,
        left: 5,
        right: 5,
      ),
    ));
  }
}

class ShowMessage extends StatelessWidget {
  final String text;
  final Color color;
  final Icon icon;
  const ShowMessage({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: UseFont(
                    text: text,
                    myFont: "Open Sans",
                    size: 15.0,
                  ),
      ),
    );
  }
}
