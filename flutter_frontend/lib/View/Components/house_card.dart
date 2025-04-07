import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';

class HouseCard extends StatelessWidget {
  final String houseName;
  final String price;
  final String houseSize;
  final String? imageUrl;
  final bool? isNotMoney;
  final Future Function()? onDeletePressed;
  const HouseCard(
      {super.key,
      required this.houseName,
      required this.price,
      required this.houseSize,
      this.imageUrl,
      this.onDeletePressed,
      this.isNotMoney});

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
          imageUrl == null || imageUrl!.isEmpty
              ? Image.asset(
                  'assets/launch.png',
                  height: 198.0,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                )
              : Image.network(
                  imageUrl!,
                  height: 198.0,
                  filterQuality: FilterQuality.high,
                  fit: BoxFit.cover,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    UseFont(
                      text: isNotMoney != null ? price :'Ksh.$price' ,
                      myFont: 'Roboto',
                      size: 16.0,
                      weight: FontWeight.bold,
                    ),
                    onDeletePressed != null
                        ? IconButton(
                            onPressed: () async {
                              await onDeletePressed!();
                            },
                            icon: Icon(Icons.delete),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
