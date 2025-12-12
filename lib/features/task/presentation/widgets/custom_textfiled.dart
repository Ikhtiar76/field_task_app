import 'package:field_task_app/core/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String)? onChanged;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final bool filled;
  final Color fillColor;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hint = '',
    this.validator,
    this.keyboardType = TextInputType.text,
    this.filled = true,
    this.fillColor = white,
    this.borderRadius = 6,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: textStyle ?? const TextStyle(fontSize: 12, color: black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: grey.withOpacity(0.5)),
        filled: filled,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }
}
