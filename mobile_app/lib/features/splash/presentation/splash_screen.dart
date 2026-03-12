import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

import '../../../core/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() {
    // Timer de 3 segundos para mostrar tu marca
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      // Recuperamos el usuario actual (Firebase mantiene el token en local)
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blancoPuro,
      body: Stack(
        children: [
          // Imagen de fondo (Mapa)
          Center(
            child: Image.asset(
              'assets/Mapa_Fondo_Extremadura.jpeg',
              fit: BoxFit.contain,
            ),
          ),
          // Logo centrado
          Center(
            child: Image.asset('assets/Logo_Color_Rutexgo.png', width: 300),
          ),
          // Círculo de carga
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: CircularProgressIndicator(
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
