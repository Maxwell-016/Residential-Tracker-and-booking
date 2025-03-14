import 'package:flutter/material.dart';

class FunctionButton extends StatelessWidget {
  final String text;
  final Color? textColor;
  final VoidCallback onPressed;
  final Color btnColor;
  final double? width;
  const FunctionButton(
      {super.key,
      required this.text,
      required this.onPressed,
      required this.btnColor,
      this.textColor,
      this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: SizedBox(
        width:width ?? double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: btnColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.all(10.0),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}
