import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../../core/widgets/images/storage_aware_image.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../data/factories/home_data_loader_factory.dart';
import '../domain/entities/home_data.dart';
import '../domain/entities/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late final AuthUseCases _authUseCases;
  late final Future<HomeData> _profileFuture;

  bool _isInitialized = false;
  bool _isSavingEmail = false;
  bool _isSavingPassword = false;

  @override
  void initState() {
    super.initState();
    _authUseCases = context.read<AuthUseCases>();
    _profileFuture = _loadProfileData();
  }

  Future<HomeData> _loadProfileData() async {
    final user = _authUseCases.getCurrentUser();
    if (user == null) {
      throw Exception("No hay sesión activa.");
    }

    return createHomeDataLoader().load(user.uid);
  }

  void _initializeForm(UserProfile user) {
    if (_isInitialized) return;

    final authEmail = _authUseCases.getCurrentUser()?.email;
    _emailController.text = authEmail?.isNotEmpty == true
        ? authEmail!
        : user.email;
    _isInitialized = true;
  }

  Future<void> _requestEmailChange() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isSavingEmail = true);
    try {
      await _authUseCases.requestEmailChange(_emailController.text.trim());
      if (!mounted) return;

      _showMessage(
        "Te hemos enviado un correo para confirmar el cambio de email.",
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSavingEmail = false);
    }
  }

  Future<void> _updatePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    setState(() => _isSavingPassword = true);
    try {
      await _authUseCases.updatePassword(
        currentPassword: _currentPasswordController.text.trim(),
        newPassword: _passwordController.text.trim(),
      );
      _currentPasswordController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      if (!mounted) return;

      _showMessage("Contraseña actualizada correctamente.");
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSavingPassword = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll("Exception: ", "")),
        backgroundColor: isError ? AppColors.error : AppColors.exito,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          const ExtremaduraMapBackground(),
          SafeArea(
            child: FutureBuilder<HomeData>(
              future: _profileFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _ProfileError(message: snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                _initializeForm(data.user);

                return _ProfileContent(
                  user: data.user,
                  emailFormKey: _emailFormKey,
                  passwordFormKey: _passwordFormKey,
                  emailController: _emailController,
                  currentPasswordController: _currentPasswordController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  isSavingEmail: _isSavingEmail,
                  isSavingPassword: _isSavingPassword,
                  onSaveEmail: _requestEmailChange,
                  onSavePassword: _updatePassword,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserProfile user;
  final GlobalKey<FormState> emailFormKey;
  final GlobalKey<FormState> passwordFormKey;
  final TextEditingController emailController;
  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isSavingEmail;
  final bool isSavingPassword;
  final VoidCallback onSaveEmail;
  final VoidCallback onSavePassword;

  const _ProfileContent({
    required this.user,
    required this.emailFormKey,
    required this.passwordFormKey,
    required this.emailController,
    required this.currentPasswordController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isSavingEmail,
    required this.isSavingPassword,
    required this.onSaveEmail,
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
          _ProfileHeader(user: user, displayName: displayName),
          const SizedBox(height: 18),
          _EmailFormCard(
            formKey: emailFormKey,
            controller: emailController,
            isSaving: isSavingEmail,
            onSave: onSaveEmail,
          ),
          const SizedBox(height: 18),
          _PasswordFormCard(
            formKey: passwordFormKey,
            currentPasswordController: currentPasswordController,
            passwordController: passwordController,
            confirmPasswordController: confirmPasswordController,
            isSaving: isSavingPassword,
            onSave: onSavePassword,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserProfile user;
  final String displayName;

  const _ProfileHeader({required this.user, required this.displayName});

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          _ProfileAvatar(avatarUrl: user.avatarUrl),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.negroTexto,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name,
                  style: const TextStyle(color: AppColors.grisNeutro),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(color: AppColors.grisNeutro),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String avatarUrl;

  const _ProfileAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    if (avatarUrl.isEmpty) {
      return const CircleAvatar(
        radius: 34,
        backgroundColor: AppColors.verdePrincipal,
        child: Icon(Icons.person, color: AppColors.blancoPuro, size: 34),
      );
    }

    return ClipOval(
      child: StorageAwareImage(
        source: avatarUrl,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        fallback: const CircleAvatar(
          radius: 34,
          backgroundColor: AppColors.verdePrincipal,
          child: Icon(Icons.person, color: AppColors.blancoPuro, size: 34),
        ),
      ),
    );
  }
}

class _EmailFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isSaving;
  final VoidCallback onSave;

  const _EmailFormCard({
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

class _PasswordFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController currentPasswordController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isSaving;
  final VoidCallback onSave;

  const _PasswordFormCard({
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

class _ProfileError extends StatelessWidget {
  final String message;

  const _ProfileError({required this.message});

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
