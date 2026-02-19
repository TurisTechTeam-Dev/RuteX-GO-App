import 'dart:convert';

import 'package:flutter/material.dart';

 class custom_input extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const custom_input({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false, 
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontSize: 15,
          ),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFE9E6DC),

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12, // 🔥 más bajo
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14), // 🔥 menos redondo
              borderSide: const BorderSide(
                color: Color(0xFF4CAF70),
                width: 1.5, // 🔥 más fino
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4CAF70),
                width: 1.5,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF007A3D),
                width: 2,
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),
      ],
    );
  }
 }