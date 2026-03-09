import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/features/auth/domain/repository/auth_repository.dart';
import 'package:mobile_app/features/auth/domain/usescases/auth_use_cases.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../../../core/widgets/buttons/custom_button.dart';
import '../../../core/utils/validadores.dart';
import '../data/auth_repository_impl.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final AuthUsesCases _authUseCases;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final repository = AuthRepositoryImpl(
      FirebaseAuth.instance,
      FirebaseFirestore.instance,
    );
    _authUseCases = AuthUsesCases(repository as AuthRepository);
  }

  Future<void> _handleLogin() async {

    if(!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authUseCases.login(
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_errorMessage!), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _recoverPassword() async{
    final emailerror = Validadores.validarEmail(_emailController.text);
    if(emailerror != null){
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Introduce un email válido arriba para recuperar tu contraseña"),
            backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try{
      await _authUseCases.recoverPassword(_emailController.text.trim());
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Correo de recuperacuión enviado."),
              backgroundColor: AppColors.exito,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // FONDO (Mapa)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa_Fondo_Extremadura.jpeg'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 80),
                // LOGO
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/Logo_Color_Rutexgo.png',
                    height: size.height * 0.18,
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
                      fontSize: 18,
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
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            custom_input(
                              label: 'Email',
                              hint: 'Introduce tu email',
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              validator: Validadores.validarEmail,
                            ),

                            custom_input(
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

                      // BOTÓN INICIAR SESIÓN
                      CustomButton(
                        text: _isLoading ? "CARGANDO..." : "Iniciar Sesión",
                        onPressed: _isLoading ? null : _handleLogin,
                      ),

                      // ENLACE CONTRASEÑA OLVIDADA
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: _recoverPassword,
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
                                    .verdePrincipal,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration
                                    .none,
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
