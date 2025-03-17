import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../View-Model/utils/app_colors.dart';
import '../../View-Model/utils/validator.dart';
import '../Components/function_button.dart';
import '../Components/google_fonts.dart';
import '../Components/link_button.dart';
import '../Components/password_field.dart';
import '../Components/text_field.dart';

// class RegistrationPage extends HookConsumerWidget {
//   final double width;
//
//   const RegistrationPage({super.key, required this.width});
//
//   @override
//
// }
class RegistrationPage extends StatefulWidget {
  final double width;
  const RegistrationPage({super.key, required this.width});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    FocusNode emailFocus = FocusNode();
    TextEditingController passController = TextEditingController();
    FocusNode passFocus = FocusNode();
    TextEditingController confirmPassController = TextEditingController();
    FocusNode confirmPassFocus = FocusNode();
    TextEditingController roleController = TextEditingController();
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    String? selectedValue;
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: Card(
              elevation: 5,
              shadowColor: isDark ? Colors.white : Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                    // UseFont(
                    //     text: 'Select your role',
                    //     myFont: 'Open Sans',
                    //     size: 17.0),
                    // SizedBox(
                    //   width: widget.width,
                    //   child: Row(
                    //     children: [
                    //       Expanded(
                    //         child: RadioListTile<String?>(
                    //             title: Text('Student'),
                    //             value: 'student',
                    //             groupValue: selectedValue,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 selectedValue = value;
                    //               });
                    //             }),
                    //       ),
                    //       Expanded(
                    //         child: RadioListTile<String?>(
                    //             title: Text('Landlord'),
                    //             value: 'landlord',
                    //             groupValue: selectedValue,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 selectedValue = value;
                    //               });
                    //             }),
                    //       ),
                    //       Expanded(
                    //         child: RadioListTile<String?>(
                    //             title: Text('Admin'),
                    //             value: 'admin',
                    //             groupValue: selectedValue,
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 selectedValue = value;
                    //               });
                    //             }),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    SizedBox(height: 20.0,),
                    DropdownMenu(dropdownMenuEntries: [
                      DropdownMenuEntry(value: 'student', label: 'Student'),
                      DropdownMenuEntry(value: 'landlord', label: 'Landlord'),
                      DropdownMenuEntry(value: 'admin', label: 'Admin'),

                    ],
                      label: Text('Select your role'),
                      onSelected: (value){
                      setState(() {
                        selectedValue = value;
                      });
                      },
                      width: widget.width,
                      enableFilter: false,
                      enableSearch: false,
                      controller: roleController,
                    ),
                    MyTextField(
                      label: 'Email',
                      placeHolder: '12345@gmail.com',
                      controller: emailController,
                      icon: Icon(Icons.email),
                      fieldValidator: Validators.emailValidator,
                      focusNode: emailFocus,
                      width: widget.width,
                    ),
                    PasswordField(
                      label: 'Password',
                      placeHolder: 'Enter your password',
                      controller: passController,
                      hidePassword: Icon(Icons.visibility_off),
                      showPassword: Icon(Icons.visibility),
                      fieldValidator: Validators.passwordValidator,
                      focusNode: passFocus,
                      width: widget.width,
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
                      width: widget.width,
                    ),
                    FunctionButton(
                      text: 'Register',
                      onPressed: () {
                        context.go('/verify-email');
                      },
                      btnColor: AppColors.deepBlue,
                      width: widget.width,
                    ),
                    SizedBox(
                      width: widget.width,
                      child: Row(
                        children: [
                          Text('Already have an account? Click here to'),
                          LinkButton(
                              onPressed: () {
                                context.go('/login');
                              },
                              text: 'Login'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
