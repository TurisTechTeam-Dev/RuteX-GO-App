import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    final puntos = args?["puntos"] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Resultado", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "MISIÓN COMPLETADA",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Text(
              "$puntos puntos",
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: AppColors.verdePrincipal,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(
                  context,
                  ModalRoute.withName(AppRoutes.missionQrScanner),
                );
              },
              child: const Text("CONTINUAR RUTA"),
            ),
          ],
        ),
      ),
    );
  }
}
