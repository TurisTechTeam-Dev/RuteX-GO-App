import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart'; // Importamos tus nuevas rutas

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Temporizador de 3 segundos para ir al Login
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Usamos la ruta nombrada que definimos en AppRoutes
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          // 1. Imagen de fondo (Mapa)
          Center(
            child: Image.asset(
              'assets/Mapa Fondo Extremadura.jpeg',
              fit: BoxFit.contain,
            ),
          ),

          // 2. Logo centrado
          Center(
            child: Image.asset(
              'assets/logos finales rutexgo1.2.png',
              width: 300,
            ),
          ),

          // 3. Círculo de carga
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 100),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                strokeWidth: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
