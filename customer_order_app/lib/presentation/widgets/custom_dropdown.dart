import 'package:flutter/material.dart';

class GenderDropdown extends StatelessWidget {
  final String labelText;
  final String selectedGender;
  final Function(String?) onChanged;
  final String? Function(String?)? validator;
  final List<String> genderOptions;

  const GenderDropdown({
    super.key,
    required this.labelText,
    required this.selectedGender,
    required this.onChanged,
    this.validator,
    this.genderOptions = const ['male', 'female', 'other'],
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.black,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      value: selectedGender.isNotEmpty ? selectedGender : null,
      items: genderOptions.map(
        (gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender[0].toUpperCase() + gender.substring(1)),
          );
        },
      ).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
