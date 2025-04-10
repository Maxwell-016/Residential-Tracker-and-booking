import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../View-Model/utils/app_colors.dart';
import '../../View-Model/view_model.dart';


class PasswordField extends HookConsumerWidget {
  final String label;
  final String placeHolder;
  final TextEditingController controller;
  final Icon hidePassword;
  final Icon showPassword;
  final FormFieldValidator<String?> fieldValidator;
  final FocusNode focusNode;
  final double width;
  final VoidCallback? onSubmit;
  final TextInputAction? inputAction;
  const PasswordField(
      {super.key,
      required this.label,
      required this.placeHolder,
      required this.controller,
      required this.hidePassword,
      required this.showPassword,
      required this.fieldValidator,
      required this.focusNode,
      required this.width,
      this.onSubmit,
      this.inputAction,
      });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelProvider = ref.watch(viewModel);
   bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.0,
        children: [
          Text(label),
          SizedBox(width: width,
            child: TextFormField(
              onTap: () {
                Future.delayed(Duration(seconds: 1), () {
                  if(!context.mounted) return;
                  FocusScope.of(context).requestFocus(focusNode);
                });
              },
              focusNode: focusNode,
              validator: fieldValidator,
              obscureText: viewModelProvider.isObscured,
              controller: controller,
              decoration: InputDecoration(
                  hintText: placeHolder,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
                  suffixIcon: IconButton(
                      onPressed: () {
                        viewModelProvider.toggleObscured();
                      },
                      icon:viewModelProvider.isObscured
                          ? hidePassword
                          : showPassword),
                  prefixIconColor: Colors.grey,
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: borderColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: borderColor)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.red,
                      )),
                  focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Colors.red,
                      ),
                  ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
