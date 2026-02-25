import 'package:customer_order_app/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardtype;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final RxString? fieldError;
  final Animation<double>? shakeAnimation;
  final Function(String)? onChanged;
  final Widget? prefixIcon;

  const CustomTextField({
    super.key,
    this.keyboardtype,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.fieldError,
    this.shakeAnimation,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    Widget textField = TextFormField(
      keyboardType: keyboardtype,
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      onChanged: (value) {
        if (fieldError != null) {
          fieldError!.value = '';
        }
      },
      decoration: InputDecoration(
        prefixIcon: prefixIcon,
        prefixIconColor: ThemesApp.textDarkColor,
        hintText: hintText,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.black),
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: suffixIcon,
        suffixIconColor: ThemesApp.textDarkColor,
      ),
    );

    if (shakeAnimation != null) {
      textField = AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shakeAnimation!.value, 0),
            child: child,
          );
        },
        child: textField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        textField,
        if (fieldError != null)
          Obx(
            () =>
                fieldError!.value.isNotEmpty
                    ? Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Text(
                        fieldError!.value,
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    )
                    : const SizedBox.shrink(),
          ),
      ],
    );
  }
}
