import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UseFont extends StatelessWidget {
  final String text;
  final String myFont;
  final double size;
  final FontWeight? weight;
  final Color? color;
  const UseFont({super.key, required this.text, required this.myFont, required this.size, this.weight, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.getFont(
        myFont,
        fontSize: size,
        fontWeight: weight ?? FontWeight.normal,
        color: color,
      ),
      softWrap: true,
    );
  }
}