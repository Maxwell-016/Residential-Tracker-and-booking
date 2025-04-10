import 'package:flutter/material.dart';

import '../../View-Model/utils/app_colors.dart';

class MyTextField extends StatefulWidget {
  final String label;
  final String placeHolder;
  final TextEditingController controller;
  final Icon icon;
  final bool? isEnabled;
  final FormFieldValidator<String?> fieldValidator;
  final FocusNode focusNode;
  final double width;
  final int? maxLines;
  final VoidCallback? onSubmit;
  final TextInputAction? inputAction;
  const MyTextField(
      {super.key,
      required this.label,
      required this.placeHolder,
      required this.controller,
      required this.icon,
      required this.fieldValidator,
      required this.focusNode,
      required this.width,
      this.maxLines = 1,
      this.isEnabled,
      this.onSubmit,
      this.inputAction,
      });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor =
        isDark ? AppColors.lightThemeBackground : AppColors.darkThemeBackground;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10.0,
        children: [
          Text(widget.label),
          SizedBox(width: widget.width,
            child: TextFormField(
              focusNode: widget.focusNode,
              validator: widget.fieldValidator,
              controller: widget.controller,
              maxLines: widget.maxLines,
              textInputAction: widget.inputAction,
              onFieldSubmitted: (value) => widget.onSubmit!,
              decoration: InputDecoration(
                hintText: widget.placeHolder,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.0),
                prefixIcon: widget.icon,
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
