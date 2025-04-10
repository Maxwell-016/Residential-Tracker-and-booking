import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_frontend/View/Components/password_field.dart';
import 'package:flutter_frontend/View/Components/snackbars.dart';
import 'package:flutter_frontend/View/Components/text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../View-Model/utils/app_colors.dart';
import '../../View-Model/utils/savecurrentpage.dart';
import '../../View-Model/utils/validator.dart';
import '../../security/hashPassword.dart';
import '../../services/firebase_services.dart';
import 'function_button.dart';
import 'google_fonts.dart';
import 'link_button.dart';

class LoginForm extends HookConsumerWidget {
  const LoginForm({super.key});
  static final GlobalKey<FormState> formKeylogin = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firebaseServicesProvider = ref.watch(firebaseServices);
    TextEditingController emailController = useTextEditingController();
    FocusNode emailFocus = useFocusNode();
    TextEditingController passController = useTextEditingController();
    FocusNode passFocus = useFocusNode();

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    var width = MediaQuery.of(context).size.width / 1.1;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            SizedBox(
              height: 50.0,
            ),
            SizedBox(
              width: width,
              child: Card(
                elevation: 5.0,
                shadowColor: isDark ? Colors.white : Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(spacing: 15.0, children: [
                    SizedBox(),
                    Icon(
                      Icons.lock,
                      size: 50.0,
                    ),
                    UseFont(
                      text:
                          'Enter your registered username and password to login',
                      myFont: 'Open Sans',
                      size: 20.0,
                    ),
                    Form(
                      key: formKeylogin,
                      child: Column(
                        children: [
                          MyTextField(
                            label: 'Email',
                            placeHolder: '12345@gmail.com',
                            controller: emailController,
                            icon: Icon(Icons.email),
                            fieldValidator: Validators.emailValidator,
                            focusNode: emailFocus,
                            width: width,
                            onSubmit: () {
                              FocusScope.of(context).requestFocus(passFocus);
                            },
                            inputAction: TextInputAction.next,
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
                            inputAction: TextInputAction.done,
                          ),
                          LinkButton(
                              onPressed: () {
                                saveCurrentPage('/forgot-password');
                                context.go('/forgot-password');
                              },
                              text: 'Forgot Password?'),
                          Center(
                            child: firebaseServicesProvider.isLoading
                                ? CircularProgressIndicator()
                                : FunctionButton(
                                    text: 'Login',
                                    onPressed: () async {
                                      if (formKeylogin.currentState!
                                          .validate()) {
                                        try {
                                          await firebaseServicesProvider.signIn(
                                              context,
                                              ref,
                                              emailController.text,
                                              passController.text);
                                              // hashPassword(
                                              //     passController.text));


                                        } catch (e) {
                                          if (!context.mounted) return;
                                          SnackBars.showErrorSnackBar(
                                              context,
                                              firebaseServicesProvider
                                                  .handleFirebaseAuthErrors(e
                                                      as FirebaseAuthException));
                                        } finally {
                                          firebaseServicesProvider
                                              .setIsLoading(false);
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
                                Text('Don\'t have an account? Click here to'),
                                LinkButton(
                                    onPressed: () {
                                      saveCurrentPage('/registration');
                                      context.go('/registration');
                                    },
                                    text: 'Register'),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
