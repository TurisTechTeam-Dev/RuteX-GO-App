import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../../../core/widgets/buttons/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Controladores para capturar el texto
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // 2. Lógica de Login con Firebase
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _mapError(e.code));
    } catch (e) {
      setState(() => _errorMessage = "Ocurrió un error inesperado.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return "El correo no está registrado.";
      case 'wrong-password':
        return "La contraseña es incorrecta.";
      case 'invalid-email':
        return "El formato del email no es válido.";
      case 'user-disabled':
        return "Este usuario ha sido deshabilitado.";
      default:
        return "Error al iniciar sesión. Inténtalo de nuevo.";
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
          // FONDO
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa Fondo Extremadura.jpeg'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.05)),

          // CONTENIDO
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/logos finales rutexgo1.2.png',
                      height: size.height * 0.18,
                    ),
                  ),
                  const SizedBox(height: 30),

                  AuthCard(
                    children: [
                      Text(
                        "Iniciar Sesión",
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: 24, color: Colors.black),
                      ),
                      const SizedBox(height: 25),

                      // INPUTS con controladores
                      custom_input(
                        label: 'Email',
                        hint: 'tu@email.com',
                        controller:
                            _emailController, // Asegúrate de que tu widget acepte controller
                        keyboardType: TextInputType.emailAddress,
                      ),

                      custom_input(
                        label: 'Contraseña',
                        hint: '********',
                        isPassword: true,
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      // Mensaje de error si existe
                      if (_errorMessage != null) ...[
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],

                      const SizedBox(height: 10),

                      // BOTÓN con estado de carga
                      custom_button(
                        text: _isLoading ? "CARGANDO..." : "ENTRAR",
                        onPressed: _isLoading ? () {} : _handleLogin,
                      ),

                      const SizedBox(height: 20),

                      // ENLACE A REGISTRO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿No tienes cuenta? "),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.register,
                            ),
                            child: Text(
                              "Regístrate",
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
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
        ],
      ),
    );
  }
}
