import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/usecases/auth_use_cases.dart';
import 'widgets/auth_snack_bar.dart';
import 'widgets/login_content.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthUseCases _authUseCases;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authUseCases = context.read<AuthUseCases>();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = await _authUseCases.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await _navigateAfterLogin(user.uid, user.email);
    } catch (e) {
      if (!mounted) return;
      showAuthSnackBar(context, e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authUseCases.loginWithGoogle();
      await _navigateAfterLogin(user.uid, user.email);
    } on GoogleSignInCancelledException {
      return;
    } catch (e) {
      if (!mounted) return;
      showAuthSnackBar(context, e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _navigateAfterLogin(String uid, String? email) async {
    final isAdmin = await _authUseCases.checkAdminStatus(uid);

    debugPrint("AUTH CHECK: Web=$kIsWeb | Admin=$isAdmin | Email=$email");

    if (!mounted) return;

    if (isAdmin) {
      Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  Future<void> _recoverPassword() async {
    final emailError = Validators.validateEmail(_emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Introduce un email válido arriba para recuperar tu contraseña",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authUseCases.recoverPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Correo de recuperación enviado."),
            backgroundColor: AppColors.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openRegister() async {
    await Navigator.pushNamed(context, AppRoutes.register);
    if (!mounted) return;

    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: LoginContent(
        formKey: _formKey,
        emailController: _emailController,
        passwordController: _passwordController,
        isLoading: _isLoading,
        onLogin: _handleLogin,
        onGoogleLogin: _handleGoogleLogin,
        onRecoverPassword: _recoverPassword,
        onOpenRegister: _openRegister,
      ),
    );
  }
}
