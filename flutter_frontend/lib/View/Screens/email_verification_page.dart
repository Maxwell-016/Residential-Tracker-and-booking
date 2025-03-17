import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmailVerificationPage extends HookConsumerWidget {
  final double width;
  const EmailVerificationPage({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              spacing: 20.0,
              children: [
                SizedBox(),
                Card(
                  elevation: 5.0,
                  shadowColor: isDark ? Colors.white : Colors.black54,
                  child: Column(
                    children: [
                      SizedBox(),
                      UseFont(
                          text:
                              'A verification link has been sent  to the email that you provided. Click the link to verify your email. If you did not  receive the email click the button below to resend ',
                          myFont: 'Open Sans',
                          size: 20.0),
                      FunctionButton(text: 'Resend', onPressed: (){}, btnColor: AppColors.deepBlue,width: width,)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
