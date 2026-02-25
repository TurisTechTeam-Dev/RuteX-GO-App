import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/buttons/custom_button.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usuario = TextEditingController();
  final _nombre = TextEditingController();
  final _apellido = TextEditingController();
  final _email = TextEditingController();
  final _contrasena = TextEditingController();
  bool _acpterTerminos = false;

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
                opacity: 0.3,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(),
                // LOGO
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    'assets/logos finales rutexgo1.2.png',
                    height: size.height * 0.12,
                  ),
                ),

                const SizedBox(height: 8),

                // CARD
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45),
                  child: AuthCard(
                    children: [
                      //usuario
                      custom_input(
                        label: 'Usuario',
                        hint: 'Introduce tu nombre de usuario',
                        controller: _usuario,
                        keyboardType: TextInputType.emailAddress,
                      ),

                      const SizedBox(),

                      custom_input(
                        label: 'nombre',
                        hint: 'Introduce tu email',
                        controller: _nombre,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(),
                      custom_input(
                        label: 'Apellidos',
                        hint: 'Introduce tus apellidos',
                        controller: _apellido,
                        keyboardType: TextInputType.visiblePassword,
                      ),
                        const SizedBox(),
                      custom_input(
                        label: 'Eamil',
                        hint: 'Introduce tu email',
                        controller: _email,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(),
                      custom_input(
                        label: 'Contraseña',
                        hint: 'Introduce tu contraseña',
                        controller: _contrasena,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      
                      Row(
                        children: [
                          Checkbox(
                            value: _acpterTerminos,
                            activeColor: const Color(0xFF007D3A),
                            checkColor: Theme.of(context).colorScheme.surface,
                            onChanged: (bool? value) {
                              setState(() {
                                _acpterTerminos = value!;
                              });
                            },
                          ),
                          Text("Acepto terminos y condiciones",
                          style: Theme.of(context).textTheme.labelMedium
                            
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      CustomButton(text: "Crear cuneta"),
                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("¿Ya tienes cuenta? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            child: Text(
                              "Iniciar sesion",
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
