import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validadores.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/auth/auth_logo.dart';
import '../../../core/widgets/auth/auth_snack_bar.dart';
import '../../../core/widgets/buttons/custom_button.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../domain/usescases/auth_use_cases.dart';
import 'auth_use_cases_factory.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _aceptaTerminos = false;
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  late final AuthUsesCases _authUseCases;

  @override
  void initState() {
    super.initState();
    _authUseCases = createAuthUseCases();

    // Escuchar cambios para habilitar botón
    _usuarioController.addListener(_validateForm);
    _nombreController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled =
          _usuarioController.text.isNotEmpty &&
          _nombreController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _aceptaTerminos;
    });
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _aceptaTerminos) {
      setState(() => _isLoading = true);

      try {
        await _authUseCases.register(
          nombre: _nombreController.text.trim(),
          usuario: _usuarioController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = "Error al registrarse";

          if (e.toString().contains('email-already-in-use')) {
            errorMessage = "El correo electrónico ya está registrado.";
          } else {
            errorMessage = e.toString().replaceAll("Exception: ", "");
          }

          showAuthSnackBar(context, errorMessage);
        }
        debugPrint(e.toString());
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else if (!_aceptaTerminos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes aceptar los términos y condiciones."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // 1. FONDO
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/Mapa_fondo_Extremadura.png'),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 2. LOGO
                  AuthLogo(height: size.height * 0.10),

                  const SizedBox(height: 10),

                  // 3. CARD DE REGISTRO
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: AuthCard(
                      children: [
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInput(
                                label: 'Usuario',
                                hint: 'Introduce tu nombre de usuario',
                                controller: _usuarioController,
                                validator: (value) =>
                                    Validadores.validarCampoVacio(
                                      value,
                                      'Usuario',
                                    ),
                              ),
                              CustomInput(
                                label: 'Nombre',
                                hint: 'Introduce tu nombre',
                                controller: _nombreController,
                                validator: Validadores.validarNombre,
                              ),
                              CustomInput(
                                label: 'Email',
                                hint: 'Introduce tu email',
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                validator: Validadores.validarEmail,
                              ),
                              CustomInput(
                                label: 'Contraseña',
                                hint: 'Introduce tu contraseña',
                                controller: _passwordController,
                                isPassword: true,
                                validator: Validadores.validarPassword,
                              ),

                              CustomInput(
                                label: 'Confirmar Contraseña',
                                hint: 'Repite tu contraseña',
                                controller: _confirmPasswordController,
                                isPassword: true,
                                validator: (value) =>
                                    Validadores.validarCoincidencia(
                                      value,
                                      _passwordController.text,
                                    ),
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
                                      onChanged: (value) {
                                        setState(
                                          () => _aceptaTerminos = value!,
                                        );
                                        _validateForm();
                                      },
                                    ),
                                    Text(
                                      "Acepto términos y condiciones",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium
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
                                text: _isLoading
                                    ? "CARGANDO..."
                                    : "Crear cuenta",
                                onPressed: _isButtonEnabled
                                    ? _handleRegister
                                    : null,
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
