import 'package:flutter/material.dart';

import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/backgrounds/extremadura_map_background.dart';
import '../../../../../core/widgets/bars/top_app_bar.dart';

class RouteResultScreen extends StatelessWidget {
  const RouteResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final score = args?['puntuacion']?.toString() ?? '--';
    final monuments = args?['monumentos']?.toString() ?? '--';
    final time = args?['tiempo']?.toString() ?? '--';

    return Scaffold(
      appBar: const TopAppBar(showBack: false),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          const ExtremaduraMapBackground(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Resultados de tu Ruta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text('Puntuacion: $score'),
                Text('Monumentos Visitados: $monuments'),
                Text('Tiempo Total: $time'),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                  child: const Text('Volver al Inicio'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
