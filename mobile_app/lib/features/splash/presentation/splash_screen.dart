import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // Necesario para kIsWeb
import 'package:provider/provider.dart'; // Necesario para leer el UseCase
import 'package:mobile_app/core/constants/app_colors.dart';
import '../../auth/domain/usescases/auth_use_cases.dart'; // Ajusta la ruta si es necesario
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

  // Convertimos a async para poder usar await con checkAdminStatus
  Future<void> _checkSession() async {
    final authUseCases = Provider.of<AuthUsesCases>(context, listen: false);

    // Timer de 3 segundos para mostrar la marca
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      // Recuperamos el usuario actual
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Comprobamos si es admin
        final bool isAdmin = await authUseCases.checkAdminStatus(user.uid);

        if (!mounted) return;

        if (kIsWeb && isAdmin) {
          // Si es Web + Admin, el AuthWrapper ya se encarga de ir al panel de administracion
          Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
        } else {
          // Si es móvil o usuario normal
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        // Si no hay sesión, al Login
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
          Center(
            child: Image.asset(
              'assets/Mapa_fondo_Extremadura.png',
              fit: BoxFit.contain,
            ),
          ),
          Center(
            child: Image.asset('assets/Logo_Color_Rutexgo.png', width: 300),
          ),
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
