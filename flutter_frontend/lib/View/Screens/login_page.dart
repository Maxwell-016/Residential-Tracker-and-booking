import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/app_colors.dart';
import 'package:flutter_frontend/View-Model/utils/validator.dart';
import 'package:flutter_frontend/View/Components/function_button.dart';
import 'package:flutter_frontend/View/Components/google_fonts.dart';
import 'package:flutter_frontend/View/Components/link_button.dart';
import 'package:flutter_frontend/View/Components/password_field.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_frontend/View/Screens/registration_page.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../View-Model/view_model.dart';
import '../../security/hashPassword.dart';

class LoginPage extends HookConsumerWidget{
  final double width;
  const LoginPage({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<FormState> _formKeylogin = GlobalKey<FormState>();
    TextEditingController emailController = useTextEditingController();
    FocusNode emailFocus = useFocusNode();
    TextEditingController passController = useTextEditingController();
    FocusNode passFocus = useFocusNode();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    final userDao = ref.watch(userDaoProvider);
    return SafeArea(child: Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 50.0,),
              Card(
                elevation: 5.0,
                shadowColor: isDark? Colors.white: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    spacing: 15.0,
                    children: [
                      SizedBox(),
                      Icon(Icons.lock,size: 50.0,),
                      UseFont(text: 'Enter your registered username and password to login', myFont: 'Open Sans', size: 20.0,),
                      Form(
                        key: _formKeylogin,
                          child:
                          Column(
                            children: [
                      MyTextField(label: 'Email',
                        placeHolder: '12345@gmail.com',
                        controller: emailController, icon: Icon(Icons.email),
                        fieldValidator: Validators.emailValidator, focusNode: emailFocus, width: width,),
                      PasswordField(label: 'Password', placeHolder: 'Enter your password', controller: passController, hidePassword: Icon(Icons.visibility_off), showPassword: Icon(Icons.visibility), fieldValidator: Validators.passwordValidator, focusNode: passFocus, width: width,),
                       ]),
                      ),
                      LinkButton(onPressed: (){context.go('/forgot-password');}, text: 'Forgot Password?'),


                      FunctionButton(text:
                      'Login', onPressed: () async {
    if (_formKeylogin.currentState!.validate()) {

      final errorMessage = await userDao.signIn(
          emailController.text,
          hashPassword(passController.text)
      );
    if (errorMessage == null||errorMessage =="Student"||errorMessage =="Admin"||errorMessage =="Landload") {
    context.go('/studentdashboard');
    } else {
   //   if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: const Duration(milliseconds: 700),
        ),
      );
    }





    }






                      },
                        btnColor: AppColors.deepBlue,width: width,),
                      SizedBox(
                        width: width,
                        child: Row(children: [
                          Text('Don\'t have an account? Click here to'),
                          LinkButton(onPressed: (){

                            ///to be fixed
                           // context.go('/registration');
                            double deviceWidth = MediaQuery.of(context).size.width;
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>   RegistrationPage(
                                width: deviceWidth / 1.1,
                              )
                              ),
                            );


                          }, text: 'Register'),
                        ],),
                      )
                    ],
                  ),

                ),
              ),
            ],
          ),
        ),
      ),
    ),);
  }

}