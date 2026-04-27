import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/inputs/custom_inputs.dart';

class UsernameFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const UsernameFormCard({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isSaving,
    required this.onCancel,
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
            const _SectionTitle("Nombre de usuario"),
            const SizedBox(height: 12),
            CustomInput(
              label: "Usuario",
              hint: "Introduce tu nombre de usuario",
              controller: controller,
              validator: _validateUsername,
            ),
            _ProfileActionRow(
              isSaving: isSaving,
              savingText: "GUARDANDO...",
              saveText: "Guardar usuario",
              onCancel: onCancel,
              onSave: onSave,
            ),
          ],
        ),
      ),
    );
  }

  String? _validateUsername(String? value) {
    return Validators.validateRequiredField(value, "usuario");
  }
}

class EmailFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EmailFormCard({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isSaving,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
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
          children: _buildFormContent(),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent() {
    final content = <Widget>[
      _EditableSectionTitle(
        text: "Correo electrónico",
        isEditing: isEditing,
        onEdit: onEdit,
      ),
    ];

    if (!isEditing) {
      content.add(const SizedBox(height: 8));
      content.add(
        Text(
          controller.text,
          style: const TextStyle(color: AppColors.grisNeutro),
        ),
      );
      return content;
    }

    content.add(const SizedBox(height: 12));
    content.add(
      CustomInput(
        label: "Nuevo email",
        hint: "Introduce tu nuevo email",
        keyboardType: TextInputType.emailAddress,
        controller: controller,
        validator: Validators.validateEmail,
      ),
    );
    content.add(
      _ProfileActionRow(
        isSaving: isSaving,
        savingText: "ENVIANDO...",
        saveText: "Enviar verificación",
        onCancel: onCancel,
        onSave: onSave,
      ),
    );

    return content;
  }
}

class PasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isSaving;
  final bool isEditing;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const PasswordFormCard({
    super.key,
    required this.formKey,
    required this.currentPasswordController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSaving,
    required this.isEditing,
    required this.onEdit,
    required this.onCancel,
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
          children: _buildFormContent(),
        ),
      ),
    );
  }

  List<Widget> _buildFormContent() {
    final content = <Widget>[
      _EditableSectionTitle(
        text: "Contraseña",
        isEditing: isEditing,
        onEdit: onEdit,
      ),
    ];

    if (!isEditing) {
      content.add(const SizedBox(height: 8));
      content.add(
        const Text("••••••••", style: TextStyle(color: AppColors.grisNeutro)),
      );
      return content;
    }

    content.add(const SizedBox(height: 12));
    content.add(
      CustomInput(
        label: "Contraseña actual",
        hint: "Introduce tu contraseña actual",
        isPassword: true,
        controller: currentPasswordController,
        validator: Validators.validatePassword,
      ),
    );
    content.add(
      CustomInput(
        label: "Nueva contraseña",
        hint: "Introduce tu nueva contraseña",
        isPassword: true,
        controller: passwordController,
        validator: Validators.validatePassword,
      ),
    );
    content.add(
      CustomInput(
        label: "Confirmar contraseña",
        hint: "Repite tu nueva contraseña",
        isPassword: true,
        controller: confirmPasswordController,
        validator: _validateRepeatedPassword,
      ),
    );
    content.add(
      _ProfileActionRow(
        isSaving: isSaving,
        savingText: "GUARDANDO...",
        saveText: "Actualizar contraseña",
        onCancel: onCancel,
        onSave: onSave,
      ),
    );

    return content;
  }

  String? _validateRepeatedPassword(String? value) {
    return Validators.validatePasswordMatch(value, passwordController.text);
  }
}

class _EditableSectionTitle extends StatelessWidget {
  final String text;
  final bool isEditing;
  final VoidCallback onEdit;

  const _EditableSectionTitle({
    required this.text,
    required this.isEditing,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _SectionTitle(text)),
        if (!isEditing)
          IconButton(
            tooltip: 'Editar',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.verdePrincipal,
            onPressed: onEdit,
          ),
      ],
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

class _ProfileActionRow extends StatelessWidget {
  final bool isSaving;
  final String savingText;
  final String saveText;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _ProfileActionRow({
    required this.isSaving,
    required this.savingText,
    required this.saveText,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSaving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.negroTexto,
              side: const BorderSide(color: AppColors.verdeBorde),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Cancelar"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ProfileActionButton(
            text: isSaving ? savingText : saveText,
            onPressed: isSaving ? null : onSave,
          ),
        ),
      ],
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
