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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.negroTexto,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.cremaInput,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),

            // Borde base
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.verdeBorde,
                width: 2,
              ),
            ),

            // Borde cuando no está seleccionado
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.verdeBorde,
                width: 2,
              ),
            ),

            // Borde cuando el usuario hace clic
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.verdePrincipal,
                width: 2.5,
              ),
            ),

            // Borde cuando salta error
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
