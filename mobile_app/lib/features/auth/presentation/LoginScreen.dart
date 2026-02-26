import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../../../core/widgets/buttons/custom_button.dart';
import '../data/auth_repository_impl.dart';
import '../domain/usescases/login_usecase.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final LoginUseCase _loginUseCase;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(FirebaseAuth.instance);
    _loginUseCase = LoginUseCase(repository);
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _loginUseCase(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // FONDO (Mapa)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa Fondo Extremadura.jpeg'),
                opacity: 0.4, // Un poco más visible según la captura 2
                fit: BoxFit.contain,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80), // Bajamos un poco menos el logo
                // LOGO
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logos finales rutexgo1.2.png',
                    height: size.height * 0.18, // Un poco más pequeño
                  ),
                ),

                const SizedBox(height: 20),

                // TEXTO DESCRIPTIVO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    '"Descubre rutas culturales, aprende y juega recorriendo la historia de Extremadura."',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 18, // Tamaño ajustado según diseño
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      color: AppColors.negroTexto,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: AuthCard(
                    children: [
                      custom_input(
                        label: 'Email',
                        hint: 'Introduce tu email', // Hint ajustado
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      custom_input(
                        label: 'Contraseña',
                        hint: 'Introduce tu contraseña', // Hint ajustado
                        isPassword: true,
                        controller: _passwordController,
                      ),

                      const SizedBox(height: 30),

                      // BOTÓN INICIAR SESIÓN
                      CustomButton(
                        text: _isLoading ? "CARGANDO..." : "Iniciar Sesión",
                        onPressed: _isLoading ? null : _handleLogin,
                      ),

                      // ENLACE CONTRASEÑA OLVIDADA
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            /* Navegar a recuperar */
                          },
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

                      // FOOTER REGISTRO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿No tienes cuenta?  ",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: Text(
                              "Regístrate",
                              style: TextStyle(
                                color: AppColors
                                    .verdePrincipal, // Corregido a Verde
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration
                                    .none, // En la captura no parece subrayado
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
