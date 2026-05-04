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
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../app/navigation/app_routes.dart';
import '../../../app/widgets/custom_drawer.dart';
import '../../../app/widgets/top_app_bar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../core/widgets/audio_guide/audio_guide.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../domain/entities/home_data.dart';
import '../domain/entities/user_profile.dart';
import '../domain/usecases/profile_use_cases.dart';
import 'widgets/profile_content.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _usernameFormKey = GlobalKey<FormState>();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _imagePicker = ImagePicker();

  late final AuthUseCases _authUseCases;
  late final ProfileUseCases _profileUseCases;
  late Future<HomeData> _profileFuture;

  bool _isEditingUsername = false;
  bool _isEditingEmail = false;
  bool _isEditingPassword = false;
  bool _isSavingUsername = false;
  bool _isSavingEmail = false;
  bool _isSavingPassword = false;
  bool _isUploadingAvatar = false;

  String _buildProfileAudioGuideText(HomeData data) {
    final user = data.user;
    final displayName = user.username.isNotEmpty ? user.username : user.name;

    return 'Hola $displayName. Estás en la pantalla de perfil. Aquí puedes ver tu foto actual, tu nombre de usuario y tu correo ${user.email}. Puedes cambiar tu foto pulsando la cámara, editar tu usuario, solicitar un cambio de email o actualizar tu contraseña en las secciones inferiores.';
  }

  @override
  void initState() {
    super.initState();
    _authUseCases = context.read<AuthUseCases>();
    _profileUseCases = context.read<ProfileUseCases>();
    _profileFuture = _loadProfileData();
  }

  Future<HomeData> _loadProfileData() async {
    final user = _authUseCases.getCurrentUser();
    if (user == null) {
      throw Exception("No hay sesión activa.");
    }

    return _profileUseCases.getHomeData(user.uid);
  }

  void _initializeForm(UserProfile user) {
    final authEmail = _authUseCases.getCurrentUser()?.email;
    final username = user.username.isNotEmpty ? user.username : user.name;
    final email = authEmail?.isNotEmpty == true ? authEmail! : user.email;

    if (!_isEditingUsername && _usernameController.text != username) {
      _usernameController.text = username;
    }

    if (!_isEditingEmail && _emailController.text != email) {
      _emailController.text = email;
    }
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfileData();
    });
  }

  Future<void> _updateUsername() async {
    if (!_usernameFormKey.currentState!.validate()) return;

    final user = _authUseCases.getCurrentUser();
    if (user == null) {
      _showMessage("No hay sesión activa.", isError: true);
      return;
    }

    setState(() => _isSavingUsername = true);
    try {
      await _profileUseCases.updateUsername(
        uid: user.uid,
        username: _usernameController.text.trim(),
      );
      if (!mounted) return;

      setState(() => _isEditingUsername = false);
      _showMessage("Usuario actualizado correctamente.");
      _refreshProfile();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSavingUsername = false);
    }
  }

  Future<void> _changeAvatar() async {
    final user = _authUseCases.getCurrentUser();
    if (user == null) {
      _showMessage("No hay sesión activa.", isError: true);
      return;
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
      maxHeight: 900,
    );
    if (image == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final bytes = await image.readAsBytes();
      final avatarPath = await _profileUseCases.uploadAvatar(
        uid: user.uid,
        bytes: bytes,
        contentType: image.mimeType ?? 'image/jpeg',
      );
      await _profileUseCases.updateAvatar(
        uid: user.uid,
        avatarPath: avatarPath,
      );
      if (!mounted) return;

      _showMessage("Foto de perfil actualizada.");
      _refreshProfile();
    } catch (e) {
      if (!mounted) return;
      _showMessage(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _requestEmailChange() async {
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isSavingEmail = true);
    try {
      await _authUseCases.requestEmailChange(_emailController.text.trim());
      if (!mounted) return;

      setState(() => _isEditingEmail = false);
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

      setState(() => _isEditingPassword = false);
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
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canReturnToPreviousRoute = Navigator.of(context).canPop();

    return PopScope(
      canPop: canReturnToPreviousRoute,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
      },
      child: Scaffold(
        appBar: const TopAppBar(showBack: true),
        endDrawer: const CustomDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: FutureBuilder<HomeData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            return AudioGuideWidget(
              text: snapshot.hasData
                  ? _buildProfileAudioGuideText(snapshot.data!)
                  : 'Pantalla de perfil. Aquí puedes ver tus datos, cambiar tu foto, editar usuario, solicitar cambio de email o actualizar tu contraseña.',
              autoRead: MediaQuery.of(context).accessibleNavigation,
              semanticLabel:
                  'Botón de audioguía. Pulsa para escuchar la descripción de tu perfil.',
            );
          },
        ),
        body: Stack(
          children: [
            const ExtremaduraMapBackground(),
            SafeArea(
              child: FutureBuilder<HomeData>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return ProfileError(message: snapshot.error.toString());
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snapshot.data!;
                  _initializeForm(data.user);

                  return ProfileContent(
                    user: data.user,
                    usernameFormKey: _usernameFormKey,
                    emailFormKey: _emailFormKey,
                    passwordFormKey: _passwordFormKey,
                    usernameController: _usernameController,
                    emailController: _emailController,
                    currentPasswordController: _currentPasswordController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                    isEditingUsername: _isEditingUsername,
                    isEditingEmail: _isEditingEmail,
                    isEditingPassword: _isEditingPassword,
                    isSavingUsername: _isSavingUsername,
                    isSavingEmail: _isSavingEmail,
                    isSavingPassword: _isSavingPassword,
                    isUploadingAvatar: _isUploadingAvatar,
                    onEditUsername: () =>
                        setState(() => _isEditingUsername = true),
                    onCancelUsername: () {
                      _usernameController.text = data.user.username.isNotEmpty
                          ? data.user.username
                          : data.user.name;
                      setState(() => _isEditingUsername = false);
                    },
                    onSaveUsername: _updateUsername,
                    onChangeAvatar: _changeAvatar,
                    onOpenDiary: () =>
                        Navigator.pushNamed(context, AppRoutes.explorerDiary),
                    onEditEmail: () => setState(() => _isEditingEmail = true),
                    onCancelEmail: () {
                      final authEmail = _authUseCases.getCurrentUser()?.email;
                      _emailController.text = authEmail?.isNotEmpty == true
                          ? authEmail!
                          : data.user.email;
                      setState(() => _isEditingEmail = false);
                    },
                    onSaveEmail: _requestEmailChange,
                    onEditPassword: () =>
                        setState(() => _isEditingPassword = true),
                    onCancelPassword: () {
                      _currentPasswordController.clear();
                      _passwordController.clear();
                      _confirmPasswordController.clear();
                      setState(() => _isEditingPassword = false);
                    },
                    onSavePassword: _updatePassword,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
