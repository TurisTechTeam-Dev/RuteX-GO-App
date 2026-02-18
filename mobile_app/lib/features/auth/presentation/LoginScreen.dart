import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';

import '../../../core/widgets/auth/auth_card.dart';
import '../../../core/widgets/inputs/custom_inputs.dart';
import '../../../core/widgets/buttons/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para ajustar el logo
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // extendBodyBehindAppBar permite que el fondo llegue hasta la zona de la batería
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // 1. IMAGEN DE FONDO (Mapa de Extremadura)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/Mapa Fondo Extremadura.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 2. CAPA SUTIL DE OSCURECIMIENTO
          // Ayuda a que el contenido de la tarjeta resalte más
          Container(color: Colors.black.withOpacity(0.05)),

          // 3. CONTENIDO PRINCIPAL
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // LOGO DE RUTEXGO
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      'assets/logos finales rutexgo1.2.png',
                      height: size.height * 0.18, // 18% del alto de pantalla
                    ),
                  ),
                  const SizedBox(height: 30),

                  // TARJETA DE AUTENTICACIÓN (Tu widget separado)
                  AuthCard(
                    children: [
                      Text(
                        "Iniciar Sesión",
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 25),

                      // INPUTS (Tus widgets separados)
                      const custom_input(
                        label: 'Usuario',
                        hint: 'Introduce tu usuario',
                        keyboardType: TextInputType.text,
                      ),

                      const custom_input(
                        label: 'Contraseña',
                        hint: '********',
                        isPassword: true,
                        keyboardType: TextInputType.visiblePassword,
                      ),

                      const SizedBox(height: 10),

                      // BOTÓN (Tu widget separado)
                      custom_button(
                        text: "ENTRAR",
                        onPressed: () {
                          // Navegación hacia el Home
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        },
                      ),

                      const SizedBox(height: 20),

                      // ENLACE A REGISTRO
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "¿No tienes cuenta? ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () {
                              // Navegación a Registro (ajusta según tu AppRoutes)
                              Navigator.pushNamed(context, AppRoutes.register);
                            },
                            child: Text(
                              "Regístrate",
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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