import 'package:flutter/material.dart';

class TitleOverlayScreen extends StatelessWidget {
  const TitleOverlayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          SizedBox.expand(
            child: Image.asset(
              'assets/launch.png',
              fit: BoxFit.cover,
            ),
          ),

          Container(
            color: Colors.black.withOpacity(0.2),
          ),
          // Centered Title Text
          Center(
            child: Text(
              'Residential-Tracker-and-booking',
              textAlign: TextAlign.start,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
                shadows: [
                  Shadow(
                    blurRadius: 18,
                    color: Colors.black,
                    offset: Offset(8, 8),
                  ),
                ],
              ),
            ),


          ),
        ],
      ),
    );
  }
}
