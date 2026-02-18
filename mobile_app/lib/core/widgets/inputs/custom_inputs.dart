import 'dart:convert';

import 'package:flutter/material.dart';

 class Custom_input extends StatelessWidget {
 final String label;
  
  final bool isPassword;
  final TextInputType keyboardType;

  const Custom_input({
    super.key,
    required this.label,
    this.isPassword = false, 
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: isPassword,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50], // Un toque de color de fondo
      ),
    );
  }
}
