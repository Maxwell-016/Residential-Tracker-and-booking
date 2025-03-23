import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';

class HouseCard extends StatelessWidget {
  final String houseName;
  final String price;
  final String houseSize;
  final String? imageUrl;
  const HouseCard(
      {super.key,
      required this.houseName,
      required this.price,
      required this.houseSize,
      this.imageUrl});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color shadowColor = isDark ? Colors.white : Colors.black;
    return Card(
      elevation: 5.0,
      shadowColor: shadowColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          imageUrl == null
              ? Image.asset(
                  'assets/launch.png',
                  height: 200.0,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.high,
                )
              : CachedNetworkImage(
                  imageUrl: imageUrl!,
                  height: 200.0,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.fill,
                ),
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UseFont(
                  text: houseName,
                  myFont: 'Open Sans',
                  size: 14.0,
                  weight: FontWeight.bold,
                ),
                UseFont(text: houseSize, myFont: 'Open Sans', size: 12.0),
                Divider(),
                UseFont(
                  text: 'Ksh.$price',
                  myFont: 'Roboto',
                  size: 16.0,
                  weight: FontWeight.bold,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
