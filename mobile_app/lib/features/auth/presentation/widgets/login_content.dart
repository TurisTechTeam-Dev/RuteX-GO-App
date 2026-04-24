import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/inputs/custom_inputs.dart';
import 'auth_card.dart';
import 'auth_logo.dart';

class LoginContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onRecoverPassword;
  final VoidCallback onOpenRegister;

  const LoginContent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onRecoverPassword,
    required this.onOpenRegister,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return SafeArea(
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
                      _LoginForm(
                        formKey: formKey,
                        emailController: emailController,
                        passwordController: passwordController,
                      ),
                      const SizedBox(height: 30),
                      CustomButton(
                        text: isLoading ? "CARGANDO..." : "Iniciar sesión",
                        onPressed: isLoading ? null : onLogin,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: onRecoverPassword,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
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
                            onTap: onOpenRegister,
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
    );
  }
}

class _LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomInput(
            label: 'Email',
            hint: 'Introduce tu email',
            controller: emailController,
            keyboardType: TextInputType.text,
            validator: Validators.validateEmail,
          ),
          CustomInput(
            label: 'Contraseña',
            hint: 'Introduce tu contraseña',
            isPassword: true,
            controller: passwordController,
            validator: Validators.validatePassword,
          ),
        ],
      ),
    );
  }
}
