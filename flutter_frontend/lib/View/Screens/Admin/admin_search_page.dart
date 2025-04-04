import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/constants.dart';

class AdminSearchPg extends StatefulWidget {
  const AdminSearchPg({
    super.key,
    required this.changeTheme,
    required this.changeColor,
    required this.colorSelected,
  });
  final ColorSelection colorSelected;
  final void Function(bool useLightMode) changeTheme;
  final void Function(int value) changeColor;

  @override
  State<AdminSearchPg> createState() => _adminSearchpage();
}

class _adminSearchpage extends State<AdminSearchPg> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 45,
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Enter student email',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                        color: Color.fromARGB(255, 4, 29, 49), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20), // Add spacing before other widgets
            // Add other content here
          ],
        ),
      ),
    );

    // return Scaffold(
    //   backgroundColor:
    //       Colors.grey[300], // Background color similar to the image
    //   body: Center(
    //     child: Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
    //       child: TextField(
    //         decoration: InputDecoration(
    //           labelText: 'Enter student email', // Floating label text
    //           prefixIcon: Icon(Icons.search), // Search icon
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(8),
    //           ),
    //           focusedBorder: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(8),
    //             borderSide: BorderSide(
    //                 color: const Color.fromARGB(255, 4, 29, 49), width: 2),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
