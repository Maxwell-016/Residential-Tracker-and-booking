import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';

class CardButton extends StatelessWidget {
  final int? quantity;
  final Color bgColor;
  final String title;
  final Icon? icon;
  const CardButton({super.key,this.quantity, required this.bgColor, required this.title, this.icon});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    double deviceWidth = MediaQuery.of(context).size.width;
    double width = deviceWidth > 800? deviceWidth / 2.5 : deviceWidth / 1.5;
    return SizedBox(
      width: width,
      child: Card(
        elevation: 5.0,
        shadowColor: isDark? Colors.white: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Column(
            spacing: 30.0,
            children: [
              SizedBox(),
              CircleAvatar(
                radius: 40.0,
                backgroundColor: bgColor,
                child: Center(
                  child: icon ?? Icon(Icons.bar_chart,size: 30.0,),
                ),
              ),
              quantity != null? UseFont(text: '$quantity houses', myFont: 'Open Sans', size: 20.0): SizedBox(),
              UseFont(text: title, myFont: 'Open Sans', size: 20.0),
              SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
