/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/cards/custom_cards.dart';
import '../../../../core/widgets/inputs/custom_inputs.dart';

class ExplorerDiaryCard extends StatelessWidget {
  final VoidCallback onTap;

  const ExplorerDiaryCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label:
          'Mi Diario de Explorador. Crea tu libro de recuerdos de Extremadura.',
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: CustomCard(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              const Icon(Icons.bookmark, color: Color(0xFF42A5F5), size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mi Diario de Explorador',
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Crea tu libro de recuerdos de Extremadura',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.62,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Theme.of(context).colorScheme.onSurface,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 320;
        final cancelButton = OutlinedButton(
          onPressed: isSaving ? null : onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.negroTexto,
            side: const BorderSide(color: AppColors.verdeBorde),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text("Cancelar"),
        );
        final saveButton = _ProfileActionButton(
          text: isSaving ? savingText : saveText,
          onPressed: isSaving ? null : onSave,
        );

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [cancelButton, const SizedBox(height: 10), saveButton],
          );
        }

        return Row(
          children: [
            Expanded(child: cancelButton),
            const SizedBox(width: 10),
            Expanded(child: saveButton),
          ],
        );
      },
    );
  }
}

class _ProfileActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const _ProfileActionButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.verdePrincipal,
          foregroundColor: AppColors.blancoPuro,
          disabledBackgroundColor: AppColors.grisSombra,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(text, textAlign: TextAlign.center, softWrap: true),
      ),
    );
  }
}
