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
import 'dart:math' as math;

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../../../../core/widgets/inputs/custom_inputs.dart';
import 'auth_card.dart';
import 'auth_logo.dart';

class LoginContent extends StatelessWidget {
  static const _slogan =
      'Descubre rutas culturales, aprende y juega recorriendo la historia de Extremadura.';

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onLogin;
  final VoidCallback onGoogleLogin;
  final VoidCallback onRecoverPassword;
  final VoidCallback onOpenRegister;

  const LoginContent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onLogin,
    required this.onGoogleLogin,
    required this.onRecoverPassword,
    required this.onOpenRegister,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    final backgroundOpacity = theme.brightness == Brightness.dark ? 0.18 : 0.4;

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
                    child: Semantics(
                      label: _slogan,
                      child: ExcludeSemantics(
                        child: Text(
                          '"$_slogan"',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                                color: theme.colorScheme.onSurface,
                              ),
                        ),
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
                      const SizedBox(height: 12),
                      _GoogleSignInButton(
                        isLoading: isLoading,
                        onPressed: onGoogleLogin,
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
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
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
            keyboardType: TextInputType.emailAddress,
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

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 46,
      child: OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: const _GoogleLogo(),
        label: const Text("Continuar con Google", textAlign: TextAlign.center),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.onSurface,
          side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.08 * math.pi, 0.58 * math.pi, false, paint);

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 0.48 * math.pi, 0.42 * math.pi, false, paint);

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 0.90 * math.pi, 0.38 * math.pi, false, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 1.28 * math.pi, 0.50 * math.pi, false, paint);

    final centerY = size.height / 2;
    paint.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * 0.54, centerY),
      Offset(size.width * 0.92, centerY),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.82, centerY),
      Offset(size.width * 0.82, size.height * 0.68),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
