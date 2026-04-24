import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../core/widgets/bars/top_app_bar.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';
import '../data/factories/home_data_loader_factory.dart';
import '../domain/entities/home_data.dart';
import '../domain/entities/user_profile.dart';
import 'widgets/profile_content.dart';

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
                  return ProfileError(message: snapshot.error.toString());
                }

                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;
                _initializeForm(data.user);

                return ProfileContent(
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
