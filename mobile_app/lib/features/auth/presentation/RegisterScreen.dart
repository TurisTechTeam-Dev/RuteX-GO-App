import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../../../core/widgets/buttons/custom_button.dart';
import '../../../core/constants/app_colors.dart';
import '../data/auth_repository_impl.dart';
import '../domain/usescases/AuthUseCases.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _aceptaTerminos = false;
  bool _isLoading = false;

  late final AuthUsesCases _authUseCases;
  @override
  void initState() {
    super.initState();
    final repository = AuthRepositoryImpl(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
    _authUseCases = AuthUsesCases(repository);
  }

  Future<void> _handleRegister() async {
    if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debes aceptar los términos y condiciones.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authUseCases.register(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        usuario: _usuarioController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll("Exception: ", ""))),
        );
      }
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. FONDO
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/Mapa Fondo Extremadura.jpeg'),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 2. LOGO
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/logos finales rutexgo1.2.png',
                      height: size.height * 0.15,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. CARD DE REGISTRO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: AuthCard(
                      children: [
                        custom_input(
                          label: 'Usuario',
                          hint: 'Introduce tu nombre de usuario',
                          controller: _usuarioController,
                        ),
                        custom_input(
                          label: 'Nombre',
                          hint: 'Introduce tu nombre',
                          controller: _nombreController,
                        ),
                        custom_input(
                          label: 'Apellidos',
                          hint: 'Introduce tus apellidos',
                          controller: _apellidoController,
                        ),
                        custom_input(
                          label: 'Email',
                          hint: 'Introduce tu email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        custom_input(
                          label: 'Contraseña',
                          hint: 'Introduce tu contraseña',
                          controller: _passwordController,
                          isPassword: true,
                        ),

                        // CHECKBOX
                        Transform.translate(
                          offset: const Offset(-8, 0),
                          child: Row(
                            children: [
                              Checkbox(
                                value: _aceptaTerminos,
                                activeColor: AppColors.verdePrincipal,
                                visualDensity: VisualDensity.compact,
                                onChanged: (value) =>
                                    setState(() => _aceptaTerminos = value!),
                              ),
                              Text(
                                "Acepto términos y condiciones",
                                style: Theme.of(context).textTheme.labelMedium
                                    ?.copyWith(
                                      fontSize: 12,
                                      color: AppColors.negroTexto,
                                    ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        CustomButton(
                          text: _isLoading ? "CARGANDO..." : "Crear cuenta",
                          onPressed: _isLoading || !_aceptaTerminos ? null : _handleRegister,
                        ),

                        const SizedBox(height: 16),

                        // FOOTER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("¿Ya tienes cuenta?  "),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Text(
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
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
