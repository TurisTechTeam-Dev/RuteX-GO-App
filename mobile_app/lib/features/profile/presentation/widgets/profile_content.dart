import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/user_profile.dart';
import 'profile_forms.dart';
import 'profile_header.dart';

class ProfileContent extends StatelessWidget {
  final UserProfile user;
  final GlobalKey<FormState> usernameFormKey;
  final GlobalKey<FormState> emailFormKey;
  final GlobalKey<FormState> passwordFormKey;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isEditingUsername;
  final bool isEditingEmail;
  final bool isEditingPassword;
  final bool isSavingUsername;
  final bool isSavingEmail;
  final bool isSavingPassword;
  final bool isUploadingAvatar;
  final VoidCallback onEditUsername;
  final VoidCallback onCancelUsername;
  final VoidCallback onSaveUsername;
  final VoidCallback onChangeAvatar;
  final VoidCallback onEditEmail;
  final VoidCallback onCancelEmail;
  final VoidCallback onSaveEmail;
  final VoidCallback onEditPassword;
  final VoidCallback onCancelPassword;
  final VoidCallback onSavePassword;

  const ProfileContent({
    super.key,
    required this.user,
    required this.usernameFormKey,
    required this.emailFormKey,
    required this.passwordFormKey,
    required this.usernameController,
    required this.emailController,
    required this.currentPasswordController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isEditingUsername,
    required this.isEditingEmail,
    required this.isEditingPassword,
    required this.isSavingUsername,
    required this.isSavingEmail,
    required this.isSavingPassword,
    required this.isUploadingAvatar,
    required this.onEditUsername,
    required this.onCancelUsername,
    required this.onSaveUsername,
    required this.onChangeAvatar,
    required this.onEditEmail,
    required this.onCancelEmail,
    required this.onSaveEmail,
    required this.onEditPassword,
    required this.onCancelPassword,
    required this.onSavePassword,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = user.username.isNotEmpty ? user.username : user.name;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "Perfil de usuario",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          ProfileHeader(
            user: user,
            displayName: displayName,
            isUploadingAvatar: isUploadingAvatar,
            onChangeAvatar: onChangeAvatar,
            onEditUsername: onEditUsername,
          ),
          if (isEditingUsername) ...[
            const SizedBox(height: 18),
            UsernameFormCard(
              formKey: usernameFormKey,
              controller: usernameController,
              isSaving: isSavingUsername,
              onCancel: onCancelUsername,
              onSave: onSaveUsername,
            ),
          ],
          const SizedBox(height: 18),
          EmailFormCard(
            formKey: emailFormKey,
            controller: emailController,
            isSaving: isSavingEmail,
            isEditing: isEditingEmail,
            onEdit: onEditEmail,
            onCancel: onCancelEmail,
            onSave: onSaveEmail,
          ),
          const SizedBox(height: 18),
          PasswordFormCard(
            formKey: passwordFormKey,
            currentPasswordController: currentPasswordController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            isSaving: isSavingPassword,
            isEditing: isEditingPassword,
            onEdit: onEditPassword,
            onCancel: onCancelPassword,
            onSave: onSavePassword,
          ),
        ],
      ),
    );
  }
}

class ProfileError extends StatelessWidget {
  final String message;

  const ProfileError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "No se pudo cargar el perfil.\n$message",
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.negroTexto),
        ),
      ),
    );
  }
}
