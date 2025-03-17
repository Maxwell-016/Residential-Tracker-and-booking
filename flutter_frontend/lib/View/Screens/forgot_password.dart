import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View-Model/utils/validator.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ForgotPassword extends HookConsumerWidget{
  final double width;
  const ForgotPassword( {super.key,required this.width,});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    TextEditingController emailController = useTextEditingController();
    FocusNode emailFocus = useFocusNode();
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(child: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            spacing: 50.0,
            children: [
              SizedBox(height: 50.0,),
              Card(
                shadowColor: isDark? Colors.white: Colors.black54,
                elevation: 5.0,
                child: Column(
                  spacing: 15.0,
                  children: [
                    SizedBox(height: 20.0,),
                    Icon(Icons.lock,size: 50.0,),
                    UseFont(text: 'Enter your registered email to reset your password', myFont: 'Open Sans', size: 20.0),
                    MyTextField(label: 'Email', placeHolder: 'e.g.12345@gmail.com', controller: emailController, icon: Icon(Icons.email), fieldValidator: Validators.emailValidator, focusNode: emailFocus, width: width),
                    FunctionButton(text: 'Reset', onPressed: (){}, btnColor: AppColors.deepBlue,width: width,),
                    SizedBox(
                      width: width,
                      child: Divider(),
                    ),
                    FunctionButton(text: 'Back to Login', onPressed: (){context.go('/login');}, btnColor: AppColors.deepBlue,width: width,),
                  ],

                ),
              )
            ],
          ),
        ),
      ),
    ),);
  }

}