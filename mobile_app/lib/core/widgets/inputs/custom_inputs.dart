import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';

class CustomInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomInput({
    super.key,
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final enabledBorder =
        inputTheme.enabledBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.verdeBorde, width: 2),
        );
    final focusedBorder =
        inputTheme.focusedBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.verdePrincipal,
            width: 2.5,
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          scrollPadding: const EdgeInsets.all(24),
          style: theme.textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: inputTheme.fillColor ?? AppColors.cremaInput,
            contentPadding:
                inputTheme.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            isDense: true,
            hintStyle: inputTheme.hintStyle,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: enabledBorder.borderSide,
            ),
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
