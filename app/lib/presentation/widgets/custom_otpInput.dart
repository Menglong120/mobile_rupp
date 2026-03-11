import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomOtpInput extends StatelessWidget {
  final int length;
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final double width;
  final double height;
  final TextInputType keyboardType;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final double borderRadius;
  final double spacing;

  const CustomOtpInput({
    super.key,
    required this.length,
    required this.controllers,
    required this.focusNodes,
    this.onCompleted,
    this.onChanged,
    this.width = 40.0,
    this.height = 60.0,
    this.keyboardType = TextInputType.number,
    this.textStyle,
    this.decoration,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.borderRadius = 8.0,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        length,
        (index) => Container(
          width: width,
          height: height,
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            keyboardType: keyboardType,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: textStyle ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: decoration ??
                InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: fillColor ?? Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor ?? Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color: borderColor ?? Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                    borderSide: BorderSide(
                      color:
                          focusedBorderColor ?? Theme.of(context).primaryColor,
                      width: 2.0,
                    ),
                  ),
                ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < length - 1) {
                  focusNodes[index + 1].requestFocus();
                } else {
                  focusNodes[index].unfocus();
                }
              } else {
                if (index > 0) {
                  focusNodes[index - 1].requestFocus();
                }
              }

              if (onChanged != null) {
                String otpValue = controllers.map((c) => c.text).join();
                onChanged!(otpValue);
              }

              if (_isAllFieldsFilled() && onCompleted != null) {
                String otpValue = controllers.map((c) => c.text).join();
                onCompleted!(otpValue);
              }
            },
            onTap: () {
              controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: controllers[index].text.length),
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isAllFieldsFilled() {
    return controllers.every((controller) => controller.text.isNotEmpty);
  }
}
