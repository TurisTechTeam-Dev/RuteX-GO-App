import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_app/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validadores.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/auth/auth_logo.dart';
import '../../../core/widgets/auth/auth_snack_bar.dart';
import '../../../core/widgets/buttons/custom_button.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';

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

      final isAdmin = await _authUseCases.checkAdminStatus(user.uid);

      debugPrint(
        "VERIFICACION: Web=$kIsWeb | Admin=$isAdmin | Email=${user.email}",
      );

      if (!mounted) return;

      if (kIsWeb && isAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;
      showAuthSnackBar(context, e.toString(), backgroundColor: AppColors.error);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _recoverPassword() async {
    final emailError = Validadores.validarEmail(_emailController.text);
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
    final size = MediaQuery.of(context).size;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
              opacity: 0.4,
              fit: BoxFit.contain,
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardInset),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AuthLogo(height: size.height * 0.18),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '"Descubre rutas culturales, aprende y juega recorriendo la historia de Extremadura."',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: AppColors.negroTexto,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthCard(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInput(
                                label: 'Email',
                                hint: 'Introduce tu email',
                                controller: _emailController,
                                keyboardType: TextInputType.text,
                                validator: Validadores.validarEmail,
                              ),
                              CustomInput(
                                label: 'Contraseña',
                                hint: 'Introduce tu contraseña',
                                isPassword: true,
                                controller: _passwordController,
                                validator: Validadores.validarPassword,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        CustomButton(
                          text: _isLoading ? "CARGANDO..." : "Iniciar sesión",
                          onPressed: _isLoading ? null : _handleLogin,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _recoverPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                            ),
                            child: Text(
                              "¿Has olvidado tu contraseña?",
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: AppColors.grisSombra,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "¿No tienes cuenta?  ",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            GestureDetector(
                              onTap: _openRegister,
                              child: const Text(
                                "Regístrate",
                                style: TextStyle(
                                  color: AppColors.verdePrincipal,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
