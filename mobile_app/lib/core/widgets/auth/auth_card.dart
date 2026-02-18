import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/inputs/custom_inputs.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({super.key}); // Usando el formato moderno de super.key

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      elevation: 16,
      child: Column(
        children: [
          Text("usuario"),
          const SizedBox(height: 20),
          const Custom_input(
            keyboardType: TextInputType.text,
            label: 'ususario',
          ),
          Text("contraseña"),
          const SizedBox(height: 20),
          const Custom_input(
            keyboardType: TextInputType.visiblePassword,
            label: 'contraseña',
          ),
        ],
      ),
    );
  }
}
