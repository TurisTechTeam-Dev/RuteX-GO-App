import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/inputs/custom_inputs.dart';

class EmailFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  const EmailFormCard({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle("Correo electrónico"),
            const SizedBox(height: 12),
            CustomInput(
              label: "Nuevo email",
              hint: "Introduce tu nuevo email",
              keyboardType: TextInputType.emailAddress,
              controller: controller,
              validator: Validators.validateEmail,
            ),
            _ProfileActionButton(
              text: isSaving ? "ENVIANDO..." : "Enviar verificación",
              onPressed: isSaving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class PasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isSaving;
  final VoidCallback onSave;

  const PasswordFormCard({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSaving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SectionTitle("Contraseña"),
            const SizedBox(height: 12),
            CustomInput(
              label: "Contraseña actual",
              hint: "Introduce tu contraseña actual",
              isPassword: true,
              controller: currentPasswordController,
              validator: Validators.validatePassword,
            ),
            CustomInput(
              label: "Nueva contraseña",
              hint: "Introduce tu nueva contraseña",
              isPassword: true,
              controller: passwordController,
              validator: Validators.validatePassword,
            ),
            CustomInput(
              label: "Confirmar contraseña",
              hint: "Repite tu nueva contraseña",
              isPassword: true,
              controller: confirmPasswordController,
              validator: (value) => Validators.validatePasswordMatch(
                value,
                passwordController.text,
              ),
            ),
            _ProfileActionButton(
              text: isSaving ? "GUARDANDO..." : "Actualizar contraseña",
              onPressed: isSaving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.negroTexto,
      ),
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _ProfileActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrincipal,
          foregroundColor: AppColors.blancoPuro,
          disabledBackgroundColor: AppColors.grisSombra,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, textAlign: TextAlign.center),
      ),
    );
  }
}
