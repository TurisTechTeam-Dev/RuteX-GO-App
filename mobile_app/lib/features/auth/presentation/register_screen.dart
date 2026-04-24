import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/auth/auth_logo.dart';
import '../../../core/widgets/auth/auth_snack_bar.dart';
import '../../../core/widgets/buttons/custom_button.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../domain/usecases/auth_use_cases.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptedTerms = false;
  bool _isLoading = false;
  bool _isButtonEnabled = false;

  late final AuthUseCases _authUseCases;

  @override
  void initState() {
    super.initState();
    _authUseCases = context.read<AuthUseCases>();

    _usernameController.addListener(_validateForm);
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isButtonEnabled =
          _usernameController.text.isNotEmpty &&
          _nameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          _acceptedTerms;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptedTerms) {
      setState(() => _isLoading = true);

      try {
        await _authUseCases.register(
          name: _nameController.text.trim(),
          username: _usernameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          var errorMessage = "Error al registrarse";

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
    } else if (!_acceptedTerms) {
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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
              opacity: 0.3,
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
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInput(
                                label: 'Usuario',
                                hint: 'Introduce tu nombre de usuario',
                                controller: _usernameController,
                                validator: (value) =>
                                    Validators.validateRequiredField(
                                      value,
                                      'Usuario',
                                    ),
                              ),
                              CustomInput(
                                label: 'Nombre',
                                hint: 'Introduce tu nombre',
                                controller: _nameController,
                                validator: Validators.validateName,
                              ),
                              CustomInput(
                                label: 'Email',
                                hint: 'Introduce tu email',
                                controller: _emailController,
                                keyboardType: TextInputType.text,
                                validator: Validators.validateEmail,
                              ),
                              CustomInput(
                                label: 'Contraseña',
                                hint: 'Introduce tu contraseña',
                                controller: _passwordController,
                                isPassword: true,
                                validator: Validators.validatePassword,
                              ),
                              CustomInput(
                                label: 'Confirmar contraseña',
                                hint: 'Repite tu contraseña',
                                controller: _confirmPasswordController,
                                isPassword: true,
                                validator: (value) =>
                                    Validators.validatePasswordMatch(
                                      value,
                                      _passwordController.text,
                                    ),
                              ),
                              Transform.translate(
                                offset: const Offset(-8, 0),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _acceptedTerms,
                                      activeColor: AppColors.verdePrincipal,
                                      visualDensity: VisualDensity.compact,
                                      onChanged: (value) {
                                        setState(
                                          () => _acceptedTerms = value ?? false,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("¿Ya tienes cuenta?  "),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
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
