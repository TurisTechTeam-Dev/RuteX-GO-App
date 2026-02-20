import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
        _errorMessage =
            e.toString().replaceFirst("Exception: ", "");
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
    final size = MediaQuery
        .of(context)
        .size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [

          // FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa Fondo Extremadura.jpeg'),
                opacity: 0.3,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Container(
            color: Colors.white.withOpacity(0.30),
          ),

          SingleChildScrollView(
            child: Column(
              children: [

                const SizedBox(height: 100),

                // LOGO
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logos finales rutexgo1.2.png',
                    height: size.height * 0.22,
                  ),
                ),

                const SizedBox(height: 30),

                // TEXTO DESCRIPTIVO
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    '"Descubre rutas culturales, aprende y juega recorriendo la historia de Extremadura."',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      letterSpacing: 0.06,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: AuthCard(
                    children: [

                      custom_input(
                        label: 'Email',
                        hint: 'tu@email.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      custom_input(
                        label: 'Contraseña',
                        hint: '********',
                        isPassword: true,
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],

                      const SizedBox(height: 15),

                      CustomButton(
                        text: _isLoading
                            ? "CARGANDO..."
                            : "Iniciar Sesión",
                        onPressed:
                        _isLoading ? null : _handleLogin,
                      ),

                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No tienes cuenta? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.register,
                              );
                            },
                            child: Text(
                              "Regístrate",
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }
}