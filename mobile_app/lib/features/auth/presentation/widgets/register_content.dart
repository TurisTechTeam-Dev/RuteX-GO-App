import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/inputs/custom_inputs.dart';
import 'auth_card.dart';
import 'auth_logo.dart';

class RegisterContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptedTerms;
  final bool isLoading;
  final bool isButtonEnabled;
  final ValueChanged<bool> onAcceptedTermsChanged;
  final VoidCallback onRegister;
  final VoidCallback onOpenLogin;

  const RegisterContent({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    required this.isLoading,
    required this.isButtonEnabled,
    required this.onAcceptedTermsChanged,
    required this.onRegister,
    required this.onOpenLogin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final backgroundOpacity = theme.brightness == Brightness.dark ? 0.18 : 0.3;

    return SafeArea(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          image: DecorationImage(
            image: const AssetImage('assets/Mapa_fondo_Extremadura.png'),
            opacity: backgroundOpacity,
            fit: BoxFit.contain,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardInset),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AuthLogo(height: size.height * 0.10),
                  const SizedBox(height: 10),
                  AuthCard(
                    children: [
                      _RegisterForm(
                        formKey: formKey,
                        usernameController: usernameController,
                        nameController: nameController,
                        emailController: emailController,
                        passwordController: passwordController,
                        confirmPasswordController: confirmPasswordController,
                        acceptedTerms: acceptedTerms,
                        onAcceptedTermsChanged: onAcceptedTermsChanged,
                      ),
                      const SizedBox(height: 10),
                      CustomButton(
                        text: isLoading ? "CARGANDO..." : "Crear cuenta",
                        onPressed: isButtonEnabled ? onRegister : null,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿Ya tienes cuenta?  ",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          GestureDetector(
                            onTap: onOpenLogin,
                            child: const Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                color: AppColors.verdePrincipal,
                                fontWeight: FontWeight.bold,
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

class _RegisterForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool acceptedTerms;
  final ValueChanged<bool> onAcceptedTermsChanged;

  const _RegisterForm({
    required this.formKey,
    required this.usernameController,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.acceptedTerms,
    required this.onAcceptedTermsChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomInput(
            label: 'Usuario',
            hint: 'Introduce tu nombre de usuario',
            controller: usernameController,
            validator: (value) =>
                Validators.validateRequiredField(value, 'Usuario'),
          ),
          CustomInput(
            label: 'Nombre',
            hint: 'Introduce tu nombre',
            controller: nameController,
            validator: Validators.validateName,
          ),
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
            controller: passwordController,
            isPassword: true,
            validator: Validators.validatePassword,
          ),
          CustomInput(
            label: 'Confirmar contraseña',
            hint: 'Repite tu contraseña',
            controller: confirmPasswordController,
            isPassword: true,
            validator: (value) => Validators.validatePasswordMatch(
              value,
              passwordController.text,
            ),
          ),
          Transform.translate(
            offset: const Offset(-8, 0),
            child: Row(
              children: [
                Checkbox(
                  value: acceptedTerms,
                  activeColor: AppColors.verdePrincipal,
                  visualDensity: VisualDensity.compact,
                  onChanged: (value) => onAcceptedTermsChanged(value ?? false),
                ),
                Text(
                  "Acepto términos y condiciones",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
