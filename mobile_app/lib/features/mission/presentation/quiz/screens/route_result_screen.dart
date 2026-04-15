import 'package:flutter/material.dart';
import 'package:mobile_app/core/widgets/Bars/toppAppBarr.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;

    // Placeholders neutros: luego conectas casos de uso/Firestore.
    final puntuacion = args?['puntuacion']?.toString() ?? '--';
    final monumentos = args?['monumentos']?.toString() ?? '--';
    final tiempo = args?['tiempo']?.toString() ?? '--';

    return Scaffold(
      backgroundColor: AppColors.blancoPuro,

      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¡Resultados de tu Ruta!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Puntuación: $puntuacion'),
            Text('Monumentos Visitados: $monumentos'),
            Text('Tiempo Total: $tiempo'),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                      (route) => false,
                );
              },
              child: Text('Volver al Inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
