import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/widgets/Bars/toppAppBarr.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/cards/custom_cards.dart';
import '../../profile/presentation/home_screen.dart';

class RouteSelectionScreen extends StatelessWidget {
  const RouteSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(showBack: true),
      endDrawer: const CustomDrawer(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.blancoPuro,
              image: DecorationImage(
                image: AssetImage('assets/Mapa_fondo_Extremadura.png'),
                opacity: 0.4,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(height: 2, color: AppColors.negroTexto),
                const SizedBox(height: 20),
                const StrokeTitle(text: "Rutas en Mérida"),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // RUTA 1: ID corregido para Firebase
                      _routeCard(
                        context,
                        routeId: "ruta_merida_1",
                        image: "assets/merida_monumental.png",
                        title: "Ruta Monumental Romana",
                        description: "Teatro, Anfiteatro, Circo Romano",
                        difficulty: "Fácil",
                        time: "2 h",
                        distance: "3 km",
                      ),

                      // RUTA 2: ID corregido para Firebase
                      _routeCard(
                        context,
                        routeId: "ruta_merida_2",
                        image: "assets/merida_cotidiana.png",
                        title: "Ruta Roma Cotidiana",
                        description: "Templo de Diana, Foro Romano, Casa Mitreo",
                        difficulty: "Fácil",
                        time: "1.5 h",
                        distance: "1 km",
                      ),

                      // RUTA 3: ID corregido para Firebase
                      _routeCard(
                        context,
                        routeId: "ruta_merida_3",
                        image: "assets/merida_vidafe.jpg",
                        title: "Ruta Vida y Fe",
                        description: "Basílica de Santa Eulalia, Cripta de Santa Eulalia, Alcazaba Árabe",
                        difficulty: "Fácil",
                        time: "2 h",
                        distance: "1,5 km",
                      ),
                      const SizedBox(height: 60)
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 10,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: AppColors.negroTexto, width: 2),
          ),
        ),
        child: const SafeArea(child: SizedBox()),
      ),
    );
  }
}

// WIDGET DE TARJETA CORREGIDO
Widget _routeCard(
    BuildContext context, {
      required String routeId, // Recibimos el ID de la ruta
      required String image,
      required String title,
      required String description,
      required String difficulty,
      required String time,
      required String distance,
    }) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: CustomCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // IMAGEN
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.negroTexto, width: 1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(image, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // TITULO
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance, color: AppColors.verdePrincipal, size: 20),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.negroTexto),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // DESCRIPCION
          Text(
            description,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 10),
          // INFO RUTA
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 6,
            children: [
              _infoRow(Icons.extension, "Dificultad: $difficulty"),
              _infoRow(Icons.access_time, "Tiempo: $time"),
              _infoRow(Icons.route, "Distancia: $distance"),
            ],
          ),
          const SizedBox(height: 12),
          // BOTON - AHORA PASA EL ID
          SizedBox(
            height: 36,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.verdePrincipal,
                foregroundColor: AppColors.blancoPuro,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              onPressed: () {
                // ENVIAMOS EL ID COMO ARGUMENTO
                Navigator.pushNamed(
                  context,
                  AppRoutes.mapNavigation,
                  arguments: routeId,
                );
              },
              child: const Text("Comenzar ruta"),
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget auxiliar para no repetir código de los iconos de info
Widget _infoRow(IconData icon, String text) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 18, color: AppColors.verdePrincipal),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12)),
    ],
  );
}