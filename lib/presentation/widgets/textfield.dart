import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    this.controller,
    this.isPassword = false,
    this.focusNode,
    this.obscureToggle,
    this.obscureText = false,
    this.onChanged,
  });

  final String hint;
  final String label;
  final TextEditingController? controller;
  final bool isPassword;
  final FocusNode? focusNode;
  final VoidCallback? obscureToggle;
  final bool obscureText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: isPassword ? obscureText : false,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        label: Text(label),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Colors.grey, width: 1),
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: obscureToggle,
        )
            : null,
      ),
    );
  }
}
