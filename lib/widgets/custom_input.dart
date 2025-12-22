import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscure;

  const CustomInput({
    super.key,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    const textGrey = Color(0xFF6F8F8B);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        obscureText: obscure,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: textGrey),
          prefixIcon: Icon(icon, color: textGrey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}