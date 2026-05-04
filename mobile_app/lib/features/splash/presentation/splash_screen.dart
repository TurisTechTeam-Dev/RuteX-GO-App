/*
  -----------------------------------------------------------------------------
  Proyecto: RuteX Go
  Desarrollado por: TurisTechTeam
  Descripción: Esta aplicación y su código fuente son propiedad intelectual de
  TurisTechTeam. Queda prohibida su copia, distribución o uso no autorizado.
  Año: 2026
  -----------------------------------------------------------------------------
*/
import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../app/navigation/app_routes.dart';
import '../../auth/domain/usecases/auth_use_cases.dart';

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

  Future<void> _checkSession() async {
    final authUseCases = Provider.of<AuthUseCases>(context, listen: false);

    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;

      final user = authUseCases.getCurrentUser();

      if (user != null) {
        final isAdmin = await authUseCases.checkAdminStatus(user.uid);

        if (!mounted) return;

        if (kIsWeb && isAdmin) {
          Navigator.pushReplacementNamed(context, AppRoutes.adminPanel);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
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
