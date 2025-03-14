import 'package:flutter/material.dart';

class LinkButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  const LinkButton({super.key, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
     onPressed: onPressed, 
     child: Text(text,style: TextStyle(color: Colors.blue),),
    );
  }
}