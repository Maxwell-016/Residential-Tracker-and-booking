import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View-Model/utils/savecurrentpage.dart';
import 'package:flutter_frontend/View/Components/password_field.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../View-Model/utils/app_colors.dart';
import '../../View-Model/utils/validator.dart';
import '../../View-Model/view_model.dart';
import '../../security/hashPassword.dart';
import '../../services/firebase_services.dart';
import 'function_button.dart';
import 'google_fonts.dart';
import 'link_button.dart';

class RegForm extends HookConsumerWidget{
  const RegForm({super.key});




  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final firebaseServicesProvider = ref.watch(firebaseServices);

    String selectedUser = ref.watch(selectedNameProvider);

    TextEditingController emailController = TextEditingController();
    FocusNode emailFocus = FocusNode();
    TextEditingController passController = TextEditingController();
    FocusNode passFocus = FocusNode();
    TextEditingController confirmPassController = TextEditingController();
    FocusNode confirmPassFocus = FocusNode();
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    var width = MediaQuery
        .of(context)
        .size
        .width / 1.1;

    return  SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: width,
          child: Card(
            elevation: 5,
            shadowColor: isDark ? Colors.white : Colors.black54,
            child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    spacing: 15.0,
                    children: [
                      SizedBox(),
                      Icon(
                        Icons.lock,
                        size: 50.0,
                      ),
                      UseFont(
                        text: 'Enter your username and password to Register',
                        myFont: 'Open Sans',
                        size: 20.0,
                      ),

                      SizedBox(
                        height: 20.0,
                      ),

                      // Container(
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.rectangle,
                      //     borderRadius: BorderRadius.circular(10),
                      //
                      //   ),
                      //   width: width,
                      //   child:
                        Row(
                          mainAxisSize: MainAxisSize.min,
                            children: [

                        Text("Select the role to register as  "),
                        DropdownButton<String>(

                            value: selectedUser,
                            items: <String>['Student', 'Landlord', "Admin"]
                                .map<DropdownMenuItem<String>>((String user) {
                              return DropdownMenuItem<String>(
                                value: user,
                                child: Text(user),
                              );
                            }).toList(),
                            onChanged: (newValue) {

                              ref.read(selectedNameProvider.notifier).state =
                              newValue!;
                            }),

                    ] ,
                  ),



                      MyTextField(
                        label: 'Email',
                        placeHolder: '12345@gmail.com',
                        controller: emailController,
                        icon: Icon(Icons.email),
                        fieldValidator: Validators.emailValidator,
                        focusNode: emailFocus,
                        width: width,
                      ),

                      PasswordField(
                        label: 'Password',
                        placeHolder: 'Enter your password',
                        controller: passController,
                        hidePassword: Icon(Icons.visibility_off),
                        showPassword: Icon(Icons.visibility),
                        fieldValidator: Validators.passwordValidator,
                        focusNode: passFocus,
                        width: width,
                      ),
                      PasswordField(
                        label: 'Confirm Password',
                        placeHolder: 'Confirm your password',
                        controller: confirmPassController,
                        hidePassword: Icon(Icons.visibility_off),
                        showPassword: Icon(Icons.visibility),
                        fieldValidator: (value) =>
                            Validators.confirmPasswordValidator(
                                value, passController.text),
                        focusNode: confirmPassFocus,
                        width: width,
                      ),

                      Center(
                        child: firebaseServicesProvider.isLoading? CircularProgressIndicator()
                            :FunctionButton(
                          text: 'Register',
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              try {

                                await firebaseServicesProvider.createUser(
                                  context,
                                  ref,
                                  emailController.text,
                                  hashPassword(passController.text),
                                  ref.watch(selectedNameProvider),
                                );



                              }catch(e){
                                if (!context.mounted) return;
                                SnackBars.showErrorSnackBar(
                                    context,
                                    firebaseServicesProvider
                                        .handleFirebaseAuthErrors(
                                        e as FirebaseAuthException));
                              }finally{
                                firebaseServicesProvider.setIsLoading(false);
                              }
                            }
                          },
                          btnColor: AppColors.deepBlue,
                          width: width,
                        ),
                      ),
                      SizedBox(
                        width: width,
                        child: Row(
                          children: [
                            Text('Already have an account? Click here to'),
                            LinkButton(
                                onPressed: () {
                                  context.go('/login');
                                  saveCurrentPage("/login");
                                },
                                text: 'Login'),
                          ],
                        ),
                      )
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }}