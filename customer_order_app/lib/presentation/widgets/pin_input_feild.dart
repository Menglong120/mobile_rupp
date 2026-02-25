import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PinInputField extends StatefulWidget {
  final int length;
  final Function(String)? onCompleted;
  final Function(String)? onChanged;
  final double fieldWidth;
  final double fieldHeight;
  final TextStyle? textStyle;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? selectedColor;
  final double borderRadius;
  final double spacing;
  final bool obscureText;
  final String obscuringCharacter;
  final bool autoFocus;
  final TextInputType keyboardType;

  const PinInputField({
    super.key,
    required this.length,
    this.onCompleted,
    this.onChanged,
    this.fieldWidth = 40.0,
    this.fieldHeight = 60.0,
    this.textStyle,
    this.activeColor,
    this.inactiveColor,
    this.selectedColor,
    this.borderRadius = 8.0,
    this.spacing = 8.0,
    this.obscureText = false,
    this.obscuringCharacter = '●',
    this.autoFocus = true,
    this.keyboardType = TextInputType.number,
  });

  @override
  State<PinInputField> createState() => PinInputFieldState();
}

class PinInputFieldState extends State<PinInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _currentPin = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    if (widget.autoFocus && _focusNodes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updatePin() {
    _currentPin = _controllers.map((c) => c.text).join();

    if (widget.onChanged != null) {
      widget.onChanged!(_currentPin);
    }

    if (_currentPin.length == widget.length && widget.onCompleted != null) {
      widget.onCompleted!(_currentPin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => Container(
          width: widget.fieldWidth,
          height: widget.fieldHeight,
          // margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
          decoration: BoxDecoration(
            border: Border.all(
              color: _focusNodes[index].hasFocus
                  ? (widget.selectedColor ?? Theme.of(context).primaryColor)
                  : _controllers[index].text.isNotEmpty
                      ? (widget.activeColor ?? Colors.green)
                      : (widget.inactiveColor ?? Colors.grey[300]!),
              width: _focusNodes[index].hasFocus ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Colors.grey[50],
          ),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: widget.keyboardType,
            textAlign: TextAlign.center,
            maxLength: 1,
            obscureText: widget.obscureText,
            obscuringCharacter: widget.obscuringCharacter,
            style: widget.textStyle ??
                const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
            inputFormatters: [
              if (widget.keyboardType == TextInputType.number)
                FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty && index < widget.length - 1) {
                _focusNodes[index + 1].requestFocus();
              } else if (value.isEmpty && index > 0) {
                _focusNodes[index - 1].requestFocus();
              }
              _updatePin();
            },
            onTap: () {
              _controllers[index].selection = TextSelection.fromPosition(
                TextPosition(offset: _controllers[index].text.length),
              );
            },
          ),
        ),
      ),
    );
  }

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _currentPin = '';
    if (_focusNodes.isNotEmpty) {
      _focusNodes[0].requestFocus();
    }
  }

  String get currentPin => _currentPin;
}
